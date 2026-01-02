import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

import 'package:explored/features/location/data/models/location_permission_level.dart';
import 'package:explored/features/location/data/services/location_permission_service.dart';
import 'package:explored/features/location/data/services/platform_info.dart';

class FakePlatformInfo implements PlatformInfo {
  FakePlatformInfo({
    required this.isAndroid,
    required this.isIOS,
    required this.androidSdkInt,
  });

  @override
  final bool isAndroid;

  @override
  final bool isIOS;

  @override
  final int? androidSdkInt;
}

class FakePermissionHandlerClient implements PermissionHandlerClient {
  FakePermissionHandlerClient({
    required this.foregroundStatus,
    required this.backgroundStatus,
    required this.notificationStatus,
    required this.serviceStatusValue,
  });

  permission_handler.PermissionStatus foregroundStatus;
  permission_handler.PermissionStatus backgroundStatus;
  permission_handler.PermissionStatus notificationStatus;
  permission_handler.ServiceStatus serviceStatusValue;

  int foregroundRequestCount = 0;
  int backgroundRequestCount = 0;
  int notificationRequestCount = 0;
  int statusCallCount = 0;

  @override
  Future<permission_handler.PermissionStatus> request(
    permission_handler.Permission permission,
  ) async {
    if (permission == permission_handler.Permission.locationAlways) {
      backgroundRequestCount += 1;
      return backgroundStatus;
    }
    if (permission == permission_handler.Permission.notification) {
      notificationRequestCount += 1;
      return notificationStatus;
    }
    foregroundRequestCount += 1;
    return foregroundStatus;
  }

  @override
  Future<permission_handler.PermissionStatus> status(
    permission_handler.Permission permission,
  ) async {
    statusCallCount += 1;
    if (permission == permission_handler.Permission.locationAlways) {
      return backgroundStatus;
    }
    if (permission == permission_handler.Permission.notification) {
      return notificationStatus;
    }
    return foregroundStatus;
  }

  @override
  Future<permission_handler.ServiceStatus> serviceStatus(
    permission_handler.PermissionWithService permission,
  ) async {
    return serviceStatusValue;
  }

  @override
  Future<bool> openAppSettings() async {
    return true;
  }
}

class FakeGeolocatorPermissionClient implements GeolocatorPermissionClient {
  FakeGeolocatorPermissionClient({
    required this.checkPermissionResult,
    required List<LocationPermission> requestResults,
    required this.serviceEnabled,
    List<LocationPermission>? checkResults,
  })  : _requestResults = List<LocationPermission>.from(requestResults),
        _checkResults = checkResults == null
            ? null
            : List<LocationPermission>.from(checkResults);

  LocationPermission checkPermissionResult;
  final List<LocationPermission> _requestResults;
  final List<LocationPermission>? _checkResults;
  final bool serviceEnabled;

  int checkCount = 0;
  int requestCount = 0;

  @override
  Future<LocationPermission> checkPermission() async {
    checkCount += 1;
    if (_checkResults != null && _checkResults!.isNotEmpty) {
      checkPermissionResult = _checkResults!.removeAt(0);
    }
    return checkPermissionResult;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    requestCount += 1;
    if (_requestResults.isNotEmpty) {
      checkPermissionResult = _requestResults.removeAt(0);
    }
    return checkPermissionResult;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return serviceEnabled;
  }
}

void main() {
  group('PermissionHandlerLocationPermissionService', () {
    test('iOS foreground request uses geolocator prompt', () async {
      final permissionClient = FakePermissionHandlerClient(
        foregroundStatus: permission_handler.PermissionStatus.denied,
        backgroundStatus: permission_handler.PermissionStatus.denied,
        notificationStatus: permission_handler.PermissionStatus.denied,
        serviceStatusValue: permission_handler.ServiceStatus.enabled,
      );
      final geolocatorClient = FakeGeolocatorPermissionClient(
        checkPermissionResult: LocationPermission.denied,
        requestResults: [LocationPermission.whileInUse],
        serviceEnabled: true,
      );
      final service = PermissionHandlerLocationPermissionService(
        client: permissionClient,
        geolocatorClient: geolocatorClient,
        platformInfo: FakePlatformInfo(
          isAndroid: false,
          isIOS: true,
          androidSdkInt: null,
        ),
      );

      final level = await service.requestForegroundPermission();

      expect(level, LocationPermissionLevel.foreground);
      expect(geolocatorClient.requestCount, 1);
      expect(permissionClient.foregroundRequestCount, 0);
    });

    test('iOS background request attempts upgrade to always', () async {
      final permissionClient = FakePermissionHandlerClient(
        foregroundStatus: permission_handler.PermissionStatus.denied,
        backgroundStatus: permission_handler.PermissionStatus.denied,
        notificationStatus: permission_handler.PermissionStatus.denied,
        serviceStatusValue: permission_handler.ServiceStatus.enabled,
      );
      final geolocatorClient = FakeGeolocatorPermissionClient(
        checkPermissionResult: LocationPermission.whileInUse,
        requestResults: const [],
        serviceEnabled: true,
        checkResults: [
          LocationPermission.whileInUse,
          LocationPermission.always,
        ],
      );
      final service = PermissionHandlerLocationPermissionService(
        client: permissionClient,
        geolocatorClient: geolocatorClient,
        platformInfo: FakePlatformInfo(
          isAndroid: false,
          isIOS: true,
          androidSdkInt: null,
        ),
      );

      final level = await service.requestBackgroundPermission();

      expect(level, LocationPermissionLevel.background);
      expect(geolocatorClient.requestCount, 0);
      expect(permissionClient.backgroundRequestCount, 1);
    });

    test('iOS notification permission uses permission_handler', () async {
      final permissionClient = FakePermissionHandlerClient(
        foregroundStatus: permission_handler.PermissionStatus.denied,
        backgroundStatus: permission_handler.PermissionStatus.denied,
        notificationStatus: permission_handler.PermissionStatus.denied,
        serviceStatusValue: permission_handler.ServiceStatus.enabled,
      );
      final geolocatorClient = FakeGeolocatorPermissionClient(
        checkPermissionResult: LocationPermission.denied,
        requestResults: const [],
        serviceEnabled: true,
      );
      final service = PermissionHandlerLocationPermissionService(
        client: permissionClient,
        geolocatorClient: geolocatorClient,
        platformInfo: FakePlatformInfo(
          isAndroid: false,
          isIOS: true,
          androidSdkInt: null,
        ),
      );

      final grantedBefore = await service.isNotificationPermissionGranted();

      permissionClient.notificationStatus =
          permission_handler.PermissionStatus.provisional;
      final grantedAfter = await service.requestNotificationPermission();

      expect(grantedBefore, false);
      expect(grantedAfter, true);
      expect(permissionClient.notificationRequestCount, 1);
      expect(service.isNotificationPermissionRequired, false);
    });

    test('Android foreground request uses permission_handler', () async {
      final permissionClient = FakePermissionHandlerClient(
        foregroundStatus: permission_handler.PermissionStatus.granted,
        backgroundStatus: permission_handler.PermissionStatus.denied,
        notificationStatus: permission_handler.PermissionStatus.denied,
        serviceStatusValue: permission_handler.ServiceStatus.enabled,
      );
      final geolocatorClient = FakeGeolocatorPermissionClient(
        checkPermissionResult: LocationPermission.denied,
        requestResults: const [],
        serviceEnabled: true,
      );
      final service = PermissionHandlerLocationPermissionService(
        client: permissionClient,
        geolocatorClient: geolocatorClient,
        platformInfo: FakePlatformInfo(
          isAndroid: true,
          isIOS: false,
          androidSdkInt: 34,
        ),
      );

      final level = await service.requestForegroundPermission();

      expect(level, LocationPermissionLevel.foreground);
      expect(permissionClient.foregroundRequestCount, 1);
      expect(geolocatorClient.requestCount, 0);
    });
  });
}
