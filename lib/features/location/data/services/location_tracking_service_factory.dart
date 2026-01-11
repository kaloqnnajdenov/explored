import 'dart:io';

import '../location_tracking_config.dart';
import '../models/lat_lng_sample.dart';
import 'android_location_tracking_service.dart';
import 'background_location_client.dart';
import 'ios_location_tracking_service.dart';
import 'location_tracking_service.dart';

/// Builds the correct platform tracking service for Android/iOS.
class LocationTrackingServiceFactory {
  static LocationTrackingService create({
    required BackgroundLocationClient client,
    required LocationTrackingConfig config,
  }) {
    if (Platform.isAndroid) {
      return AndroidLocationTrackingService(client: client, config: config);
    }
    if (Platform.isIOS) {
      return IOSLocationTrackingService(client: client, config: config);
    }
    return UnsupportedLocationTrackingService();
  }
}

/// No-op service for unsupported platforms (keeps app from crashing).
class UnsupportedLocationTrackingService implements LocationTrackingService {
  @override
  Stream<LatLngSample> get stream => const Stream<LatLngSample>.empty();

  @override
  bool get isRunning => false;

  @override
  Future<void> start() async {
    // ignore: avoid_print
    print('[LocationTracking] Unsupported platform; tracking not started.');
  }

  @override
  Future<void> stop() async {}
}
