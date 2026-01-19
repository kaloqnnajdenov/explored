import '../models/app_permission.dart';
import '../services/file_access_permission_service.dart';
import '../services/permission_request_store.dart';
import '../../../location/data/models/location_permission_level.dart';
import '../../../location/data/services/location_permission_service.dart';
import '../../../location/data/services/platform_info.dart';

abstract class PermissionsRepository {
  Future<List<AppPermissionStatus>> fetchPermissions();

  Future<void> requestPermission(AppPermissionType type);

  Future<void> requestInitialPermissionsIfNeeded();
}

class DefaultPermissionsRepository implements PermissionsRepository {
  DefaultPermissionsRepository({
    required LocationPermissionService locationPermissionService,
    required FileAccessPermissionService fileAccessPermissionService,
    required PermissionRequestStore requestStore,
    required PlatformInfo platformInfo,
  })  : _locationPermissionService = locationPermissionService,
        _fileAccessPermissionService = fileAccessPermissionService,
        _requestStore = requestStore,
        _platformInfo = platformInfo;

  final LocationPermissionService _locationPermissionService;
  final FileAccessPermissionService _fileAccessPermissionService;
  final PermissionRequestStore _requestStore;
  final PlatformInfo _platformInfo;

  @override
  Future<List<AppPermissionStatus>> fetchPermissions() async {
    final permissionLevel =
        await _locationPermissionService.checkPermissionLevel();
    final notificationGranted =
        await _locationPermissionService.isNotificationPermissionGranted();
    final fileAccessGranted = await _fileAccessPermissionService.isGranted();

    final permissions = <AppPermissionStatus>[
      AppPermissionStatus(
        type: AppPermissionType.locationForeground,
        isGranted: _isForegroundGranted(permissionLevel),
      ),
      if (_shouldExposeBackgroundPermission())
        AppPermissionStatus(
          type: AppPermissionType.locationBackground,
          isGranted: permissionLevel == LocationPermissionLevel.background,
        ),
      if (_shouldExposeNotificationPermission())
        AppPermissionStatus(
          type: AppPermissionType.notifications,
          isGranted: notificationGranted,
        ),
      if (_shouldExposeFileAccessPermission())
        AppPermissionStatus(
          type: AppPermissionType.fileAccess,
          isGranted: fileAccessGranted,
        ),
    ];

    return permissions;
  }

  @override
  Future<void> requestPermission(AppPermissionType type) async {
    switch (type) {
      case AppPermissionType.locationForeground:
        await _locationPermissionService.requestForegroundPermission();
        break;
      case AppPermissionType.locationBackground:
        await _locationPermissionService.requestBackgroundPermission();
        break;
      case AppPermissionType.notifications:
        await _locationPermissionService.requestNotificationPermission();
        break;
      case AppPermissionType.fileAccess:
        await _fileAccessPermissionService.request();
        break;
    }
  }

  @override
  Future<void> requestInitialPermissionsIfNeeded() async {
    final hasRequested = await _requestStore.hasRequestedPermissions();
    if (hasRequested) {
      return;
    }

    try {
      await _requestInitialPermissions();
    } finally {
      await _requestStore.markPermissionsRequested();
    }
  }

  Future<void> _requestInitialPermissions() async {
    final permissionLevel =
        await _locationPermissionService.checkPermissionLevel();
    if (!_isForegroundGranted(permissionLevel)) {
      await _locationPermissionService.requestForegroundPermission();
    }

    if (_requiresBackgroundPermission()) {
      final updatedLevel =
          await _locationPermissionService.checkPermissionLevel();
      if (updatedLevel != LocationPermissionLevel.background) {
        await _locationPermissionService.requestBackgroundPermission();
      }
    }

    if (_locationPermissionService.isNotificationPermissionRequired) {
      final granted =
          await _locationPermissionService.isNotificationPermissionGranted();
      if (!granted) {
        await _locationPermissionService.requestNotificationPermission();
      }
    }

    if (_isFileAccessRequired()) {
      final granted = await _fileAccessPermissionService.isGranted();
      if (!granted) {
        await _fileAccessPermissionService.request();
      }
    }
  }

  bool _requiresBackgroundPermission() {
    if (_platformInfo.isIOS) {
      return true;
    }
    if (_platformInfo.isAndroid) {
      return (_platformInfo.androidSdkInt ?? 0) >= 29;
    }
    return false;
  }

  bool _shouldExposeBackgroundPermission() {
    return _platformInfo.isAndroid || _platformInfo.isIOS;
  }

  bool _shouldExposeNotificationPermission() {
    return _platformInfo.isAndroid || _platformInfo.isIOS;
  }

  bool _shouldExposeFileAccessPermission() {
    return _platformInfo.isAndroid;
  }

  bool _isFileAccessRequired() {
    final sdkInt = _platformInfo.androidSdkInt;
    if (!_platformInfo.isAndroid || sdkInt == null) {
      return false;
    }
    return sdkInt < 33;
  }

  bool _isForegroundGranted(LocationPermissionLevel level) {
    return level == LocationPermissionLevel.foreground ||
        level == LocationPermissionLevel.background;
  }
}
