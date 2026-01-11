/// Immutable snapshot containing only the coordinates and timestamp.
class LatLngSample {
  const LatLngSample({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;
  final DateTime timestamp;
}
