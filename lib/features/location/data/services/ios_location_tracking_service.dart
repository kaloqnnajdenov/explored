import 'location_tracking_service_base.dart';

/// iOS-specific tracking implementation (no extra configuration needed).
class IOSLocationTrackingService extends LocationTrackingServiceBase {
  IOSLocationTrackingService({
    required super.client,
    required super.config,
    super.nowProvider,
  }) : super(platformLabel: 'ios');

  @override
  Future<void> configurePlatform() async {
    // iOS relies on plugin defaults; no extra setup required.
    return;
  }
}
