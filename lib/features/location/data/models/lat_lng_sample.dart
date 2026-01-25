/// Immutable snapshot containing only the coordinates and timestamp.
class LatLngSample {
  const LatLngSample({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracyMeters,
    this.isInterpolated = false,
    this.source = LatLngSampleSource.live,
  });

  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? accuracyMeters;
  final bool isInterpolated;
  final LatLngSampleSource source;
}

enum LatLngSampleSource { live, imported, manual }
