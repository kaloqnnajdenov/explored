import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:explored/constants.dart';
import 'package:explored/features/location/data/models/lat_lng_sample.dart';
import 'package:explored/features/location/data/services/location_history_database.dart';
import 'package:explored/features/visited_grid/data/models/explored_area_log_entry.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_config.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_stats.dart';
import 'package:explored/features/visited_grid/data/repositories/visited_grid_repository.dart';
import 'package:explored/features/visited_grid/data/services/explored_area_logger.dart';
import 'package:explored/features/visited_grid/data/services/fog_of_war_tile_cache_service.dart';
import 'package:explored/features/visited_grid/data/services/visited_grid_database.dart';

import 'visited_grid_test_utils.dart';

class TestExploredAreaLogger implements ExploredAreaLogger {
  @override
  void log(ExploredAreaLogEntry entry) {}
}

class _FakePathProvider implements TileCachePathProvider {
  @override
  Future<Directory> getTemporaryDirectory() async {
    return Directory.systemTemp;
  }
}

class TestTileCacheService extends FogOfWarTileCacheService {
  TestTileCacheService() : super(pathProvider: _FakePathProvider());

  int clearCalls = 0;

  @override
  Future<void> clear() async {
    clearCalls += 1;
  }
}

class _RebuildHarness {
  _RebuildHarness({
    required this.gridDb,
    required this.historyDb,
    required this.repository,
    required this.cacheService,
  });

  final VisitedGridDatabase gridDb;
  final LocationHistoryDatabase historyDb;
  final DefaultVisitedGridRepository repository;
  final TestTileCacheService cacheService;
}

Future<_RebuildHarness> _buildHarness({
  List<LatLngSample> history = const [],
  VisitedGridConfig config = const VisitedGridConfig(),
  VisitedGridDatabase? gridDb,
  LocationHistoryDatabase? historyDb,
  bool setGridVersion = false,
}) async {
  final grid = gridDb ?? buildTestDb();
  final historyStore = historyDb ?? buildHistoryTestDb();
  if (history.isNotEmpty) {
    await historyStore.locationHistoryDao.insertSamples(history);
  }
  if (setGridVersion) {
    await grid.visitedGridDao.setGridVersion(config.baseResolution);
  }
  final cacheService = TestTileCacheService();
  final repository = DefaultVisitedGridRepository(
    locationUpdatesRepository: TestLocationUpdatesRepository(),
    visitedGridDao: grid.visitedGridDao,
    locationHistoryDao: historyStore.locationHistoryDao,
    h3Service: FakeVisitedGridH3Service(),
    exploredAreaLogger: TestExploredAreaLogger(),
    overlayCacheService: cacheService,
    appVersion: '1.0.0',
    schemaVersion: grid.schemaVersion,
    config: config,
  );
  await repository.start();
  return _RebuildHarness(
    gridDb: grid,
    historyDb: historyStore,
    repository: repository,
    cacheService: cacheService,
  );
}

Future<void> _tearDownHarness(_RebuildHarness harness) async {
  await harness.repository.dispose();
  await harness.gridDb.close();
  await harness.historyDb.close();
}

LatLngSample _sample({
  required double latitude,
  required double longitude,
  required DateTime timestamp,
  LatLngSampleSource source = LatLngSampleSource.live,
  bool isInterpolated = false,
}) {
  return LatLngSample(
    latitude: latitude,
    longitude: longitude,
    timestamp: timestamp,
    source: source,
    isInterpolated: isInterpolated,
  );
}

void main() {
  test('Rebuild enforces base resolution and clears overlay cache', () async {
    final harness = await _buildHarness(
      history: [
        _sample(
          latitude: 1,
          longitude: 1,
          timestamp: DateTime(2024, 1, 1, 10),
        ),
        _sample(
          latitude: 2,
          longitude: 2,
          timestamp: DateTime(2024, 1, 2, 10),
        ),
      ],
    );

    expect(harness.cacheService.clearCalls, 1);

    final lifetimeRows =
        await harness.gridDb.select(harness.gridDb.visitsLifetime).get();
    final dailyRows =
        await harness.gridDb.select(harness.gridDb.visitsDaily).get();
    final lifetimeRes =
        lifetimeRows.map((row) => row.res).toSet();
    final dailyRes = dailyRows.map((row) => row.res).toSet();
    expect(lifetimeRes.contains(kBaseH3Resolution), isTrue);
    expect(dailyRes.contains(kBaseH3Resolution), isTrue);
    expect(
      lifetimeRes.any((res) => res > kBaseH3Resolution),
      isFalse,
    );
    expect(
      dailyRes.any((res) => res > kBaseH3Resolution),
      isFalse,
    );

    await _tearDownHarness(harness);
  });

  test('Rebuild includes all sources without double-counting', () async {
    final harness = await _buildHarness(
      history: [
        _sample(
          latitude: 1,
          longitude: 1,
          timestamp: DateTime(2024, 1, 1, 10),
          source: LatLngSampleSource.live,
        ),
        _sample(
          latitude: 2,
          longitude: 2,
          timestamp: DateTime(2024, 1, 1, 11),
          source: LatLngSampleSource.imported,
        ),
        _sample(
          latitude: 3,
          longitude: 3,
          timestamp: DateTime(2024, 1, 1, 12),
          source: LatLngSampleSource.manual,
        ),
        _sample(
          latitude: 1,
          longitude: 1,
          timestamp: DateTime(2024, 1, 1, 13),
          source: LatLngSampleSource.imported,
        ),
      ],
    );

    final stats = await harness.repository.fetchStats();
    expect(stats.cellCount, 3);
    expect(stats.totalAreaM2, closeTo(150, 0.0001));

    await _tearDownHarness(harness);
  });

  test('Interpolated samples contribute to rebuild', () async {
    final harness = await _buildHarness(
      history: [
        _sample(
          latitude: 4,
          longitude: 4,
          timestamp: DateTime(2024, 1, 2, 10),
          isInterpolated: true,
        ),
      ],
    );

    final stats = await harness.repository.fetchStats();
    expect(stats.cellCount, 1);
    expect(stats.totalAreaM2, closeTo(50, 0.0001));

    await _tearDownHarness(harness);
  });

  test('Rebuild is idempotent', () async {
    final gridDb = buildTestDb();
    final historyDb = buildHistoryTestDb();
    await historyDb.locationHistoryDao.insertSamples(
      [
        _sample(
          latitude: 1,
          longitude: 1,
          timestamp: DateTime(2024, 1, 1, 10),
        ),
        _sample(
          latitude: 2,
          longitude: 2,
          timestamp: DateTime(2024, 1, 2, 10),
        ),
      ],
    );

    final first = await _buildHarness(
      gridDb: gridDb,
      historyDb: historyDb,
    );
    final stats1 = await first.repository.fetchStats();
    final cells1 = await gridDb.visitedGridDao
        .fetchLifetimeCellIds(kBaseH3Resolution);
    await first.repository.dispose();

    await gridDb.visitedGridDao.setGridVersion(0);
    final second = await _buildHarness(
      gridDb: gridDb,
      historyDb: historyDb,
    );
    final stats2 = await second.repository.fetchStats();
    final cells2 = await gridDb.visitedGridDao
        .fetchLifetimeCellIds(kBaseH3Resolution);

    expect(stats2.totalAreaM2, stats1.totalAreaM2);
    expect(stats2.cellCount, stats1.cellCount);
    expect(cells2.toSet(), cells1.toSet());

    await second.repository.dispose();
    await gridDb.close();
    await historyDb.close();
  });

  test('Date range queries dedupe and match all-time totals', () async {
    final harness = await _buildHarness(
      history: [
        _sample(
          latitude: 10,
          longitude: 10,
          timestamp: DateTime(2024, 1, 1, 10),
          source: LatLngSampleSource.imported,
        ),
        _sample(
          latitude: 10,
          longitude: 10,
          timestamp: DateTime(2024, 1, 1, 10, 30),
          source: LatLngSampleSource.imported,
        ),
        _sample(
          latitude: 20,
          longitude: 20,
          timestamp: DateTime(2024, 1, 3, 9),
          source: LatLngSampleSource.imported,
        ),
      ],
    );

    final dayOneArea = await harness.repository.fetchExploredAreaKm2(
      start: DateTime(2024, 1, 1),
      end: DateTime(2024, 1, 1),
    );
    final rangeArea = await harness.repository.fetchExploredAreaKm2(
      start: DateTime(2024, 1, 1),
      end: DateTime(2024, 1, 3),
    );
    final allTimeArea = await harness.repository.fetchExploredAreaKm2();

    expect(dayOneArea, closeTo(0.00005, 0.0000001));
    expect(rangeArea, closeTo(0.0001, 0.0000001));
    expect(allTimeArea, closeTo(0.0001, 0.0000001));

    await _tearDownHarness(harness);
  });

  test('Stats reconciliation corrects stored mismatches', () async {
    final gridDb = buildTestDb();
    final historyDb = buildHistoryTestDb();
    await historyDb.locationHistoryDao.insertSamples(
      [
        _sample(
          latitude: 1,
          longitude: 1,
          timestamp: DateTime(2024, 1, 1, 10),
        ),
      ],
    );

    final rebuilt = await _buildHarness(
      gridDb: gridDb,
      historyDb: historyDb,
    );
    await rebuilt.repository.dispose();

    await gridDb.customStatement(
      'UPDATE visited_grid_stats SET total_area_m2 = 0, cell_count = 0',
    );
    await gridDb.visitedGridDao.setGridVersion(kBaseH3Resolution);

    final repository = DefaultVisitedGridRepository(
      locationUpdatesRepository: TestLocationUpdatesRepository(),
      visitedGridDao: gridDb.visitedGridDao,
      locationHistoryDao: historyDb.locationHistoryDao,
      h3Service: FakeVisitedGridH3Service(),
      exploredAreaLogger: TestExploredAreaLogger(),
      overlayCacheService: TestTileCacheService(),
      appVersion: '1.0.0',
      schemaVersion: gridDb.schemaVersion,
    );
    await repository.start();

    final stats = await repository.fetchStats();
    expect(stats.totalAreaM2, closeTo(50, 0.0001));
    expect(stats.cellCount, 1);

    await repository.dispose();
    await gridDb.close();
    await historyDb.close();
  });
}
