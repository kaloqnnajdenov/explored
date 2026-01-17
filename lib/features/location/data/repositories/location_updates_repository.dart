import 'dart:async';

import 'package:flutter/foundation.dart';

import '../location_tracking_config.dart';
import '../models/lat_lng_sample.dart';
import '../models/location_permission_level.dart';
import '../services/location_permission_service.dart';
import '../services/location_tracking_service.dart';
import '../services/platform_info.dart';
import 'location_gap_filler.dart';

/// Repository contract for consuming location update streams.
abstract class LocationUpdatesRepository {
  Stream<LatLngSample> get locationUpdates;

  Future<void> startTracking();

  Future<void> stopTracking();

  /// Re-checks permissions and stops tracking if they are revoked.
  Future<void> refreshPermissions();

  Future<LocationPermissionLevel> checkPermissionLevel();

  Future<LocationPermissionLevel> requestForegroundPermission();

  Future<LocationPermissionLevel> requestBackgroundPermission();

  Future<bool> isLocationServiceEnabled();

  Future<bool> isNotificationPermissionGranted();

  Future<bool> requestNotificationPermission();

  bool get isNotificationPermissionRequired;

  Future<bool> openAppSettings();

  Future<bool> openNotificationSettings();

  bool get requiresBackgroundPermission;

  bool get isRunning;
}

/// Default repository that checks permissions then starts tracking.
class DefaultLocationUpdatesRepository implements LocationUpdatesRepository {
  DefaultLocationUpdatesRepository({
    required LocationTrackingService trackingService,
    required LocationPermissionService permissionService,
    required PlatformInfo platformInfo,
    required LocationTrackingConfig config,
  })  : _trackingService = trackingService,
        _permissionService = permissionService,
        _platformInfo = platformInfo,
        _gapFiller = LocationGapFiller(
          expectedInterval: config.gapFillInterval,
          maxSpeedMps: config.speedMaxMetersPerSecond,
          maxDistanceMeters: config.gapFillMaxDistanceMeters,
        ) {
    _controller = StreamController<LatLngSample>.broadcast(
      onListen: _startListening,
      onCancel: _stopListening,
    );
  }

  final LocationTrackingService _trackingService;
  final LocationPermissionService _permissionService;
  final PlatformInfo _platformInfo;
  final LocationGapFiller _gapFiller;
  late final StreamController<LatLngSample> _controller;
  StreamSubscription<LatLngSample>? _subscription;

  @override
  Stream<LatLngSample> get locationUpdates => _controller.stream;

  @override
  bool get isRunning => _trackingService.isRunning;

  @override
  Future<LocationPermissionLevel> checkPermissionLevel() {
    return _permissionService.checkPermissionLevel();
  }

  @override
  Future<LocationPermissionLevel> requestForegroundPermission() {
    return _permissionService.requestForegroundPermission();
  }

  @override
  Future<LocationPermissionLevel> requestBackgroundPermission() {
    return _permissionService.requestBackgroundPermission();
  }

  @override
  Future<bool> isLocationServiceEnabled() {
    return _permissionService.isLocationServiceEnabled();
  }

  @override
  Future<bool> isNotificationPermissionGranted() {
    return _permissionService.isNotificationPermissionGranted();
  }

  @override
  Future<bool> requestNotificationPermission() {
    return _permissionService.requestNotificationPermission();
  }

  @override
  bool get isNotificationPermissionRequired {
    return _permissionService.isNotificationPermissionRequired;
  }

  @override
  Future<bool> openAppSettings() {
    return _permissionService.openAppSettings();
  }

  @override
  Future<bool> openNotificationSettings() {
    return _permissionService.openNotificationSettings();
  }

  @override
  bool get requiresBackgroundPermission {
    return _requiresBackgroundPermission();
  }

  @override
  Future<void> startTracking() async {
    if (_trackingService.isRunning) {
      return;
    }

    final canStart = await _safeCanStartTracking();
    if (!canStart) {
      return;
    }

    try {
      await _trackingService.start();
      _gapFiller.reset();
    } catch (error) {
      debugPrint('Failed to start location tracking: $error');
    }
  }

  @override
  Future<void> stopTracking() async {
    try {
      await _trackingService.stop();
      _gapFiller.reset();
    } catch (error) {
      debugPrint('Failed to stop location tracking: $error');
    }
  }

  @override
  Future<void> refreshPermissions() async {
    if (!_trackingService.isRunning) {
      return;
    }

    final canContinue = await _safeCanStartTracking();
    if (!canContinue) {
      try {
        await _trackingService.stop();
        _gapFiller.reset();
      } catch (error) {
        debugPrint('Failed to stop location tracking: $error');
      }
    }
  }

  Future<bool> _safeCanStartTracking() async {
    try {
      return await _canStartTracking();
    } catch (error) {
      debugPrint('Failed to check tracking permissions: $error');
      return false;
    }
  }

  Future<bool> _canStartTracking() async {
    if (!_platformInfo.isAndroid && !_platformInfo.isIOS) {
      _logPermission('Unsupported platform.');
      return false;
    }

    final serviceEnabled = await _permissionService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _logPermission(
        'Location services are disabled. Enable location services to start tracking.',
      );
      return false;
    }

    final permissionLevel = await _permissionService.checkPermissionLevel();
    if (!_hasRequiredPermission(permissionLevel)) {
      _logPermission(_permissionMessage(permissionLevel));
      return false;
    }

    if (_permissionService.isNotificationPermissionRequired) {
      final granted = await _permissionService.isNotificationPermissionGranted();
      if (!granted) {
        _logPermission(
          'Notification permission is required to start tracking.',
        );
        return false;
      }
    }

    return true;
  }

  bool _hasRequiredPermission(LocationPermissionLevel level) {
    if (_requiresBackgroundPermission()) {
      return level == LocationPermissionLevel.background;
    }
    return level == LocationPermissionLevel.foreground ||
        level == LocationPermissionLevel.background;
  }

  String _permissionMessage(LocationPermissionLevel level) {
    if (_requiresBackgroundPermission()) {
      return 'Background location permission is required to start tracking.';
    }
    switch (level) {
      case LocationPermissionLevel.denied:
      case LocationPermissionLevel.deniedForever:
      case LocationPermissionLevel.restricted:
      case LocationPermissionLevel.unknown:
        return 'Foreground location permission is required to start tracking.';
      case LocationPermissionLevel.foreground:
      case LocationPermissionLevel.background:
        return 'Foreground location permission is required to start tracking.';
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

  void _logPermission(String message) {
    debugPrint('Location tracking not started: $message');
  }

  void _startListening() {
    _subscription ??= _trackingService.stream.listen(
      _handleSample,
      onError: _controller.addError,
    );
  }

  Future<void> _stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void _handleSample(LatLngSample sample) {
    for (final output in _gapFiller.handleSample(sample)) {
      _controller.add(output);
    }
  }
}
