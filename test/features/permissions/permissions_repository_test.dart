import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/location/data/models/location_permission_level.dart';
import 'package:explored/features/location/data/services/location_permission_service.dart';
import 'package:explored/features/location/data/services/platform_info.dart';
import 'package:explored/features/permissions/data/models/app_permission.dart';
import 'package:explored/features/permissions/data/repositories/permissions_repository.dart';
import 'package:explored/features/permissions/data/services/file_access_permission_service.dart';
import 'package:explored/features/permissions/data/services/permission_request_store.dart';

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

class FakeLocationPermissionService implements LocationPermissionService {
  LocationPermissionLevel permissionLevel = LocationPermissionLevel.denied;
  bool notificationGranted = false;
  bool notificationRequired = false;

  int foregroundRequests = 0;
  int backgroundRequests = 0;
  int notificationRequests = 0;

  @override
  Future<LocationPermissionLevel> checkPermissionLevel() async {
    return permissionLevel;
  }

  @override
  Future<LocationPermissionLevel> requestForegroundPermission() async {
    foregroundRequests += 1;
    return permissionLevel;
  }

  @override
  Future<LocationPermissionLevel> requestBackgroundPermission() async {
    backgroundRequests += 1;
    return permissionLevel;
  }

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<bool> isNotificationPermissionGranted() async {
    return notificationGranted;
  }

  @override
  Future<bool> requestNotificationPermission() async {
    notificationRequests += 1;
    return notificationGranted;
  }

  @override
  bool get isNotificationPermissionRequired => notificationRequired;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openNotificationSettings() async => true;
}

class FakeFileAccessPermissionService implements FileAccessPermissionService {
  bool granted = false;
  int requestCalls = 0;
  int statusCalls = 0;

  @override
  Future<bool> isGranted() async {
    statusCalls += 1;
    return granted;
  }

  @override
  Future<bool> request() async {
    requestCalls += 1;
    return granted;
  }
}

class FakePermissionRequestStore implements PermissionRequestStore {
  bool requested = false;
  int markCalls = 0;

  @override
  Future<bool> hasRequestedPermissions() async => requested;

  @override
  Future<void> markPermissionsRequested() async {
    requested = true;
    markCalls += 1;
  }
}

void main() {
  test('fetchPermissions returns required permissions with status', () async {
    final locationService = FakeLocationPermissionService()
      ..permissionLevel = LocationPermissionLevel.foreground
      ..notificationGranted = false
      ..notificationRequired = true;
    final fileService = FakeFileAccessPermissionService()..granted = false;
    final repository = DefaultPermissionsRepository(
      locationPermissionService: locationService,
      fileAccessPermissionService: fileService,
      requestStore: FakePermissionRequestStore(),
      platformInfo: FakePlatformInfo(
        isAndroid: true,
        isIOS: false,
        androidSdkInt: 30,
      ),
    );

    final permissions = await repository.fetchPermissions();

    expect(
      permissions.any(
        (perm) =>
            perm.type == AppPermissionType.locationForeground &&
            perm.isGranted,
      ),
      isTrue,
    );
    expect(
      permissions.any(
        (perm) =>
            perm.type == AppPermissionType.locationBackground &&
            !perm.isGranted,
      ),
      isTrue,
    );
    expect(
      permissions.any(
        (perm) =>
            perm.type == AppPermissionType.notifications && !perm.isGranted,
      ),
      isTrue,
    );
    expect(
      permissions.any(
        (perm) =>
            perm.type == AppPermissionType.fileAccess && !perm.isGranted,
      ),
      isTrue,
    );
  });

  test('fetchPermissions includes file access on Android with unknown SDK',
      () async {
    final locationService = FakeLocationPermissionService()
      ..permissionLevel = LocationPermissionLevel.foreground
      ..notificationGranted = false
      ..notificationRequired = true;
    final fileService = FakeFileAccessPermissionService()..granted = true;
    final repository = DefaultPermissionsRepository(
      locationPermissionService: locationService,
      fileAccessPermissionService: fileService,
      requestStore: FakePermissionRequestStore(),
      platformInfo: FakePlatformInfo(
        isAndroid: true,
        isIOS: false,
        androidSdkInt: null,
      ),
    );

    final permissions = await repository.fetchPermissions();

    expect(
      permissions.any(
        (perm) =>
            perm.type == AppPermissionType.fileAccess && perm.isGranted,
      ),
      isTrue,
    );
  });

  test('fetchPermissions exposes notifications on iOS', () async {
    final locationService = FakeLocationPermissionService()
      ..permissionLevel = LocationPermissionLevel.foreground
      ..notificationGranted = false
      ..notificationRequired = false;
    final fileService = FakeFileAccessPermissionService()..granted = false;
    final repository = DefaultPermissionsRepository(
      locationPermissionService: locationService,
      fileAccessPermissionService: fileService,
      requestStore: FakePermissionRequestStore(),
      platformInfo: FakePlatformInfo(
        isAndroid: false,
        isIOS: true,
        androidSdkInt: null,
      ),
    );

    final permissions = await repository.fetchPermissions();

    expect(
      permissions.any(
        (perm) => perm.type == AppPermissionType.locationBackground,
      ),
      isTrue,
    );
    expect(
      permissions.any(
        (perm) => perm.type == AppPermissionType.notifications,
      ),
      isTrue,
    );
  });

  test('requestInitialPermissionsIfNeeded requests once', () async {
    final locationService = FakeLocationPermissionService()
      ..permissionLevel = LocationPermissionLevel.denied
      ..notificationGranted = false
      ..notificationRequired = true;
    final fileService = FakeFileAccessPermissionService()..granted = false;
    final requestStore = FakePermissionRequestStore();
    final repository = DefaultPermissionsRepository(
      locationPermissionService: locationService,
      fileAccessPermissionService: fileService,
      requestStore: requestStore,
      platformInfo: FakePlatformInfo(
        isAndroid: true,
        isIOS: false,
        androidSdkInt: 30,
      ),
    );

    await repository.requestInitialPermissionsIfNeeded();
    await repository.requestInitialPermissionsIfNeeded();

    expect(locationService.foregroundRequests, 1);
    expect(locationService.backgroundRequests, 1);
    expect(locationService.notificationRequests, 1);
    expect(fileService.requestCalls, 1);
    expect(requestStore.markCalls, 1);
  });
}
