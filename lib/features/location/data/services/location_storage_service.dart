import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_update.dart';

/// Persists the last known location locally for resilience and debugging.
abstract class LocationStorageService {
  Future<void> saveLastLocation(LocationUpdate location);

  Future<LocationUpdate?> loadLastLocation();
}

/// Stores location data using SharedPreferences.
class SharedPreferencesLocationStorageService implements LocationStorageService {
  static const _keyLat = 'last_location_latitude';
  static const _keyLng = 'last_location_longitude';
  static const _keyAccuracy = 'last_location_accuracy';
  static const _keyAltitude = 'last_location_altitude';
  static const _keyBearing = 'last_location_bearing';
  static const _keySpeed = 'last_location_speed';
  static const _keyTimestamp = 'last_location_timestamp';
  static const _keyIsMock = 'last_location_is_mock';

  @override
  Future<void> saveLastLocation(LocationUpdate location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyLat, location.latitude);
    await prefs.setDouble(_keyLng, location.longitude);
    await prefs.setDouble(_keyAccuracy, location.accuracy);
    if (location.altitude != null) {
      await prefs.setDouble(_keyAltitude, location.altitude!);
    }
    if (location.bearing != null) {
      await prefs.setDouble(_keyBearing, location.bearing!);
    }
    if (location.speed != null) {
      await prefs.setDouble(_keySpeed, location.speed!);
    }
    await prefs.setInt(_keyTimestamp, location.timestamp.millisecondsSinceEpoch);
    await prefs.setBool(_keyIsMock, location.isMock);
  }

  @override
  Future<LocationUpdate?> loadLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_keyLat) || !prefs.containsKey(_keyLng)) {
      return null;
    }
    final latitude = prefs.getDouble(_keyLat);
    final longitude = prefs.getDouble(_keyLng);
    if (latitude == null || longitude == null) {
      return null;
    }
    final accuracy = prefs.getDouble(_keyAccuracy) ?? 0;
    final timestampMs = prefs.getInt(_keyTimestamp) ?? 0;
    return LocationUpdate(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      altitude: prefs.getDouble(_keyAltitude),
      bearing: prefs.getDouble(_keyBearing),
      speed: prefs.getDouble(_keySpeed),
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMs),
      isMock: prefs.getBool(_keyIsMock) ?? false,
    );
  }
}
