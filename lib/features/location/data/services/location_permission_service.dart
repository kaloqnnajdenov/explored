import 'package:geolocator/geolocator.dart';
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

  bool get isNotificationPermissionRequired;

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

/// Minimal abstraction over geolocator for iOS permission prompts.
abstract class GeolocatorPermissionClient {
  Future<LocationPermission> checkPermission();

  Future<LocationPermission> requestPermission();

  Future<bool> isLocationServiceEnabled();
}

/// Production client that forwards to geolocator permission APIs.
class GeolocatorPermissionClientImpl implements GeolocatorPermissionClient {
  @override
  Future<LocationPermission> checkPermission() {
    return Geolocator.checkPermission();
  }

  @override
  Future<LocationPermission> requestPermission() {
    return Geolocator.requestPermission();
  }

  @override
  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }
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
    required GeolocatorPermissionClient geolocatorClient,
    required PlatformInfo platformInfo,
  })  : _client = client,
        _geolocatorClient = geolocatorClient,
        _platformInfo = platformInfo;

  final PermissionHandlerClient _client;
  final GeolocatorPermissionClient _geolocatorClient;
  final PlatformInfo _platformInfo;

  @override
  Future<LocationPermissionLevel> checkPermissionLevel() async {
    if (_platformInfo.isIOS) {
      final status = await _geolocatorClient.checkPermission();
      return _mapGeolocatorPermission(status);
    }
    final foregroundStatus = await _client.status(_foregroundPermission());
    final backgroundStatus = await _client.status(_backgroundPermission());
    return _resolveLevel(foregroundStatus, backgroundStatus);
  }

  @override
  Future<LocationPermissionLevel> requestForegroundPermission() async {
    if (_platformInfo.isIOS) {
      final status = await _geolocatorClient.requestPermission();
      return _mapGeolocatorPermission(status);
    }
    final foregroundStatus = await _client.request(_foregroundPermission());
    final backgroundStatus = await _client.status(_backgroundPermission());
    return _resolveLevel(foregroundStatus, backgroundStatus);
  }

  @override
  Future<LocationPermissionLevel> requestBackgroundPermission() async {
    if (_platformInfo.isIOS) {
      return _requestIosBackgroundPermission();
    }
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
    if (_platformInfo.isIOS) {
      return _geolocatorClient.isLocationServiceEnabled();
    }
    final status = await _client.serviceStatus(_foregroundPermission());
    return status == permission_handler.ServiceStatus.enabled;
  }

  @override
  Future<bool> isNotificationPermissionGranted() async {
    if (!_platformInfo.isAndroid && !_platformInfo.isIOS) {
      return true;
    }
    final status = await _client.status(permission_handler.Permission.notification);
    return _isNotificationPermissionGranted(status);
  }

  @override
  Future<bool> requestNotificationPermission() async {
    if (!_platformInfo.isAndroid && !_platformInfo.isIOS) {
      return true;
    }
    final status = await _client.request(permission_handler.Permission.notification);
    return _isNotificationPermissionGranted(status);
  }

  @override
  Future<bool> openAppSettings() {
    return _client.openAppSettings();
  }

  @override
  bool get isNotificationPermissionRequired {
    if (_platformInfo.isAndroid) {
      return (_platformInfo.androidSdkInt ?? 0) >= 33;
    }
    return false;
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

  bool _isNotificationPermissionGranted(
    permission_handler.PermissionStatus status,
  ) {
    return status == permission_handler.PermissionStatus.granted ||
        status == permission_handler.PermissionStatus.limited ||
        status == permission_handler.PermissionStatus.provisional;
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

  Future<LocationPermissionLevel> _requestIosBackgroundPermission() async {
    var status = await _geolocatorClient.checkPermission();
    if (_shouldRequestGeolocatorPermission(status)) {
      status = await _geolocatorClient.requestPermission();
    }
    if (status == LocationPermission.whileInUse) {
      await _client.request(_backgroundPermission());
      status = await _geolocatorClient.checkPermission();
    }
    return _mapGeolocatorPermission(status);
  }

  bool _shouldRequestGeolocatorPermission(LocationPermission status) {
    return status == LocationPermission.denied ||
        status == LocationPermission.unableToDetermine;
  }

  LocationPermissionLevel _mapGeolocatorPermission(
    LocationPermission status,
  ) {
    switch (status) {
      case LocationPermission.denied:
        return LocationPermissionLevel.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionLevel.deniedForever;
      case LocationPermission.whileInUse:
        return LocationPermissionLevel.foreground;
      case LocationPermission.always:
        return LocationPermissionLevel.background;
      case LocationPermission.unableToDetermine:
        return LocationPermissionLevel.unknown;
    }
  }
}
