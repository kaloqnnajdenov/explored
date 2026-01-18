import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import '../../../location/data/models/lat_lng_sample.dart';
import '../../../location/data/repositories/location_updates_repository.dart';
import '../models/visited_grid_bounds.dart';
import '../models/visited_grid_cell.dart';
import '../models/visited_grid_cell_bounds.dart';
import '../models/visited_grid_config.dart';
import '../models/visited_grid_overlay.dart';
import '../models/visited_overlay_polygon.dart';
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

    await _visitedGridDao.upsertVisit(
      cells: cells,
      cellBounds: bounds,
      day: dayKey,
      hourMask: hourMask,
      epochSeconds: epochSeconds,
      latE5: latE5,
      lonE5: lonE5,
    );

    await _maybeCleanup(epochSeconds, timestamp);
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
