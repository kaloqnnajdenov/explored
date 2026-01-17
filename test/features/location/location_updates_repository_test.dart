import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/location/data/location_tracking_config.dart';
import 'package:explored/features/location/data/models/lat_lng_sample.dart';
import 'package:explored/features/location/data/models/location_permission_level.dart';
import 'package:explored/features/location/data/repositories/location_updates_repository.dart';
import 'package:explored/features/location/data/services/location_permission_service.dart';
import 'package:explored/features/location/data/services/location_tracking_service.dart';
import 'package:explored/features/location/data/services/platform_info.dart';

class FakePlatformInfo implements PlatformInfo {
  FakePlatformInfo({
    required this.isAndroid,
    required this.isIOS,
    this.androidSdkInt,
  });

  @override
  final bool isAndroid;

  @override
  final bool isIOS;

  @override
  final int? androidSdkInt;
}

class FakeTrackingService implements LocationTrackingService {
  final Stream<LatLngSample> _stream =
      const Stream<LatLngSample>.empty();

  int startCalls = 0;
  int stopCalls = 0;
  bool _isRunning = false;

  @override
  Stream<LatLngSample> get stream => _stream;

  @override
  bool get isRunning => _isRunning;

  @override
  Future<void> start() async {
    startCalls += 1;
    _isRunning = true;
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
    _isRunning = false;
  }
}

class FakeLocationPermissionService implements LocationPermissionService {
  FakeLocationPermissionService({
    required this.permissionLevel,
    this.serviceEnabled = true,
    this.notificationRequired = false,
    this.notificationGranted = true,
  });

  LocationPermissionLevel permissionLevel;
  bool serviceEnabled;
  bool notificationRequired;
  bool notificationGranted;

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
}

void main() {
  group('DefaultLocationUpdatesRepository', () {
    late DebugPrintCallback originalDebugPrint;
    late List<String> logs;

    setUp(() {
      logs = <String>[];
      originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) {
          logs.add(message);
        }
      };
    });

    tearDown(() {
      debugPrint = originalDebugPrint;
    });

    test('Always denied permission blocks tracking', () async {
      final trackingService = FakeTrackingService();
      final permissionService = FakeLocationPermissionService(
        permissionLevel: LocationPermissionLevel.deniedForever,
      );
      final repository = DefaultLocationUpdatesRepository(
        trackingService: trackingService,
        permissionService: permissionService,
        platformInfo: FakePlatformInfo(
          isAndroid: true,
          isIOS: false,
          androidSdkInt: 33,
        ),
        config: const LocationTrackingConfig(),
      );

      await repository.startTracking();

      expect(trackingService.startCalls, 0);
      expect(trackingService.isRunning, isFalse);
      expect(
        logs.any(
          (line) =>
              line.contains('Location tracking not started') &&
              line.contains('permission'),
        ),
        isTrue,
      );
    });

    test('Permission revoked while running stops tracking', () async {
      final trackingService = FakeTrackingService();
      final permissionService = FakeLocationPermissionService(
        permissionLevel: LocationPermissionLevel.background,
      );
      final repository = DefaultLocationUpdatesRepository(
        trackingService: trackingService,
        permissionService: permissionService,
        platformInfo: FakePlatformInfo(
          isAndroid: true,
          isIOS: false,
          androidSdkInt: 33,
        ),
        config: const LocationTrackingConfig(),
      );

      await repository.startTracking();
      expect(trackingService.isRunning, isTrue);

      permissionService.permissionLevel = LocationPermissionLevel.denied;
      await repository.refreshPermissions();

      expect(trackingService.stopCalls, 1);
      expect(trackingService.isRunning, isFalse);
      expect(
        logs.any(
          (line) =>
              line.contains('Location tracking not started') &&
              line.contains('permission'),
        ),
        isTrue,
      );
    });
  });
}
