import '../location_tracking_config.dart';
import 'background_location_client.dart';
import 'location_tracking_service_base.dart';

/// Android-specific tracking configuration using background_location plugin.
class AndroidLocationTrackingService extends LocationTrackingServiceBase {
  AndroidLocationTrackingService({
    required BackgroundLocationClient client,
    required LocationTrackingConfig config,
    DateTime Function()? nowProvider,
  }) : super(
          client: client,
          config: config,
          platformLabel: 'android',
          nowProvider: nowProvider,
        );

  @override
  Future<void> configurePlatform() async {
    // Interval configuration is Android-only in the background_location plugin.
    // Notification text is intentionally not set to keep UI messaging out of scope.
    await client.setAndroidConfiguration(config.updateIntervalMilliseconds);
  }
}
