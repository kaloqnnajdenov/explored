import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:h3_flutter/h3_flutter.dart';
import '../../../../constants.dart';
import '../../../location/data/models/lat_lng_sample.dart';
import '../../../location/data/repositories/location_updates_repository.dart';
import '../models/explored_area_log_entry.dart';
import '../models/visited_grid_bounds.dart';
import '../models/visited_grid_cell.dart';
import '../models/visited_grid_cell_bounds.dart';
import '../models/visited_grid_cell_update.dart';
import '../models/visited_grid_config.dart';
import '../models/visited_grid_overlay.dart';
import '../models/visited_grid_stats.dart';
import '../models/visited_overlay_polygon.dart';
import '../models/visited_time_filter.dart';
import '../services/explored_area_logger.dart';
import '../services/visited_grid_database.dart';
import '../services/visited_grid_h3_service.dart';

abstract class VisitedGridRepository {
  Stream<VisitedGridCellUpdate> get cellUpdates;
  Stream<VisitedGridStats> get statsUpdates;
  Future<void> start();
  Future<void> stop();
  Future<void> dispose();
  Future<void> ingestSamples(Iterable<LatLngSample> samples);
  Future<VisitedGridStats> fetchStats();
  Future<void> logExploredAreaViewed();
  Future<VisitedGridOverlay> loadOverlay({
    required VisitedGridBounds bounds,
    required double zoom,
    required VisitedTimeFilter timeFilter,
  });
}

class DefaultVisitedGridRepository implements VisitedGridRepository {
  DefaultVisitedGridRepository({
    required LocationUpdatesRepository locationUpdatesRepository,
    required VisitedGridDao visitedGridDao,
    required VisitedGridH3Service h3Service,
    required ExploredAreaLogger exploredAreaLogger,
    required String appVersion,
    required int schemaVersion,
    VisitedGridConfig config = const VisitedGridConfig(),
    DateTime Function()? nowProvider,
  })  : _locationUpdatesRepository = locationUpdatesRepository,
        _visitedGridDao = visitedGridDao,
        _h3Service = h3Service,
        _exploredAreaLogger = exploredAreaLogger,
        _appVersion = appVersion,
        _schemaVersion = schemaVersion,
        _config = config,
        _now = nowProvider ?? DateTime.now;

  final LocationUpdatesRepository _locationUpdatesRepository;
  final VisitedGridDao _visitedGridDao;
  final VisitedGridH3Service _h3Service;
  final ExploredAreaLogger _exploredAreaLogger;
  final String _appVersion;
  final int _schemaVersion;
  final VisitedGridConfig _config;
  final DateTime Function() _now;

  StreamSubscription<LatLngSample>? _subscription;
  final StreamController<VisitedGridCellUpdate> _cellUpdatesController =
      StreamController<VisitedGridCellUpdate>.broadcast();
  final StreamController<VisitedGridStats> _statsController =
      StreamController<VisitedGridStats>.broadcast();
  bool _writeInFlight = false;
  final ListQueue<LatLngSample> _pendingSamples =
      ListQueue<LatLngSample>();
  Completer<void>? _drainCompleter;
  String? _lastPersistedCellId;
  int? _lastPersistedHour;
  int? _lastCleanupTs;
  bool _cleanupLoaded = false;
  bool _statsLoaded = false;
  VisitedGridStats? _lastStats;
  bool _disposed = false;

  @override
  Stream<VisitedGridCellUpdate> get cellUpdates =>
      _cellUpdatesController.stream;

  @override
  Stream<VisitedGridStats> get statsUpdates => _statsController.stream;

  @override
  Future<void> start() async {
    if (_subscription != null) {
      return;
    }

    _subscription = _locationUpdatesRepository.locationUpdates.listen(
      _handleSample,
      onError: (error) {
        debugPrint('Visited grid location update error: $error');
      },
    );
    _scheduleStatsReconcile();
  }

  @override
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _pendingSamples.clear();
    _completeDrainIfIdle();
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await stop();
    await _cellUpdatesController.close();
    await _statsController.close();
    _completeDrainIfIdle();
  }

  @override
  Future<void> ingestSamples(Iterable<LatLngSample> samples) async {
    if (samples.isEmpty) {
      return;
    }
    _pendingSamples.addAll(samples);
    final completer = _ensureDrainCompleter();
    _kickDrain();
    await completer.future;
  }

  @override
  Future<VisitedGridStats> fetchStats() async {
    _statsLoaded = true;
    final cached = _lastStats;
    if (cached != null) {
      return cached;
    }
    final stats = await _loadStatsFromStore();
    if (stats != null) {
      _lastStats = stats;
      _statsController.add(stats);
      return stats;
    }
    final computed = await _computeStatsFromCanonical();
    await _persistStats(computed);
    _lastStats = computed;
    _statsController.add(computed);
    _logStatsEvent(
      event: 'explored_area_reconciled',
      stats: computed,
    );
    return computed;
  }

  @override
  Future<void> logExploredAreaViewed() async {
    final stats = await fetchStats();
    _logStatsEvent(
      event: 'explored_area_viewed',
      stats: stats,
    );
  }

  @override
  Future<VisitedGridOverlay> loadOverlay({
    required VisitedGridBounds bounds,
    required double zoom,
    required VisitedTimeFilter timeFilter,
  }) async {
    final resolution = _config.baseResolution;
    final visitedIds = await _fetchVisitedCellsInBounds(
      resolution: resolution,
      bounds: bounds,
      timeFilter: timeFilter,
    );

    if (visitedIds.isEmpty) {
      return VisitedGridOverlay(resolution: resolution, polygons: const []);
    }

    final polygons = <VisitedOverlayPolygon>[];
    for (final cellId in visitedIds) {
      final cell = _h3Service.decodeCellId(cellId);
      polygons.add(
        VisitedOverlayPolygon(outer: _h3Service.cellBoundary(cell)),
      );
    }

    return VisitedGridOverlay(resolution: resolution, polygons: polygons);
  }

  Future<void> _handleSample(LatLngSample sample) async {
    // Queue bursts so interpolated samples are not dropped mid-write.
    _pendingSamples.add(sample);
    _kickDrain();
  }

  void _kickDrain() {
    if (_writeInFlight) {
      return;
    }
    _writeInFlight = true;
    unawaited(_drainQueue());
  }

  Future<void> _drainQueue() async {
    try {
      while (_pendingSamples.isNotEmpty) {
        final next = _pendingSamples.removeFirst();
        await _processSample(next);
      }
    } finally {
      _writeInFlight = false;
      if (_pendingSamples.isNotEmpty) {
        _kickDrain();
        return;
      }
      _completeDrainIfIdle();
    }
  }

  Completer<void> _ensureDrainCompleter() {
    return _drainCompleter ??= Completer<void>();
  }

  void _completeDrainIfIdle() {
    if (_writeInFlight || _pendingSamples.isNotEmpty) {
      return;
    }
    final completer = _drainCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
    _drainCompleter = null;
  }

  Future<void> _processSample(LatLngSample sample) async {
    if (_disposed) {
      return;
    }
    if (sample.accuracyMeters != null &&
        sample.accuracyMeters! > _config.maxAcceptedAccuracyMeters) {
      return;
    }

    final timestamp = sample.timestamp;
    final hour = timestamp.toLocal().hour;
    final baseCell = _h3Service.cellForLatLng(
      latitude: sample.latitude,
      longitude: sample.longitude,
      resolution: _config.baseResolution,
    );
    final baseCellId = _h3Service.encodeCellId(baseCell);
    final baseCellAreaM2 = _h3Service.cellArea(baseCell, H3Units.m);

    if (_lastPersistedCellId == baseCellId && _lastPersistedHour == hour) {
      return;
    }

    _lastPersistedCellId = baseCellId;
    _lastPersistedHour = hour;

    final dayKey = _dayKey(timestamp);
    final hourMask = 1 << hour;
    final epochSeconds = timestamp.millisecondsSinceEpoch ~/ 1000;
    final latE5 = (sample.latitude * 100000).round();
    final lonE5 = (sample.longitude * 100000).round();

    final cells = <VisitedGridCell>[
      VisitedGridCell(
        resolution: _config.baseResolution,
        cellId: baseCellId,
      ),
    ];
    final bounds = <VisitedGridCellBounds>[
      ..._h3Service.cellBounds(baseCell),
    ];
    for (final resolution in _config.coarserResolutions) {
      if (resolution >= _config.baseResolution) {
        continue;
      }
      final parent = _h3Service.parentCell(
        cell: baseCell,
        resolution: resolution,
      );
      cells.add(
        VisitedGridCell(
          resolution: resolution,
          cellId: _h3Service.encodeCellId(parent),
        ),
      );
      bounds.addAll(_h3Service.cellBounds(parent));
    }

    final result = await _visitedGridDao.upsertVisit(
      cells: cells,
      cellBounds: bounds,
      day: dayKey,
      hourMask: hourMask,
      epochSeconds: epochSeconds,
      latE5: latE5,
      lonE5: lonE5,
      baseResolution: _config.baseResolution,
      baseCellId: baseCellId,
      baseCellAreaM2: baseCellAreaM2,
    );

    if (result.isNewBaseCell) {
      final stats = _mapStatsRow(result.statsRow) ??
          _lastStats?.copyWith(
            totalAreaM2: (_lastStats?.totalAreaM2 ?? 0) + baseCellAreaM2,
            cellCount: (_lastStats?.cellCount ?? 0) + 1,
            canonicalVersion:
                (_lastStats?.canonicalVersion ?? 0) + 1,
            lastUpdatedEpochSeconds: epochSeconds,
          ) ??
          VisitedGridStats(
            totalAreaM2: baseCellAreaM2,
            cellCount: 1,
            canonicalVersion: 1,
            lastUpdatedEpochSeconds: epochSeconds,
            lastReconciledEpochSeconds: null,
          );
      _lastStats = stats;
      _statsController.add(stats);
      _cellUpdatesController.add(
        VisitedGridCellUpdate(
          cellId: baseCellId,
          resolution: _config.baseResolution,
          deltaAreaM2: baseCellAreaM2,
          stats: stats,
          timestamp: timestamp,
        ),
      );
      _logStatsEvent(
        event: 'explored_area_cell_added',
        stats: stats,
        deltaAreaM2: baseCellAreaM2,
        cellId: baseCellId,
        timestamp: timestamp,
      );
    }

    await _maybeCleanup(epochSeconds, timestamp);
  }

  void _scheduleStatsReconcile() {
    if (_statsLoaded) {
      return;
    }
    _statsLoaded = true;
    unawaited(_reconcileStatsOnStartup());
  }

  Future<void> _reconcileStatsOnStartup() async {
    try {
      final stored = await _loadStatsFromStore();
      final computed = await _computeStatsFromCanonical(
        lastUpdatedEpochSeconds: stored?.lastUpdatedEpochSeconds,
      );
      if (stored == null || _statsMismatch(stored, computed)) {
        final reconciled = computed.copyWith(
          lastReconciledEpochSeconds:
              _now().millisecondsSinceEpoch ~/ 1000,
        );
        await _persistStats(reconciled);
        _lastStats = reconciled;
        _statsController.add(reconciled);
        _logStatsEvent(
          event: 'explored_area_reconciled',
          stats: reconciled,
          deltaAreaM2: stored == null
              ? reconciled.totalAreaM2
              : reconciled.totalAreaM2 - stored.totalAreaM2,
        );
      } else if (_lastStats == null) {
        _lastStats = stored;
        _statsController.add(stored);
      }
    } catch (error) {
      debugPrint('Visited grid stats reconcile failed: $error');
    }
  }

  bool _statsMismatch(VisitedGridStats stored, VisitedGridStats computed) {
    final deltaArea =
        (stored.totalAreaM2 - computed.totalAreaM2).abs();
    if (deltaArea > kVisitedGridStatsToleranceM2) {
      return true;
    }
    return stored.cellCount != computed.cellCount;
  }

  Future<VisitedGridStats?> _loadStatsFromStore() async {
    final row = await _visitedGridDao.fetchStats();
    return _mapStatsRow(row);
  }

  Future<VisitedGridStats> _computeStatsFromCanonical({
    int? lastUpdatedEpochSeconds,
  }) async {
    final cellIds = await _visitedGridDao.fetchLifetimeCellIds(
      _config.baseResolution,
    );
    var totalArea = 0.0;
    for (final cellId in cellIds) {
      final cell = _h3Service.decodeCellId(cellId);
      totalArea += _h3Service.cellArea(cell, H3Units.m);
    }
    final nowSeconds = _now().millisecondsSinceEpoch ~/ 1000;
    return VisitedGridStats(
      totalAreaM2: totalArea,
      cellCount: cellIds.length,
      canonicalVersion: cellIds.length,
      lastUpdatedEpochSeconds: lastUpdatedEpochSeconds ??
          (cellIds.isEmpty ? null : nowSeconds),
      lastReconciledEpochSeconds: nowSeconds,
    );
  }

  Future<void> _persistStats(VisitedGridStats stats) {
    return _visitedGridDao.upsertStats(
      VisitedGridStatsRow(
        id: kVisitedGridStatsRowId,
        totalAreaM2: stats.totalAreaM2,
        cellCount: stats.cellCount,
        canonicalVersion: stats.canonicalVersion,
        lastUpdatedTs: stats.lastUpdatedEpochSeconds,
        lastReconciledTs: stats.lastReconciledEpochSeconds,
      ),
    );
  }

  VisitedGridStats? _mapStatsRow(VisitedGridStatsRow? row) {
    if (row == null) {
      return null;
    }
    return VisitedGridStats(
      totalAreaM2: row.totalAreaM2,
      cellCount: row.cellCount,
      canonicalVersion: row.canonicalVersion,
      lastUpdatedEpochSeconds: row.lastUpdatedTs,
      lastReconciledEpochSeconds: row.lastReconciledTs,
    );
  }

  void _logStatsEvent({
    required String event,
    required VisitedGridStats stats,
    double? deltaAreaM2,
    String? cellId,
    DateTime? timestamp,
  }) {
    _exploredAreaLogger.log(
      ExploredAreaLogEntry(
        event: event,
        timestamp: timestamp ?? _now(),
        totalAreaM2: stats.totalAreaM2,
        totalAreaKm2: stats.totalAreaKm2,
        deltaAreaM2: deltaAreaM2,
        cellCount: stats.cellCount,
        canonicalVersion: stats.canonicalVersion,
        schemaVersion: _schemaVersion,
        appVersion: _appVersion,
        cellId: cellId,
      ),
    );
  }

  Future<Set<String>> _fetchVisitedCellsInBounds({
    required int resolution,
    required VisitedGridBounds bounds,
    required VisitedTimeFilter timeFilter,
  }) async {
    final southLatE5 = (bounds.south * 100000).floor();
    final northLatE5 = (bounds.north * 100000).ceil();
    final lonRanges = _lonRangesForBounds(bounds);

    if (timeFilter == VisitedTimeFilter.allTime) {
      final result = <String>{};
      for (final range in lonRanges) {
        result.addAll(
          await _visitedGridDao.fetchVisitedLifetimeInBounds(
            resolution: resolution,
            southLatE5: southLatE5,
            northLatE5: northLatE5,
            westLonE5: range.westE5,
            eastLonE5: range.eastE5,
          ),
        );
      }
      return result;
    }

    final range = _dayRange(timeFilter);
    final result = <String>{};
    for (final lonRange in lonRanges) {
      result.addAll(
        await _visitedGridDao.fetchVisitedDailyInBounds(
          resolution: resolution,
          startDay: range.startDay,
          endDay: range.endDay,
          southLatE5: southLatE5,
          northLatE5: northLatE5,
          westLonE5: lonRange.westE5,
          eastLonE5: lonRange.eastE5,
        ),
      );
    }
    return result;
  }

  _DayRange _dayRange(VisitedTimeFilter filter) {
    final now = _now().toLocal();
    final endDay = _dayKey(now);
    final window = filter.dayWindow ?? 0;
    final startDay = _dayKey(now.subtract(Duration(days: window)));
    return _DayRange(startDay: startDay, endDay: endDay);
  }

  int _dayKey(DateTime timestamp) {
    final local = timestamp.toLocal();
    return local.year * 10000 + local.month * 100 + local.day;
  }

  Future<void> _maybeCleanup(int epochSeconds, DateTime timestamp) async {
    final lastCleanup = await _ensureCleanupLoaded();
    if (lastCleanup != null &&
        epochSeconds - lastCleanup < _config.cleanupIntervalSeconds) {
      return;
    }

    final cutoff = timestamp
        .toLocal()
        .subtract(Duration(days: _config.maxDailyRetentionDays));
    final cutoffDay = _dayKey(cutoff);
    await _visitedGridDao.deleteDailyOlderThan(cutoffDay);
    await _visitedGridDao.setLastCleanupTs(epochSeconds);
    _lastCleanupTs = epochSeconds;
  }

  Future<int?> _ensureCleanupLoaded() async {
    if (_cleanupLoaded) {
      return _lastCleanupTs;
    }
    _cleanupLoaded = true;
    _lastCleanupTs = await _visitedGridDao.fetchLastCleanupTs();
    return _lastCleanupTs;
  }
}

class _DayRange {
  const _DayRange({required this.startDay, required this.endDay});

  final int startDay;
  final int endDay;
}

class _LonRangeE5 {
  const _LonRangeE5({required this.westE5, required this.eastE5});

  final int westE5;
  final int eastE5;
}

List<_LonRangeE5> _lonRangesForBounds(VisitedGridBounds bounds) {
  if (bounds.east >= bounds.west) {
    return [
      _LonRangeE5(
        westE5: (bounds.west * 100000).floor(),
        eastE5: (bounds.east * 100000).ceil(),
      ),
    ];
  }
  return [
    _LonRangeE5(
      westE5: (bounds.west * 100000).floor(),
      eastE5: 18000000,
    ),
    _LonRangeE5(
      westE5: -18000000,
      eastE5: (bounds.east * 100000).ceil(),
    ),
  ];
}
