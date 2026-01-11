import '../location_tracking_config.dart';
import 'background_location_client.dart';
import 'location_tracking_service_base.dart';

/// iOS-specific tracking implementation (no extra configuration needed).
class IOSLocationTrackingService extends LocationTrackingServiceBase {
  IOSLocationTrackingService({
    required BackgroundLocationClient client,
    required LocationTrackingConfig config,
  }) : super(
          client: client,
          config: config,
          platformLabel: 'ios',
        );

  @override
  Future<void> configurePlatform() async {
    // iOS relies on plugin defaults; no extra setup required.
    return;
  }
}
