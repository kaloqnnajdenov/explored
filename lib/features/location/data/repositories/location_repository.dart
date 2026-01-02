import 'dart:async';

import '../models/location_notification.dart';
import '../models/location_permission_level.dart';
import '../models/location_tracking_mode.dart';
import '../models/location_update.dart';
import '../services/background_location_service.dart';
import '../services/foreground_location_service.dart';
import '../services/location_permission_service.dart';
import '../services/location_storage_service.dart';

/// Coordinates permissions, background tracking, and persistence of location.
class LocationRepository {
  LocationRepository({
    required ForegroundLocationService foregroundLocationService,
    required BackgroundTrackingService backgroundLocationService,
    required LocationPermissionService permissionService,
    required LocationStorageService storageService,
  })  : _foregroundLocationService = foregroundLocationService,
        _backgroundLocationService = backgroundLocationService,
        _permissionService = permissionService,
        _storageService = storageService;

  final ForegroundLocationService _foregroundLocationService;
  final BackgroundTrackingService _backgroundLocationService;
  final LocationPermissionService _permissionService;
  final LocationStorageService _storageService;
  final StreamController<LocationUpdate> _controller =
      StreamController<LocationUpdate>.broadcast();
  StreamSubscription<LocationUpdate>? _subscription;
  LocationTrackingMode _activeMode = LocationTrackingMode.none;

  Stream<LocationUpdate> get locationUpdates => _controller.stream;

  Future<LocationPermissionLevel> checkPermissionLevel() {
    return _permissionService.checkPermissionLevel();
  }

  Future<LocationPermissionLevel> requestForegroundPermission() {
    return _permissionService.requestForegroundPermission();
  }

  Future<LocationPermissionLevel> requestBackgroundPermission() {
    return _permissionService.requestBackgroundPermission();
  }

  Future<bool> isLocationServiceEnabled() {
    return _permissionService.isLocationServiceEnabled();
  }

  Future<bool> isNotificationPermissionGranted() {
    return _permissionService.isNotificationPermissionGranted();
  }

  Future<bool> requestNotificationPermission() {
    return _permissionService.requestNotificationPermission();
  }

  bool get isNotificationPermissionRequired {
    return _permissionService.isNotificationPermissionRequired;
  }

  Future<bool> openAppSettings() {
    return _permissionService.openAppSettings();
  }

  Future<LocationUpdate?> loadLastLocation() {
    return _storageService.loadLastLocation();
  }

  Future<void> startForegroundTracking({double? distanceFilter}) async {
    await stopTracking();
    _attachUpdates(_foregroundLocationService.locationUpdates);
    await _foregroundLocationService.startLocationUpdates(
      distanceFilter: distanceFilter,
    );
    _activeMode = LocationTrackingMode.foreground;
  }

  Future<void> startBackgroundTracking({
    required LocationNotification notification,
    int androidIntervalMs = 1000,
    double? distanceFilter,
  }) async {
    await stopTracking();
    // Workaround plugin issue: stop any existing service before starting.
    await _backgroundLocationService.stopLocationService();
    await _backgroundLocationService.configureAndroidNotification(notification);
    await _backgroundLocationService.configureAndroidInterval(androidIntervalMs);
    _attachUpdates(_backgroundLocationService.locationUpdates);
    await _backgroundLocationService.startLocationService(
      distanceFilter: distanceFilter,
    );
    _activeMode = LocationTrackingMode.background;
  }

  Future<void> stopTracking() async {
    await _subscription?.cancel();
    _subscription = null;
    if (_activeMode == LocationTrackingMode.background) {
      await _backgroundLocationService.stopLocationService();
    } else if (_activeMode == LocationTrackingMode.foreground) {
      await _foregroundLocationService.stopLocationUpdates();
    }
    _activeMode = LocationTrackingMode.none;
  }

  void _attachUpdates(Stream<LocationUpdate> updates) {
    _subscription?.cancel();
    _subscription = updates.listen((update) {
      _controller.add(update);
      unawaited(_storageService.saveLastLocation(update));
    });
  }
}
