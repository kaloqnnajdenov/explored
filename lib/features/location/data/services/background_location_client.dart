import 'package:background_location/background_location.dart';

/// Raw payload from the background_location plugin for easier testing.
class RawLocationData {
  const RawLocationData({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    required this.bearing,
    required this.speed,
    required this.time,
    required this.isMock,
  });

  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy;
  final double bearing;
  final double speed;
  final double time;
  final bool isMock;
}

/// Callback signature for raw background location updates.
typedef RawLocationCallback = void Function(RawLocationData data);

/// Bridge interface over the background_location plugin API.
abstract class BackgroundLocationClient {
  Future<void> setAndroidNotification({
    required String title,
    required String message,
    required String iconName,
  });

  Future<void> setAndroidConfiguration(int intervalMs);

  Future<void> startLocationService({
    double? distanceFilter,
    bool? forceAndroidLocationManager,
  });

  Future<void> stopLocationService();

  void getLocationUpdates(RawLocationCallback callback);
}

/// Production client that forwards calls to the background_location plugin.
class BackgroundLocationPluginClient implements BackgroundLocationClient {
  @override
  Future<void> setAndroidNotification({
    required String title,
    required String message,
    required String iconName,
  }) {
    return BackgroundLocation.setAndroidNotification(
      title: title,
      message: message,
      icon: iconName,
    );
  }

  @override
  Future<void> setAndroidConfiguration(int intervalMs) {
    return BackgroundLocation.setAndroidConfiguration(intervalMs);
  }

  @override
  Future<void> startLocationService({
    double? distanceFilter,
    bool? forceAndroidLocationManager,
  }) {
    return BackgroundLocation.startLocationService(
      distanceFilter: distanceFilter ?? 0,
      forceAndroidLocationManager: forceAndroidLocationManager ?? false,
    );
  }

  @override
  Future<void> stopLocationService() {
    return BackgroundLocation.stopLocationService();
  }

  @override
  void getLocationUpdates(RawLocationCallback callback) {
    BackgroundLocation.getLocationUpdates((location) {
      callback(
        RawLocationData(
          latitude: location.latitude ?? 0,
          longitude: location.longitude ?? 0,
          altitude: location.altitude ?? 0,
          accuracy: location.accuracy ?? 0,
          bearing: location.bearing ?? 0,
          speed: location.speed ?? 0,
          time: location.time ?? 0,
          isMock: location.isMock ?? false,
        ),
      );
    });
  }
}
