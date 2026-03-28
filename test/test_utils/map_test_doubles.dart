import 'dart:async';

import 'package:explored/features/location/data/models/history_export_result.dart';
import 'package:explored/features/location/data/models/lat_lng_sample.dart';
import 'package:explored/features/location/data/models/location_permission_level.dart';
import 'package:explored/features/location/data/repositories/location_history_repository.dart';
import 'package:explored/features/location/data/repositories/location_updates_repository.dart';
import 'package:explored/features/map/data/models/map_tile_source.dart';
import 'package:explored/features/map/data/repositories/map_repository.dart';
import 'package:explored/features/map/data/services/map_attribution_service.dart';
import 'package:explored/features/map/data/services/map_tile_service.dart';
import 'package:explored/features/permissions/data/models/app_permission.dart';
import 'package:explored/features/permissions/data/repositories/permissions_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

class TestTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MemoryImage(TileProvider.transparentImage);
  }
}

class FakeMapTileService implements MapTileService {
  @override
  MapTileSource getTileSource() {
    return MapTileSource(
      urlTemplate: 'https://example.com/{z}/{x}/{y}.png',
      subdomains: ['a'],
      userAgentPackageName: 'com.explored.test',
      tileProvider: TestTileProvider(),
    );
  }
}

class FakeMapAttributionService implements MapAttributionService {
  bool opened = false;

  @override
  Future<void> openAttribution() async {
    opened = true;
  }
}

class FakeLocationUpdatesRepository implements LocationUpdatesRepository {
  FakeLocationUpdatesRepository({
    this.permissionLevel = LocationPermissionLevel.foreground,
    this.serviceEnabled = true,
    this.notificationRequired = false,
    this.notificationGranted = true,
    this.requiresBackgroundPermissionFlag = false,
  });

  final StreamController<LatLngSample> _controller =
      StreamController<LatLngSample>.broadcast();
  bool _isRunning = false;
  LocationPermissionLevel permissionLevel;
  bool serviceEnabled;
  bool notificationRequired;
  bool notificationGranted;
  bool requiresBackgroundPermissionFlag;

  @override
  Stream<LatLngSample> get locationUpdates => _controller.stream;

  @override
  bool get isRunning => _isRunning;

  @override
  Future<void> startTracking() async {
    _isRunning = true;
  }

  @override
  Future<void> stopTracking() async {
    _isRunning = false;
  }

  @override
  Future<void> refreshPermissions() async {}

  @override
  Future<LocationPermissionLevel> checkPermissionLevel() async {
    return permissionLevel;
  }

  @override
  Future<LocationPermissionLevel> requestForegroundPermission() async {
    return permissionLevel;
  }

  @override
  Future<LocationPermissionLevel> requestBackgroundPermission() async {
    return permissionLevel;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return serviceEnabled;
  }

  @override
  Future<bool> isNotificationPermissionGranted() async {
    return notificationGranted;
  }

  @override
  Future<bool> requestNotificationPermission() async {
    return notificationGranted;
  }

  @override
  bool get isNotificationPermissionRequired => notificationRequired;

  @override
  Future<bool> openAppSettings() async {
    return true;
  }

  @override
  Future<bool> openNotificationSettings() async {
    return true;
  }

  @override
  bool get requiresBackgroundPermission => requiresBackgroundPermissionFlag;

  void emit(LatLngSample sample) {
    _controller.add(sample);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

class FakeLocationHistoryRepository implements LocationHistoryRepository {
  final StreamController<List<LatLngSample>> _controller =
      StreamController<List<LatLngSample>>.broadcast();
  final List<LatLngSample> _samples = <LatLngSample>[];
  HistoryExportResult exportResult = const HistoryExportResult.success(
    filePath: 'export.csv',
  );
  HistoryExportResult downloadResult = const HistoryExportResult.success(
    filePath: 'download.csv',
  );

  @override
  Stream<List<LatLngSample>> get historyStream => _controller.stream;

  @override
  List<LatLngSample> get currentSamples => List.unmodifiable(_samples);

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {
    await _controller.close();
  }

  @override
  Future<List<LatLngSample>> addImportedSamples(
    List<LatLngSample> samples,
  ) async {
    _samples.addAll(samples);
    _controller.add(List.unmodifiable(_samples));
    return samples;
  }

  @override
  Future<HistoryManualEditResult> applyManualEdits({
    required List<LatLngSample> insertSamples,
    required Set<String> deleteBaseCellIds,
  }) async {
    _samples.addAll(insertSamples);
    _controller.add(List.unmodifiable(_samples));
    return HistoryManualEditResult(
      insertedSamples: insertSamples,
      deletedSamples: deleteBaseCellIds.length,
    );
  }

  @override
  Future<HistoryExportResult> exportHistory() async {
    return exportResult;
  }

  @override
  Future<HistoryExportResult> downloadHistory() async {
    return downloadResult;
  }
}

class FakePermissionsRepository implements PermissionsRepository {
  @override
  Future<List<AppPermissionStatus>> fetchPermissions() async {
    return const [];
  }

  @override
  Future<void> openPermissionSettings(AppPermissionType type) async {}

  @override
  Future<void> requestInitialPermissionsIfNeeded() async {}

  @override
  Future<void> requestPermission(AppPermissionType type) async {}
}

MapRepository buildMapRepository() {
  return MapRepository(
    tileService: FakeMapTileService(),
    attributionService: FakeMapAttributionService(),
  );
}

LatLngSample buildSample({
  required double latitude,
  required double longitude,
  DateTime? timestamp,
  LatLngSampleSource source = LatLngSampleSource.live,
}) {
  return LatLngSample(
    latitude: latitude,
    longitude: longitude,
    timestamp: timestamp ?? DateTime(2024, 1, 1),
    source: source,
  );
}
