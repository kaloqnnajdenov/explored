import '../models/location_update.dart';

/// Defines a testable gateway for location services and background tracking IO.
abstract class LocationServicesGateway {
  Future<bool> isLocationServicesEnabled();

  Stream<LocationUpdate> locationStream();

  Future<void> startBackgroundService();

  Future<void> stopBackgroundService();

  Future<bool> canPostNotifications();

  Future<void> openAppSettings();

  Future<void> openNotificationSettings();
}
