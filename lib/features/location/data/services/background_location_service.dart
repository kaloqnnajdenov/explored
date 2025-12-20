import 'dart:async';

import '../models/location_notification.dart';
import '../models/location_update.dart';
import 'background_location_client.dart';
import 'platform_info.dart';

/// Defines the IO surface for background location tracking operations.
abstract class BackgroundTrackingService {
  Stream<LocationUpdate> get locationUpdates;

  Future<void> configureAndroidNotification(LocationNotification notification);

  Future<void> configureAndroidInterval(int intervalMs);

  Future<void> startLocationService({
    double? distanceFilter,
    bool? forceAndroidLocationManager,
  });

  Future<void> stopLocationService();
}

/// Adapts the background_location plugin into a testable service.
class BackgroundLocationService implements BackgroundTrackingService {
  BackgroundLocationService({
    required BackgroundLocationClient client,
    required PlatformInfo platformInfo,
  })  : _client = client,
        _platformInfo = platformInfo;

  final BackgroundLocationClient _client;
  final PlatformInfo _platformInfo;
  final StreamController<LocationUpdate> _controller =
      StreamController<LocationUpdate>.broadcast();
  bool _isListening = false;

  @override
  Stream<LocationUpdate> get locationUpdates {
    _ensureListening();
    return _controller.stream;
  }

  @override
  Future<void> configureAndroidNotification(LocationNotification notification) async {
    if (!_platformInfo.isAndroid) {
      return;
    }
    await _client.setAndroidNotification(
      title: notification.title,
      message: notification.message,
      iconName: notification.iconName,
    );
  }

  @override
  Future<void> configureAndroidInterval(int intervalMs) async {
    if (!_platformInfo.isAndroid) {
      return;
    }
    await _client.setAndroidConfiguration(intervalMs);
  }

  @override
  Future<void> startLocationService({
    double? distanceFilter,
    bool? forceAndroidLocationManager,
  }) {
    _ensureListening();
    return _client.startLocationService(
      distanceFilter: distanceFilter,
      forceAndroidLocationManager: forceAndroidLocationManager,
    );
  }

  @override
  Future<void> stopLocationService() {
    return _client.stopLocationService();
  }

  void _ensureListening() {
    if (_isListening) {
      return;
    }
    _isListening = true;
    _client.getLocationUpdates((data) {
      _controller.add(_mapLocation(data));
    });
  }

  LocationUpdate _mapLocation(RawLocationData data) {
    final timestampMs = data.time.round();
    final timestamp = timestampMs > 0
        ? DateTime.fromMillisecondsSinceEpoch(timestampMs)
        : DateTime.now();
    return LocationUpdate(
      latitude: data.latitude,
      longitude: data.longitude,
      accuracy: data.accuracy,
      timestamp: timestamp,
      altitude: data.altitude,
      bearing: data.bearing,
      speed: data.speed,
      isMock: data.isMock,
    );
  }
}
