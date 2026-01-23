import 'dart:async';

import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/location/data/models/lat_lng_sample.dart';
import 'package:explored/features/location/data/models/history_export_result.dart';
import 'package:explored/features/location/data/models/location_permission_level.dart';
import 'package:explored/features/location/data/repositories/location_history_repository.dart';
import 'package:explored/features/location/data/repositories/location_updates_repository.dart';
import 'package:explored/features/location/data/services/location_history_database.dart';
import 'package:explored/features/location/data/services/location_history_export_service.dart';

class FakeLocationUpdatesRepository implements LocationUpdatesRepository {
  final StreamController<LatLngSample> _controller =
      StreamController<LatLngSample>.broadcast();

  @override
  Stream<LatLngSample> get locationUpdates => _controller.stream;

  @override
  bool get isRunning => false;

  @override
  Future<void> startTracking() async {}

  @override
  Future<void> stopTracking() async {}

  @override
  Future<void> refreshPermissions() async {}

  @override
  Future<LocationPermissionLevel> checkPermissionLevel() async {
    return LocationPermissionLevel.foreground;
  }

  @override
  Future<LocationPermissionLevel> requestForegroundPermission() async {
    return LocationPermissionLevel.foreground;
  }

  @override
  Future<LocationPermissionLevel> requestBackgroundPermission() async {
    return LocationPermissionLevel.background;
  }

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<bool> isNotificationPermissionGranted() async => true;

  @override
  Future<bool> requestNotificationPermission() async => true;

  @override
  bool get isNotificationPermissionRequired => false;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openNotificationSettings() async => true;

  @override
  bool get requiresBackgroundPermission => false;

  void emit(LatLngSample sample) {
    _controller.add(sample);
  }
}

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

class TestLocationHistoryExportService extends LocationHistoryExportService {
  TestLocationHistoryExportService({
    required LocationHistoryDao historyDao,
  }) : super(
          historyDao: historyDao,
          pathProvider: _NoopPathProviderClient(),
          shareClient: _NoopShareClient(),
          fileSaveClient: _NoopFileSaveClient(),
        );

  int exportCalls = 0;
  int downloadCalls = 0;

  @override
  Future<HistoryExportResult> exportHistory() async {
    exportCalls += 1;
    return const HistoryExportResult.success(filePath: 'export.csv');
  }

  @override
  Future<HistoryExportResult> downloadHistory() async {
    downloadCalls += 1;
    return const HistoryExportResult.success(filePath: 'download.csv');
  }
}

LocationHistoryDatabase _buildTestDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return LocationHistoryDatabase(executor: NativeDatabase.memory());
}

void main() {
  test('captures live samples and deduplicates by timestamp and coords',
      () async {
    final updatesRepository = FakeLocationUpdatesRepository();
    final db = _buildTestDb();
    final exportService =
        TestLocationHistoryExportService(historyDao: db.locationHistoryDao);
    final historyRepository = DefaultLocationHistoryRepository(
      locationUpdatesRepository: updatesRepository,
      historyDao: db.locationHistoryDao,
      exportService: exportService,
    );

    await historyRepository.start();

    final sample = LatLngSample(
      latitude: 42.0,
      longitude: 23.0,
      timestamp: DateTime.utc(2024, 1, 1),
    );
    updatesRepository.emit(sample);
    updatesRepository.emit(sample);

    final history = await historyRepository.historyStream.first;
    expect(history.length, 1);
    expect(history.first.latitude, 42.0);

    final persisted = await db.locationHistoryDao.fetchAllSamples();
    expect(persisted.length, 1);

    await historyRepository.dispose();
    await db.close();
  });

  test('addImportedSamples merges and returns only new samples', () async {
    final updatesRepository = FakeLocationUpdatesRepository();
    final db = _buildTestDb();
    final exportService =
        TestLocationHistoryExportService(historyDao: db.locationHistoryDao);
    final historyRepository = DefaultLocationHistoryRepository(
      locationUpdatesRepository: updatesRepository,
      historyDao: db.locationHistoryDao,
      exportService: exportService,
    );

    final sampleA = LatLngSample(
      latitude: 42.0,
      longitude: 23.0,
      timestamp: DateTime.utc(2024, 1, 1),
      source: LatLngSampleSource.imported,
    );
    final sampleB = LatLngSample(
      latitude: 42.0001,
      longitude: 23.0001,
      timestamp: DateTime.utc(2024, 1, 2),
      source: LatLngSampleSource.imported,
    );

    final added = await historyRepository.addImportedSamples(
      [sampleA, sampleA, sampleB],
    );

    expect(added.length, 2);
    expect(historyRepository.currentSamples.length, 2);

    final persisted = await db.locationHistoryDao.fetchAllSamples();
    expect(persisted.length, 2);

    await historyRepository.dispose();
    await db.close();
  });

  test('start loads persisted samples into memory', () async {
    final updatesRepository = FakeLocationUpdatesRepository();
    final db = _buildTestDb();
    await db.locationHistoryDao.insertSamples(
      [
        LatLngSample(
          latitude: 1.23,
          longitude: 4.56,
          timestamp: DateTime.utc(2024, 1, 3),
        ),
      ],
    );
    final exportService =
        TestLocationHistoryExportService(historyDao: db.locationHistoryDao);
    final historyRepository = DefaultLocationHistoryRepository(
      locationUpdatesRepository: updatesRepository,
      historyDao: db.locationHistoryDao,
      exportService: exportService,
    );

    await historyRepository.start();

    expect(historyRepository.currentSamples.length, 1);
    expect(historyRepository.currentSamples.first.latitude, 1.23);

    await historyRepository.dispose();
    await db.close();
  });

  test('exportHistory delegates to the export service', () async {
    final updatesRepository = FakeLocationUpdatesRepository();
    final db = _buildTestDb();
    final exportService =
        TestLocationHistoryExportService(historyDao: db.locationHistoryDao);
    final historyRepository = DefaultLocationHistoryRepository(
      locationUpdatesRepository: updatesRepository,
      historyDao: db.locationHistoryDao,
      exportService: exportService,
    );

    await historyRepository.exportHistory();

    expect(exportService.exportCalls, 1);

    await historyRepository.dispose();
    await db.close();
  });

  test('downloadHistory delegates to the export service', () async {
    final updatesRepository = FakeLocationUpdatesRepository();
    final db = _buildTestDb();
    final exportService =
        TestLocationHistoryExportService(historyDao: db.locationHistoryDao);
    final historyRepository = DefaultLocationHistoryRepository(
      locationUpdatesRepository: updatesRepository,
      historyDao: db.locationHistoryDao,
      exportService: exportService,
    );

    await historyRepository.downloadHistory();

    expect(exportService.downloadCalls, 1);

    await historyRepository.dispose();
    await db.close();
  });

  test('exportHistory syncs persisted rows when history is ahead of storage',
      () async {
    final updatesRepository = FakeLocationUpdatesRepository();
    final db = _buildTestDb();
    final exportService =
        TestLocationHistoryExportService(historyDao: db.locationHistoryDao);
    final historyRepository = DefaultLocationHistoryRepository(
      locationUpdatesRepository: updatesRepository,
      historyDao: db.locationHistoryDao,
      exportService: exportService,
    );

    await historyRepository.start();
    await historyRepository.addImportedSamples(
      [
        LatLngSample(
          latitude: 42.0,
          longitude: 23.0,
          timestamp: DateTime.utc(2024, 1, 1),
          source: LatLngSampleSource.imported,
        ),
        LatLngSample(
          latitude: 42.1,
          longitude: 23.1,
          timestamp: DateTime.utc(2024, 1, 2),
          source: LatLngSampleSource.imported,
        ),
      ],
    );

    await db.customStatement('DELETE FROM location_samples');
    expect(await db.locationHistoryDao.fetchSampleCount(), 0);

    await historyRepository.exportHistory();

    expect(await db.locationHistoryDao.fetchSampleCount(), 2);

    await historyRepository.dispose();
    await db.close();
  });
}
