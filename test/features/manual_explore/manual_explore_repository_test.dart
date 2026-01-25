import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:explored/constants.dart';
import 'package:explored/features/location/data/models/lat_lng_sample.dart';
import 'package:explored/features/location/data/repositories/location_history_repository.dart';
import 'package:explored/features/location/data/repositories/location_updates_repository.dart';
import 'package:explored/features/location/data/services/location_history_database.dart';
import 'package:explored/features/location/data/services/location_history_export_service.dart';
import 'package:explored/features/location/data/services/location_history_h3_service.dart';
import 'package:explored/features/manual_explore/data/repositories/manual_explore_repository.dart';
import 'package:explored/features/visited_grid/data/models/explored_area_log_entry.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_config.dart';
import 'package:explored/features/visited_grid/data/repositories/visited_grid_repository.dart';
import 'package:explored/features/visited_grid/data/services/explored_area_logger.dart';
import 'package:explored/features/visited_grid/data/services/visited_grid_database.dart';
import 'package:explored/features/visited_grid/data/services/visited_grid_h3_service.dart';

import '../visited_grid/visited_grid_test_utils.dart';

class _NoopPathProviderClient implements PathProviderClient {
  @override
  Future<Directory> getTemporaryDirectory() async {
    return Directory.systemTemp;
  }
}

class _NoopShareClient implements ShareClient {
  @override
  Future<void> shareFile({
    required String path,
    required String mimeType,
  }) async {}
}

class _NoopFileSaveClient implements FileSaveClient {
  @override
  Future<String?> saveFile({
    required String fileName,
    required List<String> allowedExtensions,
    required Uint8List bytes,
  }) async {
    return null;
  }
}

class _NoopExportService extends LocationHistoryExportService {
  _NoopExportService({required super.historyDao})
      : super(
          pathProvider: _NoopPathProviderClient(),
          shareClient: _NoopShareClient(),
          fileSaveClient: _NoopFileSaveClient(),
        );
}

class _NoopExploredAreaLogger implements ExploredAreaLogger {
  @override
  void log(ExploredAreaLogEntry entry) {}
}

class _Harness {
  _Harness({
    required this.historyDb,
    required this.gridDb,
    required this.historyRepository,
    required this.visitedGridRepository,
    required this.manualRepository,
    required this.h3Service,
    required this.locationUpdatesRepository,
  });

  final LocationHistoryDatabase historyDb;
  final VisitedGridDatabase gridDb;
  final DefaultLocationHistoryRepository historyRepository;
  final DefaultVisitedGridRepository visitedGridRepository;
  final DefaultManualExploreRepository manualRepository;
  final VisitedGridH3Service h3Service;
  final LocationUpdatesRepository locationUpdatesRepository;
}

Future<_Harness> _buildHarness({
  VisitedGridConfig config = const VisitedGridConfig(),
}) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final fakeH3 = FakeVisitedGridH3Service();
  final resolver = (double lat, double lon) {
    final cell = fakeH3.cellForLatLng(
      latitude: lat,
      longitude: lon,
      resolution: kBaseH3Resolution,
    );
    return fakeH3.encodeCellId(cell);
  };
  final historyDb = LocationHistoryDatabase(
    executor: NativeDatabase.memory(),
    h3Service: LocationHistoryH3Service(cellIdResolver: resolver),
  );
  final gridDb = VisitedGridDatabase(executor: NativeDatabase.memory());
  final updatesRepository = TestLocationUpdatesRepository();
  final historyDao = historyDb.locationHistoryDao;
  final historyRepository = DefaultLocationHistoryRepository(
    locationUpdatesRepository: updatesRepository,
    historyDao: historyDao,
    exportService: _NoopExportService(historyDao: historyDao),
    h3Service: LocationHistoryH3Service(cellIdResolver: resolver),
  );
  final h3Service = fakeH3;
  final visitedGridRepository = DefaultVisitedGridRepository(
    locationUpdatesRepository: updatesRepository,
    visitedGridDao: gridDb.visitedGridDao,
    locationHistoryDao: historyDao,
    h3Service: h3Service,
    exploredAreaLogger: _NoopExploredAreaLogger(),
    appVersion: '1.0.0',
    schemaVersion: gridDb.schemaVersion,
    config: config,
  );
  await visitedGridRepository.start();
  final manualRepository = DefaultManualExploreRepository(
    historyRepository: historyRepository,
    historyDao: historyDao,
    visitedGridRepository: visitedGridRepository,
    h3Service: h3Service,
    config: config,
  );
  return _Harness(
    historyDb: historyDb,
    gridDb: gridDb,
    historyRepository: historyRepository,
    visitedGridRepository: visitedGridRepository,
    manualRepository: manualRepository,
    h3Service: h3Service,
    locationUpdatesRepository: updatesRepository,
  );
}

Future<void> _tearDownHarness(_Harness harness) async {
  await harness.visitedGridRepository.dispose();
  if (harness.locationUpdatesRepository is TestLocationUpdatesRepository) {
    await (harness.locationUpdatesRepository as TestLocationUpdatesRepository)
        .close();
  }
  await harness.historyRepository.dispose();
  await harness.historyDb.close();
  await harness.gridDb.close();
}

String _cellIdFor(
  VisitedGridH3Service h3,
  LatLng position,
) {
  final cell = h3.cellForLatLng(
    latitude: position.latitude,
    longitude: position.longitude,
    resolution: kBaseH3Resolution,
  );
  return h3.encodeCellId(cell);
}

void main() {
  test('tap add inserts centroid and updates visited grid', () async {
    final harness = await _buildHarness();
    final position = const LatLng(37.7749, -122.4194);
    final cellId = harness.manualRepository.cellIdForLatLng(position);
    final timestamp = DateTime(2024, 1, 1, 10, 30).toUtc();

    await harness.manualRepository.applyEdits(
      addCellIds: {cellId},
      deleteCellIds: const {},
      timestampUtc: timestamp,
    );

    final rows = await harness.historyDb.locationHistoryDao.fetchAllSamples();
    expect(rows.length, 1);
    final row = rows.first;
    expect(row.source, LatLngSampleSource.manual);
    expect(row.isInterpolated, isFalse);
    expect(row.h3Base, cellId);

    final center = harness.h3Service
        .cellToGeo(harness.h3Service.decodeCellId(cellId));
    expect(row.latitude, closeTo(center.lat, 1e-6));
    expect(row.longitude, closeTo(center.lon, 1e-6));

    final stats = await harness.visitedGridRepository.fetchStats();
    expect(stats.cellCount, 1);
    expect(stats.totalAreaM2, closeTo(50.0, 0.5));

    final lifetimeRows = await (harness.gridDb
            .select(harness.gridDb.visitsLifetime)
          ..where((tbl) =>
              tbl.res.equals(kBaseH3Resolution) & tbl.cellId.equals(cellId)))
        .get();
    expect(lifetimeRows.length, 1);

    await _tearDownHarness(harness);
  });

  test('add multiple cells inserts one history row per cell', () async {
    final harness = await _buildHarness();
    final cellA = harness.manualRepository
        .cellIdForLatLng(const LatLng(0.0, 0.0));
    final cellB = harness.manualRepository
        .cellIdForLatLng(const LatLng(10.0, 10.0));

    await harness.manualRepository.applyEdits(
      addCellIds: {cellA, cellB},
      deleteCellIds: const {},
      timestampUtc: DateTime.utc(2024, 2, 2),
    );

    final rows = await harness.historyDb.locationHistoryDao.fetchAllSamples();
    expect(rows.length, 2);
    final stats = await harness.visitedGridRepository.fetchStats();
    expect(stats.cellCount, 2);

    await _tearDownHarness(harness);
  });

  test('adding an existing explored cell does not duplicate', () async {
    final harness = await _buildHarness();
    final cellId = harness.manualRepository
        .cellIdForLatLng(const LatLng(1.0, 1.0));
    await harness.historyDb.locationHistoryDao.insertSamples([
      LatLngSample(
        latitude: 1.0,
        longitude: 1.0,
        timestamp: DateTime.utc(2024, 1, 1),
        source: LatLngSampleSource.live,
      ),
    ]);
    await harness.visitedGridRepository.rebuildFromHistory();
    final statsBefore = await harness.visitedGridRepository.fetchStats();

    await harness.manualRepository.applyEdits(
      addCellIds: {cellId},
      deleteCellIds: const {},
      timestampUtc: DateTime.utc(2024, 1, 2),
    );

    final rows = await harness.historyDb.locationHistoryDao.fetchAllSamples();
    expect(rows.length, 1);
    final statsAfter = await harness.visitedGridRepository.fetchStats();
    expect(statsAfter.cellCount, statsBefore.cellCount);
    expect(statsAfter.totalAreaM2, statsBefore.totalAreaM2);

    await _tearDownHarness(harness);
  });

  test('date attribution stores UTC and updates membership tables', () async {
    final harness = await _buildHarness();
    final local = DateTime(2024, 5, 6, 14, 30);
    final cellId = harness.manualRepository
        .cellIdForLatLng(const LatLng(5.0, 5.0));

    await harness.manualRepository.applyEdits(
      addCellIds: {cellId},
      deleteCellIds: const {},
      timestampUtc: local.toUtc(),
    );

    final rows = await harness.historyDb.locationHistoryDao.fetchAllSamples();
    final stored = DateTime.parse(rows.first.timestamp).toLocal();
    expect(stored.year, local.year);
    expect(stored.month, local.month);
    expect(stored.day, local.day);
    expect(stored.hour, local.hour);

    final dailyRows = await (harness.gridDb
            .select(harness.gridDb.visitsDaily)
          ..where((tbl) =>
              tbl.res.equals(kBaseH3Resolution) & tbl.cellId.equals(cellId)))
        .get();
    expect(dailyRows.length, 1);
    final expectedDay = local.year * 10000 + local.month * 100 + local.day;
    expect(dailyRows.first.dayYyyyMmdd, expectedDay);
    expect(dailyRows.first.hourMask, 1 << local.hour);

    await _tearDownHarness(harness);
  });

  test('delete removes all samples in the cell across sources', () async {
    final harness = await _buildHarness();
    final base = const LatLng(2.0, 2.0);
    final cellId = harness.manualRepository.cellIdForLatLng(base);

    await harness.historyDb.locationHistoryDao.insertSamples([
      LatLngSample(
        latitude: base.latitude,
        longitude: base.longitude,
        timestamp: DateTime.utc(2024, 1, 1, 1),
        source: LatLngSampleSource.live,
      ),
      LatLngSample(
        latitude: base.latitude,
        longitude: base.longitude,
        timestamp: DateTime.utc(2024, 1, 1, 2),
        source: LatLngSampleSource.imported,
      ),
      LatLngSample(
        latitude: base.latitude,
        longitude: base.longitude,
        timestamp: DateTime.utc(2024, 1, 1, 3),
        source: LatLngSampleSource.manual,
        isInterpolated: true,
      ),
      LatLngSample(
        latitude: 30.0,
        longitude: 30.0,
        timestamp: DateTime.utc(2024, 1, 1, 4),
        source: LatLngSampleSource.live,
      ),
    ]);
    await harness.visitedGridRepository.rebuildFromHistory();

    await harness.manualRepository.applyEdits(
      addCellIds: const {},
      deleteCellIds: {cellId},
      timestampUtc: DateTime.utc(2024, 1, 2),
    );

    final remaining = await harness.historyDb.locationHistoryDao
        .fetchAllSamples();
    expect(remaining.length, 1);
    expect(remaining.first.latitude, 30.0);

    final lifetimeRows = await (harness.gridDb
            .select(harness.gridDb.visitsLifetime)
          ..where((tbl) =>
              tbl.res.equals(kBaseH3Resolution) & tbl.cellId.equals(cellId)))
        .get();
    expect(lifetimeRows, isEmpty);

    await _tearDownHarness(harness);
  });

  test('delete of non-explored cell is a no-op', () async {
    final harness = await _buildHarness();
    final cellId = harness.manualRepository
        .cellIdForLatLng(const LatLng(12.0, 12.0));
    await harness.historyDb.locationHistoryDao.insertSamples([
      LatLngSample(
        latitude: 0.0,
        longitude: 0.0,
        timestamp: DateTime.utc(2024, 1, 1),
      ),
    ]);
    await harness.visitedGridRepository.rebuildFromHistory();
    final statsBefore = await harness.visitedGridRepository.fetchStats();

    await harness.manualRepository.applyEdits(
      addCellIds: const {},
      deleteCellIds: {cellId},
      timestampUtc: DateTime.utc(2024, 1, 2),
    );

    final rows = await harness.historyDb.locationHistoryDao.fetchAllSamples();
    expect(rows.length, 1);
    final statsAfter = await harness.visitedGridRepository.fetchStats();
    expect(statsAfter.cellCount, statsBefore.cellCount);
    expect(statsAfter.totalAreaM2, statsBefore.totalAreaM2);

    await _tearDownHarness(harness);
  });

  test('delete removes large batches efficiently', () async {
    final harness = await _buildHarness();
    final cellId = harness.manualRepository
        .cellIdForLatLng(const LatLng(8.0, 8.0));

    final samples = <LatLngSample>[];
    for (var i = 0; i < 1500; i += 1) {
      samples.add(
        LatLngSample(
          latitude: 8.0,
          longitude: 8.0,
          timestamp: DateTime.utc(2024, 1, 1, 0, 0, i),
          source: LatLngSampleSource.live,
        ),
      );
    }
    await harness.historyDb.locationHistoryDao.insertSamples(samples);
    await harness.visitedGridRepository.rebuildFromHistory();

    await harness.manualRepository.applyEdits(
      addCellIds: const {},
      deleteCellIds: {cellId},
      timestampUtc: DateTime.utc(2024, 1, 2),
    );

    final remaining = await harness.historyDb.locationHistoryDao
        .fetchAllSamples();
    expect(remaining, isEmpty);

    await _tearDownHarness(harness);
  });

  test('deleting cells updates date-range explored area', () async {
    final harness = await _buildHarness();
    final cellId = _cellIdFor(
      harness.h3Service,
      const LatLng(15.0, 15.0),
    );

    await harness.historyDb.locationHistoryDao.insertSamples([
      LatLngSample(
        latitude: 15.0,
        longitude: 15.0,
        timestamp: DateTime.utc(2024, 1, 1, 10),
      ),
      LatLngSample(
        latitude: 15.0,
        longitude: 15.0,
        timestamp: DateTime.utc(2024, 1, 2, 10),
      ),
    ]);
    await harness.visitedGridRepository.rebuildFromHistory();

    final before = await harness.visitedGridRepository.fetchExploredAreaKm2(
      start: DateTime(2024, 1, 1),
      end: DateTime(2024, 1, 3),
    );
    expect(before, greaterThan(0));

    await harness.manualRepository.applyEdits(
      addCellIds: const {},
      deleteCellIds: {cellId},
      timestampUtc: DateTime.utc(2024, 1, 3),
    );

    final after = await harness.visitedGridRepository.fetchExploredAreaKm2(
      start: DateTime(2024, 1, 1),
      end: DateTime(2024, 1, 3),
    );
    expect(after, 0);

    await _tearDownHarness(harness);
  });

  test('rebuild after add/delete yields correct lifetime set', () async {
    final harness = await _buildHarness();
    final cellA = _cellIdFor(harness.h3Service, const LatLng(2.0, 3.0));
    final cellB = _cellIdFor(harness.h3Service, const LatLng(4.0, 5.0));
    final cellC = _cellIdFor(harness.h3Service, const LatLng(6.0, 7.0));

    await harness.historyDb.locationHistoryDao.insertSamples([
      LatLngSample(
        latitude: 2.0,
        longitude: 3.0,
        timestamp: DateTime.utc(2024, 1, 1),
      ),
      LatLngSample(
        latitude: 4.0,
        longitude: 5.0,
        timestamp: DateTime.utc(2024, 1, 1, 1),
      ),
    ]);
    await harness.visitedGridRepository.rebuildFromHistory();

    await harness.manualRepository.applyEdits(
      addCellIds: {cellC},
      deleteCellIds: {cellA},
      timestampUtc: DateTime.utc(2024, 2, 1),
    );

    final lifetimeRows = await (harness.gridDb
            .select(harness.gridDb.visitsLifetime)
          ..where((tbl) => tbl.res.equals(kBaseH3Resolution)))
        .get();
    final ids = {for (final row in lifetimeRows) row.cellId};
    expect(ids, {cellB, cellC});

    final stats = await harness.visitedGridRepository.fetchStats();
    expect(stats.totalAreaM2, closeTo(100.0, 1.0));

    await _tearDownHarness(harness);
  });

  test('saving with no changes is idempotent', () async {
    final harness = await _buildHarness();
    await harness.historyDb.locationHistoryDao.insertSamples([
      LatLngSample(
        latitude: 1.0,
        longitude: 2.0,
        timestamp: DateTime.utc(2024, 1, 1),
      ),
    ]);
    await harness.visitedGridRepository.rebuildFromHistory();
    final statsBefore = await harness.visitedGridRepository.fetchStats();

    final result = await harness.manualRepository.applyEdits(
      addCellIds: const {},
      deleteCellIds: const {},
      timestampUtc: DateTime.utc(2024, 1, 2),
    );
    expect(result.hasChanges, isFalse);

    final statsAfter = await harness.visitedGridRepository.fetchStats();
    expect(statsAfter.totalAreaM2, statsBefore.totalAreaM2);
    expect(statsAfter.cellCount, statsBefore.cellCount);

    await _tearDownHarness(harness);
  });

  test('adds near antimeridian use correct cell id', () async {
    final harness = await _buildHarness();
    final position = const LatLng(0.0, 179.999);
    final cellId = harness.manualRepository.cellIdForLatLng(position);

    await harness.manualRepository.applyEdits(
      addCellIds: {cellId},
      deleteCellIds: const {},
      timestampUtc: DateTime.utc(2024, 1, 1),
    );

    final rows = await harness.historyDb.locationHistoryDao.fetchAllSamples();
    expect(rows.length, 1);
    expect(rows.first.h3Base, cellId);

    await _tearDownHarness(harness);
  });

  test('add/delete near poles updates history safely', () async {
    final harness = await _buildHarness();
    final position = const LatLng(85.0, 40.0);
    final cellId = harness.manualRepository.cellIdForLatLng(position);

    await harness.manualRepository.applyEdits(
      addCellIds: {cellId},
      deleteCellIds: const {},
      timestampUtc: DateTime.utc(2024, 1, 1),
    );
    await harness.manualRepository.applyEdits(
      addCellIds: const {},
      deleteCellIds: {cellId},
      timestampUtc: DateTime.utc(2024, 1, 2),
    );

    final rows = await harness.historyDb.locationHistoryDao.fetchAllSamples();
    expect(rows, isEmpty);

    await _tearDownHarness(harness);
  });
}
