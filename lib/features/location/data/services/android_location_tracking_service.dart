import 'location_tracking_service_base.dart';

/// Android-specific tracking configuration using background_location plugin.
class AndroidLocationTrackingService extends LocationTrackingServiceBase {
  AndroidLocationTrackingService({
    required super.client,
    required super.config,
    super.nowProvider,
  }) : super(platformLabel: 'android');

  @override
  Future<void> configurePlatform() async {
    // Interval configuration is Android-only in the background_location plugin.
    // Notification text is intentionally not set to keep UI messaging out of scope.
    await client.setAndroidConfiguration(config.updateIntervalMilliseconds);
  }
}
