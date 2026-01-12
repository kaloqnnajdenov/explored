import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/location/data/location_tracking_config.dart';
import 'package:explored/features/location/data/services/background_location_client.dart';
import 'package:explored/features/location/data/services/location_tracking_service_factory.dart';
import 'package:explored/features/location/data/services/platform_info.dart';
import 'package:explored/features/location/data/services/android_location_tracking_service.dart';
import 'package:explored/features/location/data/services/ios_location_tracking_service.dart';

class FakePlatformInfo implements PlatformInfo {
  FakePlatformInfo({
    required this.isAndroid,
    required this.isIOS,
    this.androidSdkInt,
  });

  @override
  final bool isAndroid;

  @override
  final bool isIOS;

  @override
  final int? androidSdkInt;
}

class FakeBackgroundLocationClient implements BackgroundLocationClient {
  @override
  Future<void> setAndroidNotification({
    required String title,
    required String message,
    required String iconName,
  }) async {}

  @override
  Future<void> setAndroidConfiguration(int intervalMs) async {}

  @override
  Future<void> startLocationService({
    double? distanceFilter,
    bool? forceAndroidLocationManager,
  }) async {}

  @override
  Future<void> stopLocationService() async {}

  @override
  void getLocationUpdates(RawLocationCallback callback) {}
}

void main() {
  test('Factory returns Android service on Android', () {
    final service = LocationTrackingServiceFactory.create(
      client: FakeBackgroundLocationClient(),
      config: const LocationTrackingConfig(),
      platformInfo: FakePlatformInfo(
        isAndroid: true,
        isIOS: false,
        androidSdkInt: 33,
      ),
    );

    expect(service, isA<AndroidLocationTrackingService>());
  });

  test('Factory returns iOS service on iOS', () {
    final service = LocationTrackingServiceFactory.create(
      client: FakeBackgroundLocationClient(),
      config: const LocationTrackingConfig(),
      platformInfo: FakePlatformInfo(
        isAndroid: false,
        isIOS: true,
      ),
    );

    expect(service, isA<IOSLocationTrackingService>());
  });

  test('Factory returns no-op service on unsupported platform', () {
    final service = LocationTrackingServiceFactory.create(
      client: FakeBackgroundLocationClient(),
      config: const LocationTrackingConfig(),
      platformInfo: FakePlatformInfo(
        isAndroid: false,
        isIOS: false,
      ),
    );

    expect(
      service.runtimeType.toString(),
      'UnsupportedLocationTrackingService',
    );
  });
}
