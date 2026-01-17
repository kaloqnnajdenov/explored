import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../location/data/models/lat_lng_sample.dart';
import '../../../location/data/repositories/location_updates_repository.dart';
import '../models/visited_grid_bounds.dart';
import '../models/visited_grid_cell.dart';
import '../models/visited_grid_config.dart';
import '../models/visited_grid_overlay.dart';
import '../models/visited_time_filter.dart';
import '../services/visited_grid_database.dart';
import '../services/visited_grid_h3_service.dart';

abstract class VisitedGridRepository {
  Future<void> start();
  Future<void> stop();
  Future<void> dispose();
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
    VisitedGridConfig config = const VisitedGridConfig(),
    DateTime Function()? nowProvider,
  })  : _locationUpdatesRepository = locationUpdatesRepository,
        _visitedGridDao = visitedGridDao,
        _h3Service = h3Service,
        _config = config,
        _now = nowProvider ?? DateTime.now;

  final LocationUpdatesRepository _locationUpdatesRepository;
  final VisitedGridDao _visitedGridDao;
  final VisitedGridH3Service _h3Service;
  final VisitedGridConfig _config;
  final DateTime Function() _now;

  StreamSubscription<LatLngSample>? _subscription;
  bool _writeInFlight = false;
  final ListQueue<LatLngSample> _pendingSamples =
      ListQueue<LatLngSample>();
  String? _lastPersistedCellId;
  int? _lastPersistedHour;
  int? _lastCleanupTs;
  bool _cleanupLoaded = false;

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
  }

  @override
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _pendingSamples.clear();
  }

  @override
  Future<void> dispose() async {
    await stop();
  }

  @override
  Future<VisitedGridOverlay> loadOverlay({
    required VisitedGridBounds bounds,
    required double zoom,
    required VisitedTimeFilter timeFilter,
  }) async {
    // Viewport-only polyfill with resolution degradation to cap candidate size.
    var resolution = _config.resolutionForZoom(zoom);
    var candidates = _h3Service.polygonToCells(
      bounds: bounds,
      resolution: resolution,
    );

    while (candidates.length > _config.maxCandidateCells &&
        resolution > _config.minRenderResolution) {
      resolution -= 1;
      candidates = _h3Service.polygonToCells(
        bounds: bounds,
        resolution: resolution,
      );
    }

    if (candidates.isEmpty) {
      return VisitedGridOverlay(resolution: resolution, polygons: const []);
    }

    final candidateIds =
        candidates.map(_h3Service.encodeCellId).toList(growable: false);
    final visitedIds = await _fetchVisitedCells(
      resolution: resolution,
      candidateIds: candidateIds,
      timeFilter: timeFilter,
    );

    if (visitedIds.isEmpty) {
      return VisitedGridOverlay(resolution: resolution, polygons: const []);
    }

    final polygons = <List<LatLng>>[];
    for (final cellId in visitedIds) {
      final cell = _h3Service.decodeCellId(cellId);
      polygons.add(_h3Service.cellBoundary(cell));
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
      }
    }
  }

  Future<void> _processSample(LatLngSample sample) async {
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
    }

    await _visitedGridDao.upsertVisit(
      cells: cells,
      day: dayKey,
      hourMask: hourMask,
      epochSeconds: epochSeconds,
      latE5: latE5,
      lonE5: lonE5,
    );

    await _maybeCleanup(epochSeconds, timestamp);
  }

  Future<Set<String>> _fetchVisitedCells({
    required int resolution,
    required List<String> candidateIds,
    required VisitedTimeFilter timeFilter,
  }) async {
    if (candidateIds.isEmpty) {
      return <String>{};
    }

    if (timeFilter == VisitedTimeFilter.allTime) {
      return _visitedGridDao.fetchVisitedLifetimeCells(
        resolution: resolution,
        cellIds: candidateIds,
      );
    }

    final range = _dayRange(timeFilter);
    return _visitedGridDao.fetchVisitedDailyCells(
      resolution: resolution,
      cellIds: candidateIds,
      startDay: range.startDay,
      endDay: range.endDay,
    );
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
