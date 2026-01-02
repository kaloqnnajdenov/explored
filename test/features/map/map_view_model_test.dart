import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/location/data/models/location_notification.dart';
import 'package:explored/features/location/data/models/location_permission_level.dart';
import 'package:explored/features/location/data/models/location_status.dart';
import 'package:explored/features/location/data/models/location_tracking_mode.dart';
import 'package:explored/features/location/data/models/location_update.dart';
import 'package:explored/features/location/data/repositories/location_repository.dart';
import 'package:explored/features/location/data/services/background_location_service.dart';
import 'package:explored/features/location/data/services/foreground_location_service.dart';
import 'package:explored/features/location/data/services/location_permission_service.dart';
import 'package:explored/features/location/data/services/location_storage_service.dart';
import 'package:explored/features/map/data/models/map_tile_source.dart';
import 'package:explored/features/map/data/repositories/map_repository.dart';
import 'package:explored/features/map/data/services/map_attribution_service.dart';
import 'package:explored/features/map/data/services/map_tile_service.dart';
import 'package:explored/features/map/view_model/map_view_model.dart';

class FakeMapTileService implements MapTileService {
  @override
  MapTileSource getTileSource() {
    return const MapTileSource(
      urlTemplate: 'https://example.com/{z}/{x}/{y}.png',
      subdomains: ['a'],
      userAgentPackageName: 'com.explored.test',
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

class FakeForegroundLocationService implements ForegroundLocationService {
  final StreamController<LocationUpdate> _controller =
      StreamController<LocationUpdate>.broadcast();
  bool started = false;

  @override
  Stream<LocationUpdate> get locationUpdates => _controller.stream;

  @override
  Future<void> startLocationUpdates({double? distanceFilter}) async {
    started = true;
  }

  @override
  Future<void> stopLocationUpdates() async {
    started = false;
  }
}

class FakeBackgroundTrackingService implements BackgroundTrackingService {
  final StreamController<LocationUpdate> _controller =
      StreamController<LocationUpdate>.broadcast();
  bool started = false;
  int? configuredInterval;
  LocationNotification? configuredNotification;

  @override
  Stream<LocationUpdate> get locationUpdates => _controller.stream;

  @override
  Future<void> configureAndroidNotification(
    LocationNotification notification,
  ) async {
    configuredNotification = notification;
  }

  @override
  Future<void> configureAndroidInterval(int intervalMs) async {
    configuredInterval = intervalMs;
  }

  @override
  Future<void> startLocationService({
    double? distanceFilter,
    bool? forceAndroidLocationManager,
  }) async {
    started = true;
  }

  @override
  Future<void> stopLocationService() async {
    started = false;
  }
}

class FakeLocationPermissionService implements LocationPermissionService {
  FakeLocationPermissionService({
    required this.permissionLevel,
    required this.serviceEnabled,
    required this.notificationGranted,
    required this.notificationRequired,
  });

  LocationPermissionLevel permissionLevel;
  LocationPermissionLevel? _nextForegroundResult;
  LocationPermissionLevel? _nextBackgroundResult;
  bool serviceEnabled;
  bool notificationGranted;
  bool notificationRequired;

  int foregroundRequestCount = 0;
  int backgroundRequestCount = 0;

  void queueForegroundResult(LocationPermissionLevel level) {
    _nextForegroundResult = level;
  }

  void queueBackgroundResult(LocationPermissionLevel level) {
    _nextBackgroundResult = level;
  }

  @override
  Future<LocationPermissionLevel> checkPermissionLevel() async {
    return permissionLevel;
  }

  @override
  Future<LocationPermissionLevel> requestForegroundPermission() async {
    foregroundRequestCount += 1;
    if (_nextForegroundResult != null) {
      permissionLevel = _nextForegroundResult!;
      _nextForegroundResult = null;
    }
    return permissionLevel;
  }

  @override
  Future<LocationPermissionLevel> requestBackgroundPermission() async {
    backgroundRequestCount += 1;
    if (_nextBackgroundResult != null) {
      permissionLevel = _nextBackgroundResult!;
      _nextBackgroundResult = null;
    }
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
  bool get isNotificationPermissionRequired {
    return notificationRequired;
  }

  @override
  Future<bool> openAppSettings() async {
    return true;
  }
}

class FakeLocationStorageService implements LocationStorageService {
  LocationUpdate? lastLocation;

  @override
  Future<void> saveLastLocation(LocationUpdate location) async {
    lastLocation = location;
  }

  @override
  Future<LocationUpdate?> loadLastLocation() async {
    return lastLocation;
  }
}

void main() {
  test(
    'Background permission request clears requesting status while foreground tracking stays active',
    () async {
      final permissionService = FakeLocationPermissionService(
        permissionLevel: LocationPermissionLevel.denied,
        serviceEnabled: true,
        notificationGranted: true,
        notificationRequired: false,
      );
      final locationRepository = LocationRepository(
        foregroundLocationService: FakeForegroundLocationService(),
        backgroundLocationService: FakeBackgroundTrackingService(),
        permissionService: permissionService,
        storageService: FakeLocationStorageService(),
      );
      final mapRepository = MapRepository(
        tileService: FakeMapTileService(),
        attributionService: FakeMapAttributionService(),
      );
      final viewModel = MapViewModel(
        mapRepository: mapRepository,
        locationRepository: locationRepository,
      );

      await viewModel.initialize();

      permissionService.queueForegroundResult(LocationPermissionLevel.foreground);
      await viewModel.requestForegroundPermission();

      expect(
        viewModel.state.locationTracking.trackingMode,
        LocationTrackingMode.foreground,
      );
      expect(
        viewModel.state.locationTracking.status,
        LocationStatus.trackingStartedForeground,
      );

      permissionService.queueBackgroundResult(LocationPermissionLevel.foreground);
      await viewModel.requestBackgroundPermission();

      expect(
        viewModel.state.locationTracking.status,
        LocationStatus.trackingStartedForeground,
      );
      expect(viewModel.state.locationTracking.isActionInProgress, false);

      viewModel.dispose();
    },
  );
}
