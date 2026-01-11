import '../models/lat_lng_sample.dart';

/// Shared interface for platform-specific location tracking services.
abstract class LocationTrackingService {
  Stream<LatLngSample> get stream;

  Future<void> start();

  Future<void> stop();

  bool get isRunning;
}
