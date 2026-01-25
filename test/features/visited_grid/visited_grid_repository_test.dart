import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:explored/constants.dart';
import 'package:explored/features/location/data/models/lat_lng_sample.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_bounds.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_cell.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_cell_update.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_config.dart';
import 'package:explored/features/visited_grid/data/models/explored_area_log_entry.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_stats.dart';
import 'package:explored/features/visited_grid/data/models/visited_time_filter.dart';
import 'package:explored/features/visited_grid/data/repositories/visited_grid_repository.dart';
import 'package:explored/features/visited_grid/data/services/explored_area_logger.dart';
import 'package:explored/features/visited_grid/data/services/visited_grid_database.dart';
import 'package:explored/features/location/data/services/location_history_database.dart';

import 'visited_grid_test_utils.dart';

class _RepoHarness {
  _RepoHarness({
    required this.db,
    required this.historyDb,
    required this.dao,
    required this.h3,
    required this.locationRepo,
    required this.logger,
    required this.repository,
  });

  final VisitedGridDatabase db;
  final LocationHistoryDatabase historyDb;
  final TestVisitedGridDao dao;
  final FakeVisitedGridH3Service h3;
  final TestLocationUpdatesRepository locationRepo;
  final TestExploredAreaLogger logger;
  final DefaultVisitedGridRepository repository;
}

class TestExploredAreaLogger implements ExploredAreaLogger {
  final List<ExploredAreaLogEntry> entries = [];

  @override
  void log(ExploredAreaLogEntry entry) {
    entries.add(entry);
  }
}

Future<_RepoHarness> _buildHarness({
  VisitedGridConfig config = const VisitedGridConfig(),
  DateTime Function()? nowProvider,
  bool forceRebuild = false,
}) async {
  final db = buildTestDb();
  final historyDb = buildHistoryTestDb();
  final dao = TestVisitedGridDao(db);
  if (!forceRebuild) {
    await dao.setGridVersion(config.baseResolution);
  }
  final h3 = FakeVisitedGridH3Service();
  final locationRepo = TestLocationUpdatesRepository();
  final logger = TestExploredAreaLogger();
  final repository = DefaultVisitedGridRepository(
    locationUpdatesRepository: locationRepo,
    visitedGridDao: dao,
    locationHistoryDao: historyDb.locationHistoryDao,
    h3Service: h3,
    exploredAreaLogger: logger,
    appVersion: '1.0.0',
    schemaVersion: db.schemaVersion,
    config: config,
    nowProvider: nowProvider,
  );
  await repository.start();
  return _RepoHarness(
    db: db,
    historyDb: historyDb,
    dao: dao,
    h3: h3,
    locationRepo: locationRepo,
    logger: logger,
    repository: repository,
  );
}

Future<void> _tearDownHarness(_RepoHarness harness) async {
  await harness.repository.dispose();
  await harness.locationRepo.close();
  await harness.db.close();
  await harness.historyDb.close();
}

LatLngSample _sample({
  required double latitude,
  required double longitude,
  required DateTime timestamp,
  double? accuracyMeters,
}) {
  return LatLngSample(
    latitude: latitude,
    longitude: longitude,
    timestamp: timestamp,
    accuracyMeters: accuracyMeters,
  );
}

int _dayKey(DateTime timestamp) {
  final local = timestamp.toLocal();
  return local.year * 10000 + local.month * 100 + local.day;
}

Future<void> _drain() async {
  await pumpEventQueue(times: 10);
}

void main() {
  group('VisitedGridRepository write gates', () {
    test('Accuracy gate skips samples above threshold', () async {
      final harness = await _buildHarness();

      harness.locationRepo.emit(
        _sample(
          latitude: 1,
          longitude: 2,
          timestamp: DateTime(2024, 1, 1, 10),
          accuracyMeters: 60,
        ),
      );
      await _drain();

      expect(harness.dao.upsertCalls, 0);
      expect(harness.h3.cellForLatLngCalls, 0);
      final dailyRows = await (harness.db.select(harness.db.visitsDaily)
            ..where((tbl) => tbl.res.equals(kBaseH3Resolution)))
          .get();
      expect(dailyRows, isEmpty);

      await _tearDownHarness(harness);
    });

    test('Stationary de-dupe skips same cell in same hour', () async {
      final harness = await _buildHarness();
      final time = DateTime(2024, 1, 1, 10, 5);

      harness.locationRepo.emit(
        _sample(latitude: 1, longitude: 2, timestamp: time),
      );
      harness.locationRepo.emit(
        _sample(
          latitude: 1,
          longitude: 2,
          timestamp: time.add(const Duration(minutes: 10)),
        ),
      );
      await _drain();

      expect(harness.dao.upsertCalls, 1);
      final dailyRows = await (harness.db.select(harness.db.visitsDaily)
            ..where((tbl) => tbl.res.equals(kBaseH3Resolution)))
          .get();
      expect(dailyRows, hasLength(1));
      expect(dailyRows.first.samples, 1);

      await _tearDownHarness(harness);
    });

    test('ingestSamples awaits queued writes', () async {
      final harness = await _buildHarness();
      final gate = Completer<void>();
      harness.dao.upsertGate = gate;

      var completed = false;
      final future = harness.repository.ingestSamples([
        _sample(
          latitude: 1,
          longitude: 2,
          timestamp: DateTime(2024, 1, 1, 10, 5),
        ),
      ]);
      future.then((_) => completed = true);

      await pumpEventQueue(times: 5);
      expect(completed, isFalse);

      gate.complete();
      await future;
      expect(completed, isTrue);

      await _tearDownHarness(harness);
    });

    test('Queues samples while writes are in flight', () async {
      final harness = await _buildHarness();
      final gate = Completer<void>();
      harness.dao.upsertGate = gate;

      final baseTime = DateTime(2024, 1, 1, 10);
      harness.locationRepo.emit(
        _sample(latitude: 1, longitude: 1, timestamp: baseTime),
      );
      await _drain();

      harness.locationRepo.emit(
        _sample(
          latitude: 2,
          longitude: 2,
          timestamp: baseTime.add(const Duration(minutes: 1)),
        ),
      );
      harness.locationRepo.emit(
        _sample(
          latitude: 3,
          longitude: 3,
          timestamp: baseTime.add(const Duration(minutes: 2)),
        ),
      );

      gate.complete();
      await _drain();

      final dailyRows = await (harness.db.select(harness.db.visitsDaily)
            ..where((tbl) => tbl.res.equals(kBaseH3Resolution)))
          .get();
      final latValues = dailyRows.map((row) => row.latE5).toSet();
      expect(dailyRows, hasLength(3));
      expect(latValues.contains(100000), isTrue);
      expect(latValues.contains(200000), isTrue);
      expect(latValues.contains(300000), isTrue);

      await _tearDownHarness(harness);
    });

    test('Write path never invokes polyfill', () async {
      final harness = await _buildHarness();
      harness.locationRepo.emit(
        _sample(
          latitude: 1,
          longitude: 2,
          timestamp: DateTime(2024, 1, 1, 10),
        ),
      );
      await _drain();

      expect(harness.h3.polygonCalls, 0);

      await _tearDownHarness(harness);
    });
  });

  group('VisitedGridRepository stats', () {
    test('Emits stats + cell update for new base cell', () async {
      final harness = await _buildHarness();
      final updates = <VisitedGridCellUpdate>[];
      final statsUpdates = <VisitedGridStats>[];
      final updateSub = harness.repository.cellUpdates.listen(updates.add);
      final statsSub = harness.repository.statsUpdates.listen(statsUpdates.add);

      harness.locationRepo.emit(
        _sample(
          latitude: 1,
          longitude: 2,
          timestamp: DateTime(2024, 1, 1, 10),
        ),
      );
      await _drain();

      expect(updates, hasLength(1));
      expect(updates.first.deltaAreaM2, 50.0);
      expect(updates.first.stats.cellCount, 1);
      expect(statsUpdates.isNotEmpty, isTrue);
      expect(statsUpdates.last.totalAreaM2, 50.0);

      await updateSub.cancel();
      await statsSub.cancel();
      await _tearDownHarness(harness);
    });

    test('Does not increment stats for repeated cell', () async {
      final harness = await _buildHarness();
      final time = DateTime(2024, 1, 1, 10);

      harness.locationRepo.emit(
        _sample(latitude: 1, longitude: 2, timestamp: time),
      );
      harness.locationRepo.emit(
        _sample(
          latitude: 1,
          longitude: 2,
          timestamp: time.add(const Duration(minutes: 10)),
        ),
      );
      await _drain();

      final stats = await harness.repository.fetchStats();
      expect(stats.cellCount, 1);
      expect(stats.totalAreaM2, 50.0);

      await _tearDownHarness(harness);
    });
  });

  group('VisitedGridRepository persistence', () {
    test('Stores epoch seconds truncated from millis', () async {
      final harness = await _buildHarness();
      final timestamp =
          DateTime.fromMillisecondsSinceEpoch(1001, isUtc: true);

      harness.locationRepo.emit(
        _sample(latitude: 1, longitude: 2, timestamp: timestamp),
      );
      await _drain();

      final daily = await (harness.db.select(harness.db.visitsDaily)
            ..where((tbl) => tbl.res.equals(kBaseH3Resolution)))
          .getSingle();
      expect(
        daily.firstTs,
        timestamp.millisecondsSinceEpoch ~/ 1000,
      );
      expect(
        daily.lastTs,
        timestamp.millisecondsSinceEpoch ~/ 1000,
      );

      await _tearDownHarness(harness);
    });

    test('Day and hour boundaries create separate daily rows', () async {
      final harness = await _buildHarness();
      final beforeMidnight = DateTime(2024, 1, 1, 23, 59, 59);
      final afterMidnight = DateTime(2024, 1, 2, 0, 0, 1);

      harness.locationRepo.emit(
        _sample(latitude: 1, longitude: 2, timestamp: beforeMidnight),
      );
      harness.locationRepo.emit(
        _sample(latitude: 3, longitude: 4, timestamp: afterMidnight),
      );
      await _drain();

      final rows = await (harness.db.select(harness.db.visitsDaily)
            ..where((tbl) => tbl.res.equals(kBaseH3Resolution)))
          .get();
      expect(rows, hasLength(2));
      final byDay = {
        for (final row in rows) row.dayYyyyMmdd: row,
      };
      final day1 = _dayKey(beforeMidnight);
      final day2 = _dayKey(afterMidnight);
      expect(byDay.containsKey(day1), isTrue);
      expect(byDay.containsKey(day2), isTrue);
      expect(byDay[day1]!.hourMask, 1 << beforeMidnight.toLocal().hour);
      expect(byDay[day2]!.hourMask, 1 << afterMidnight.toLocal().hour);

      await _tearDownHarness(harness);
    });

    test('Aggregates base and coarser H3 resolutions', () async {
      final harness = await _buildHarness(
        config: const VisitedGridConfig(
          baseResolution: kBaseH3Resolution,
          coarserResolutions: [
            kBaseH3Resolution - 1,
            kBaseH3Resolution - 2,
          ],
        ),
      );

      harness.locationRepo.emit(
        _sample(latitude: 1, longitude: 2, timestamp: DateTime(2024, 1, 1)),
      );
      await _drain();

      final rows = await (harness.db.select(harness.db.visitsDaily)
            ..where(
              (tbl) => tbl.res.isIn([
                kBaseH3Resolution,
                kBaseH3Resolution - 1,
                kBaseH3Resolution - 2,
              ]),
            ))
          .get();
      final resolutions = rows.map((row) => row.res).toSet();
      expect(
        resolutions,
        {
          kBaseH3Resolution,
          kBaseH3Resolution - 1,
          kBaseH3Resolution - 2,
        },
      );
      expect(harness.h3.parentCellCalls, 2);

      await _tearDownHarness(harness);
    });
  });

  group('VisitedGridRepository retention', () {
    test('Deletes daily rows older than retention window', () async {
      final harness = await _buildHarness(
        config: const VisitedGridConfig(
          maxDailyRetentionDays: 1,
        ),
      );
      final now = DateTime(2024, 1, 3, 10);
      final oldDay = _dayKey(now.subtract(const Duration(days: 2)));

      await harness.db.customStatement(
        '''
INSERT INTO visits_daily (
  res, cell_id, day_yyyy_mmdd, hour_mask, first_ts, last_ts, samples, lat_e5, lon_e5
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
''',
        [kBaseH3Resolution, 'old_cell', oldDay, 1, 1, 1, 1, 0, 0],
      );

      harness.locationRepo.emit(
        _sample(latitude: 1, longitude: 2, timestamp: now),
      );
      await _drain();

      final rows = await harness.db.select(harness.db.visitsDaily).get();
      final containsOld =
          rows.any((row) => row.cellId == 'old_cell');
      expect(containsOld, isFalse);
      expect(harness.dao.deleteDailyCalls, 1);

      await _tearDownHarness(harness);
    });

    test('Cleanup is rate-limited by last cleanup timestamp', () async {
      final harness = await _buildHarness(
        config: const VisitedGridConfig(
          maxDailyRetentionDays: 1,
          cleanupIntervalSeconds: 6 * 60 * 60,
        ),
      );
      final now = DateTime(2024, 1, 3, 10);
      final oldDay = _dayKey(now.subtract(const Duration(days: 2)));

      await harness.db.customStatement(
        '''
INSERT INTO visits_daily (
  res, cell_id, day_yyyy_mmdd, hour_mask, first_ts, last_ts, samples, lat_e5, lon_e5
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
''',
        [kBaseH3Resolution, 'old_cell', oldDay, 1, 1, 1, 1, 0, 0],
      );

      harness.locationRepo.emit(
        _sample(latitude: 1, longitude: 2, timestamp: now),
      );
      await _drain();

      await harness.db.customStatement(
        '''
INSERT INTO visits_daily (
  res, cell_id, day_yyyy_mmdd, hour_mask, first_ts, last_ts, samples, lat_e5, lon_e5
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
''',
        [kBaseH3Resolution, 'old_cell', oldDay, 1, 1, 1, 1, 0, 0],
      );

      harness.locationRepo.emit(
        _sample(
          latitude: 3,
          longitude: 4,
          timestamp: now.add(const Duration(hours: 1)),
        ),
      );
      await _drain();

      var rows = await harness.db.select(harness.db.visitsDaily).get();
      expect(rows.any((row) => row.cellId == 'old_cell'), isTrue);
      expect(harness.dao.deleteDailyCalls, 1);

      harness.locationRepo.emit(
        _sample(
          latitude: 5,
          longitude: 6,
          timestamp: now.add(const Duration(hours: 7)),
        ),
      );
      await _drain();

      rows = await harness.db.select(harness.db.visitsDaily).get();
      expect(rows.any((row) => row.cellId == 'old_cell'), isFalse);
      expect(harness.dao.deleteDailyCalls, 2);

      await _tearDownHarness(harness);
    });
  });

  group('VisitedGridRepository read path', () {
    test('Uses base resolution for overlay regardless of zoom', () async {
      final harness = await _buildHarness();
      final cell = harness.h3.fakeCell(
        latitude: 1,
        longitude: 1,
        resolution: kBaseH3Resolution,
      );
      harness.h3.setBoundary(cell, const [
        LatLng(1, 1),
        LatLng(1, 2),
        LatLng(2, 2),
      ]);

      await harness.dao.upsertVisit(
        cells: [
          VisitedGridCell(
            resolution: kBaseH3Resolution,
            cellId: harness.h3.encodeCellId(cell),
          ),
        ],
        cellBounds: harness.h3.cellBounds(cell),
        day: 20240101,
        hourMask: 1,
        epochSeconds: 100,
        latE5: 100000,
        lonE5: 200000,
        baseResolution: kBaseH3Resolution,
        baseCellId: harness.h3.encodeCellId(cell),
        baseCellAreaM2: 50,
      );

      final overlay = await harness.repository.loadOverlay(
        bounds: const VisitedGridBounds(
          north: 2,
          south: 0,
          east: 2,
          west: 0,
        ),
        zoom: 8,
        timeFilter: VisitedTimeFilter.allTime,
      );

      expect(overlay.resolution, kBaseH3Resolution);
      expect(overlay.polygons, hasLength(1));

      await _tearDownHarness(harness);
    });

    test('Uses daily table for date-range filters', () async {
      final now = DateTime(2024, 1, 2, 12);
      final harness = await _buildHarness(nowProvider: () => now);
      final cell = harness.h3.fakeCell(
        latitude: 1,
        longitude: 1,
        resolution: kBaseH3Resolution,
      );
      final bounds = harness.h3.cellBounds(cell);

      for (final segment in bounds) {
        await harness.db.customStatement(
          '''
INSERT INTO visited_cell_bounds (
  res, cell_id, segment, min_lat_e5, max_lat_e5, min_lon_e5, max_lon_e5
) VALUES (?, ?, ?, ?, ?, ?, ?)
''',
          [
            segment.resolution,
            segment.cellId,
            segment.segment,
            segment.minLatE5,
            segment.maxLatE5,
            segment.minLonE5,
            segment.maxLonE5,
          ],
        );
      }

      await harness.db.customStatement(
        '''
INSERT INTO visits_daily (
  res, cell_id, day_yyyy_mmdd, hour_mask, first_ts, last_ts, samples, lat_e5, lon_e5
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
''',
        [
          kBaseH3Resolution,
          harness.h3.encodeCellId(cell),
          _dayKey(now),
          1,
          1,
          1,
          1,
          0,
          0,
        ],
      );

      final dailyOverlay = await harness.repository.loadOverlay(
        bounds: const VisitedGridBounds(
          north: 1,
          south: 0,
          east: 1,
          west: 0,
        ),
        zoom: 16,
        timeFilter: VisitedTimeFilter.today,
      );
      final allTimeOverlay = await harness.repository.loadOverlay(
        bounds: const VisitedGridBounds(
          north: 1,
          south: 0,
          east: 1,
          west: 0,
        ),
        zoom: 16,
        timeFilter: VisitedTimeFilter.allTime,
      );

      expect(dailyOverlay.polygons, hasLength(1));
      expect(allTimeOverlay.polygons, isEmpty);

      await _tearDownHarness(harness);
    });

    test('Uses lifetime table for all-time filters', () async {
      final now = DateTime(2024, 1, 2, 12);
      final harness = await _buildHarness(nowProvider: () => now);
      final cell = harness.h3.fakeCell(
        latitude: 1,
        longitude: 1,
        resolution: kBaseH3Resolution,
      );
      final bounds = harness.h3.cellBounds(cell);

      for (final segment in bounds) {
        await harness.db.customStatement(
          '''
INSERT INTO visited_cell_bounds (
  res, cell_id, segment, min_lat_e5, max_lat_e5, min_lon_e5, max_lon_e5
) VALUES (?, ?, ?, ?, ?, ?, ?)
''',
          [
            segment.resolution,
            segment.cellId,
            segment.segment,
            segment.minLatE5,
            segment.maxLatE5,
            segment.minLonE5,
            segment.maxLonE5,
          ],
        );
      }

      await harness.db.customStatement(
        '''
INSERT INTO visits_lifetime (
  res, cell_id, first_ts, last_ts, samples, days_visited, lat_e5, lon_e5
) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
''',
        [
          kBaseH3Resolution,
          harness.h3.encodeCellId(cell),
          1,
          1,
          1,
          1,
          0,
          0,
        ],
      );

      final allTimeOverlay = await harness.repository.loadOverlay(
        bounds: const VisitedGridBounds(
          north: 1,
          south: 0,
          east: 1,
          west: 0,
        ),
        zoom: 16,
        timeFilter: VisitedTimeFilter.allTime,
      );
      final dailyOverlay = await harness.repository.loadOverlay(
        bounds: const VisitedGridBounds(
          north: 1,
          south: 0,
          east: 1,
          west: 0,
        ),
        zoom: 16,
        timeFilter: VisitedTimeFilter.today,
      );

      expect(allTimeOverlay.polygons, hasLength(1));
      expect(dailyOverlay.polygons, isEmpty);

      await _tearDownHarness(harness);
    });

    test('Returns polygon boundaries for visited cells', () async {
      final harness = await _buildHarness();
      final cell = harness.h3.fakeCell(
        latitude: 1,
        longitude: 1,
        resolution: kBaseH3Resolution,
      );
      final boundary = <LatLng>[
        const LatLng(1, 1),
        const LatLng(1, 2),
        const LatLng(2, 2),
      ];
      harness.h3.setBoundary(cell, boundary);
      harness.h3.polygonCellsByResolution[kBaseH3Resolution] = [cell];

      await harness.dao.upsertVisit(
        cells: [
          VisitedGridCell(
            resolution: kBaseH3Resolution,
            cellId: harness.h3.encodeCellId(cell),
          ),
        ],
        cellBounds: harness.h3.cellBounds(cell),
        day: 20240101,
        hourMask: 1,
        epochSeconds: 100,
        latE5: 100000,
        lonE5: 200000,
        baseResolution: kBaseH3Resolution,
        baseCellId: harness.h3.encodeCellId(cell),
        baseCellAreaM2: 50,
      );

      final overlay = await harness.repository.loadOverlay(
        bounds: const VisitedGridBounds(
          north: 1,
          south: 0,
          east: 1,
          west: 0,
        ),
        zoom: 16,
        timeFilter: VisitedTimeFilter.allTime,
      );

      expect(overlay.polygons, hasLength(1));
      expect(overlay.polygons.first.outer, boundary);
      expect(harness.h3.cellBoundaryCalls, 2);

      await _tearDownHarness(harness);
    });
  });
}
