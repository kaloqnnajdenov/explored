import 'package:permission_handler/permission_handler.dart' as permission_handler;

import '../models/location_permission_level.dart';
import 'platform_info.dart';

/// Defines the permission operations needed for location tracking.
abstract class LocationPermissionService {
  Future<LocationPermissionLevel> checkPermissionLevel();

  Future<LocationPermissionLevel> requestForegroundPermission();

  Future<LocationPermissionLevel> requestBackgroundPermission();

  Future<bool> isLocationServiceEnabled();

  Future<bool> isNotificationPermissionGranted();

  Future<bool> requestNotificationPermission();

  Future<bool> openAppSettings();
}

/// Minimal abstraction over permission_handler for testable permission flows.
abstract class PermissionHandlerClient {
  Future<permission_handler.PermissionStatus> request(
    permission_handler.Permission permission,
  );

  Future<permission_handler.PermissionStatus> status(
    permission_handler.Permission permission,
  );

  Future<permission_handler.ServiceStatus> serviceStatus(
    permission_handler.PermissionWithService permission,
  );

  Future<bool> openAppSettings();
}

/// Production client that forwards to permission_handler APIs.
class PermissionHandlerClientImpl implements PermissionHandlerClient {
  @override
  Future<permission_handler.PermissionStatus> request(
    permission_handler.Permission permission,
  ) {
    return permission.request();
  }

  @override
  Future<permission_handler.PermissionStatus> status(
    permission_handler.Permission permission,
  ) {
    return permission.status;
  }

  @override
  Future<permission_handler.ServiceStatus> serviceStatus(
    permission_handler.PermissionWithService permission,
  ) {
    return permission.serviceStatus;
  }

  @override
  Future<bool> openAppSettings() {
    return permission_handler.openAppSettings();
  }
}

/// Uses permission_handler to map platform permission state to app-level enums.
class PermissionHandlerLocationPermissionService
    implements LocationPermissionService {
  PermissionHandlerLocationPermissionService({
    required PermissionHandlerClient client,
    required PlatformInfo platformInfo,
  })  : _client = client,
        _platformInfo = platformInfo;

  final PermissionHandlerClient _client;
  final PlatformInfo _platformInfo;

  @override
  Future<LocationPermissionLevel> checkPermissionLevel() async {
    final foregroundStatus = await _client.status(_foregroundPermission());
    final backgroundStatus = await _client.status(_backgroundPermission());
    return _resolveLevel(foregroundStatus, backgroundStatus);
  }

  @override
  Future<LocationPermissionLevel> requestForegroundPermission() async {
    final foregroundStatus = await _client.request(_foregroundPermission());
    final backgroundStatus = await _client.status(_backgroundPermission());
    return _resolveLevel(foregroundStatus, backgroundStatus);
  }

  @override
  Future<LocationPermissionLevel> requestBackgroundPermission() async {
    final foregroundPermission = _foregroundPermission();
    var foregroundStatus = await _client.status(foregroundPermission);

    if (!_isForegroundGranted(foregroundStatus)) {
      foregroundStatus = await _client.request(foregroundPermission);
    }

    final backgroundStatus = await _client.request(_backgroundPermission());
    return _resolveLevel(foregroundStatus, backgroundStatus);
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    final status = await _client.serviceStatus(_foregroundPermission());
    return status == permission_handler.ServiceStatus.enabled;
  }

  @override
  Future<bool> isNotificationPermissionGranted() async {
    if (!_platformInfo.isAndroid) {
      return true;
    }
    final status = await _client.status(permission_handler.Permission.notification);
    return status == permission_handler.PermissionStatus.granted ||
        status == permission_handler.PermissionStatus.limited;
  }

  @override
  Future<bool> requestNotificationPermission() async {
    if (!_platformInfo.isAndroid) {
      return true;
    }
    final status = await _client.request(permission_handler.Permission.notification);
    return status == permission_handler.PermissionStatus.granted ||
        status == permission_handler.PermissionStatus.limited;
  }

  @override
  Future<bool> openAppSettings() {
    return _client.openAppSettings();
  }

  permission_handler.PermissionWithService _foregroundPermission() {
    return _platformInfo.isIOS
        ? permission_handler.Permission.locationWhenInUse
        : permission_handler.Permission.location;
  }

  permission_handler.PermissionWithService _backgroundPermission() {
    return permission_handler.Permission.locationAlways;
  }

  bool _isForegroundGranted(permission_handler.PermissionStatus status) {
    return status == permission_handler.PermissionStatus.granted ||
        status == permission_handler.PermissionStatus.limited;
  }

  LocationPermissionLevel _resolveLevel(
    permission_handler.PermissionStatus foregroundStatus,
    permission_handler.PermissionStatus backgroundStatus,
  ) {
    if (foregroundStatus == permission_handler.PermissionStatus.restricted ||
        backgroundStatus == permission_handler.PermissionStatus.restricted) {
      return LocationPermissionLevel.restricted;
    }

    if (foregroundStatus ==
            permission_handler.PermissionStatus.permanentlyDenied ||
        backgroundStatus ==
            permission_handler.PermissionStatus.permanentlyDenied) {
      return LocationPermissionLevel.deniedForever;
    }

    if (backgroundStatus == permission_handler.PermissionStatus.granted) {
      return LocationPermissionLevel.background;
    }

    if (_isForegroundGranted(foregroundStatus)) {
      return LocationPermissionLevel.foreground;
    }

    if (foregroundStatus == permission_handler.PermissionStatus.denied ||
        backgroundStatus == permission_handler.PermissionStatus.denied) {
      return LocationPermissionLevel.denied;
    }

    return LocationPermissionLevel.unknown;
  }
}
