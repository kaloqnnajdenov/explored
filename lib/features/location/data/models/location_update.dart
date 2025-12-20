/// Immutable snapshot of a single location update from the device.
class LocationUpdate {
  const LocationUpdate({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    this.altitude,
    this.bearing,
    this.speed,
    this.isMock = false,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;
  final double? altitude;
  final double? bearing;
  final double? speed;
  final bool isMock;
}
