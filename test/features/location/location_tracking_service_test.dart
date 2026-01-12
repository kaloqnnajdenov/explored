import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/location/data/location_tracking_config.dart';
import 'package:explored/features/location/data/models/lat_lng_sample.dart';
import 'package:explored/features/location/data/services/android_location_tracking_service.dart';
import 'package:explored/features/location/data/services/background_location_client.dart';
import 'package:explored/features/location/data/services/ios_location_tracking_service.dart';
import 'package:explored/features/location/data/services/location_tracking_service_base.dart';

import 'location_test_utils.dart';

class FakeBackgroundLocationClient implements BackgroundLocationClient {
  RawLocationCallback? callback;
  int getUpdatesCalls = 0;
  int startCalls = 0;
  int stopCalls = 0;
  int androidConfigCalls = 0;
  int notificationCalls = 0;
  double? lastDistanceFilter;
  int? lastIntervalMs;

  @override
  Future<void> setAndroidNotification({
    required String title,
    required String message,
    required String iconName,
  }) async {
    notificationCalls += 1;
  }

  @override
  Future<void> setAndroidConfiguration(int intervalMs) async {
    androidConfigCalls += 1;
    lastIntervalMs = intervalMs;
  }

  @override
  Future<void> startLocationService({
    double? distanceFilter,
    bool? forceAndroidLocationManager,
  }) async {
    startCalls += 1;
    lastDistanceFilter = distanceFilter;
  }

  @override
  Future<void> stopLocationService() async {
    stopCalls += 1;
  }

  @override
  void getLocationUpdates(RawLocationCallback callback) {
    getUpdatesCalls += 1;
    this.callback = callback;
  }

  void emit(RawLocationData data) {
    callback?.call(data);
  }
}

class TestLocationTrackingService extends LocationTrackingServiceBase {
  TestLocationTrackingService({
    required super.client,
    required super.config,
    required super.nowProvider,
  }) : super(platformLabel: 'test');

  int configureCalls = 0;

  @override
  Future<void> configurePlatform() async {
    configureCalls += 1;
  }
}

LocationTrackingConfig _serviceConfig({
  int updateIntervalSeconds = 5,
  double distanceFilterMeters = 10,
  int watchdogCheckMinutes = 15,
  int? noUpdateThresholdSeconds,
  double minSpeedForIntervalMps = 2,
  double baseDistanceOffsetMeters = 10,
  double baseDistanceMinMeters = 10,
  double baseDistanceMaxMeters = 10,
  double speedEmaAlpha = 1,
  bool assumeBackground = false,
}) {
  return LocationTrackingConfig(
    updateIntervalSeconds: updateIntervalSeconds,
    distanceFilterMeters: distanceFilterMeters,
    watchdogCheckMinutes: watchdogCheckMinutes,
    noUpdateThresholdSeconds: noUpdateThresholdSeconds,
    minSpeedForIntervalMps: minSpeedForIntervalMps,
    baseDistanceOffsetMeters: baseDistanceOffsetMeters,
    baseDistanceMinMeters: baseDistanceMinMeters,
    baseDistanceMaxMeters: baseDistanceMaxMeters,
    speedEmaAlpha: speedEmaAlpha,
    minMovementMeters: 0,
    accuracyMovementFactor: 0,
    minMovementConfidence: 0,
    assumeBackground: assumeBackground,
  );
}

void main() {
  group('LocationTrackingServiceBase start/stop', () {
    test('Start begins streaming', () async {
      final client = FakeBackgroundLocationClient();
      final clock = TestClock(DateTime(2024, 1, 1));
      final service = TestLocationTrackingService(
        client: client,
        config: _serviceConfig(),
        nowProvider: () => clock.now,
      );

      final events = <LatLngSample>[];
      service.stream.listen(events.add);

      var runningAfterStart = false;
      final logs = await capturePrints(() async {
        await service.start();
        runningAfterStart = service.isRunning;
        client.emit(
          buildRawLocation(
            latitude: 0,
            longitude: 0,
            speed: 2,
            accuracy: 0,
            timestamp: clock.now,
          ),
        );
        await Future<void>.delayed(Duration.zero);
        await service.stop();
      });

      expect(runningAfterStart, isTrue);
      expect(events.length, 1);
      expect(logs.any((line) => line.contains('Location update')), isTrue);
    });

    test('Stop halts streaming and watchdog', () async {
      final client = FakeBackgroundLocationClient();
      final clock = TestClock(DateTime(2024, 1, 1));
      final service = TestLocationTrackingService(
        client: client,
        config: _serviceConfig(),
        nowProvider: () => clock.now,
      );
      final events = <LatLngSample>[];
      service.stream.listen(events.add);

      final logs = await capturePrints(() async {
        await service.start();
        client.emit(
          buildRawLocation(
            latitude: 0,
            longitude: 0,
            speed: 2,
            accuracy: 0,
            timestamp: clock.now,
          ),
        );
        await Future<void>.delayed(Duration.zero);
        await service.stop();
        client.emit(
          buildRawLocation(
            latitude: latDeltaForMeters(20),
            longitude: 0,
            speed: 2,
            accuracy: 0,
            timestamp: clock.now,
          ),
        );
        await Future<void>.delayed(Duration.zero);
      });

      expect(events.length, 1);
      expect(logs.where((line) => line.contains('Location update')).length, 1);
    });

    test('Start is idempotent and does not resubscribe', () async {
      final client = FakeBackgroundLocationClient();
      final clock = TestClock(DateTime(2024, 1, 1));
      final service = TestLocationTrackingService(
        client: client,
        config: _serviceConfig(),
        nowProvider: () => clock.now,
      );

      await service.start();
      await service.start();

      expect(client.getUpdatesCalls, 1);
      expect(client.startCalls, 1);
      expect(service.isRunning, isTrue);

      await service.stop();
    });

    test('Stop is idempotent', () async {
      final client = FakeBackgroundLocationClient();
      final clock = TestClock(DateTime(2024, 1, 1));
      final service = TestLocationTrackingService(
        client: client,
        config: _serviceConfig(),
        nowProvider: () => clock.now,
      );

      await service.start();
      await service.stop();
      await service.stop();

      expect(client.stopCalls, 1);
      expect(service.isRunning, isFalse);
    });

    test('Restart works cleanly', () async {
      final client = FakeBackgroundLocationClient();
      final clock = TestClock(DateTime(2024, 1, 1));
      final service = TestLocationTrackingService(
        client: client,
        config: _serviceConfig(),
        nowProvider: () => clock.now,
      );
      final events = <LatLngSample>[];
      service.stream.listen(events.add);

      await service.start();
      client.emit(
        buildRawLocation(
          latitude: 0,
          longitude: 0,
          speed: 2,
          accuracy: 0,
          timestamp: clock.now,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await service.stop();
      await service.start();
      client.emit(
        buildRawLocation(
          latitude: latDeltaForMeters(20),
          longitude: 0,
          speed: 2,
          accuracy: 0,
          timestamp: clock.now,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(events.length, 2);
      await service.stop();
    });
  });

  group('LocationTrackingServiceBase config wiring', () {
    test('Config values drive plugin and watchdog cadence', () async {
      fakeAsync((async) {
        final client = FakeBackgroundLocationClient();
        final clock = TestClock(DateTime(2024, 1, 1));
        final config = _serviceConfig(
          updateIntervalSeconds: 7,
          distanceFilterMeters: 25,
          watchdogCheckMinutes: 3,
          minSpeedForIntervalMps: 25 / 7,
          baseDistanceOffsetMeters: 25,
          baseDistanceMinMeters: 25,
          baseDistanceMaxMeters: 25,
        );
        final service = AndroidLocationTrackingService(
          client: client,
          config: config,
          nowProvider: () => clock.now,
        );

        final logs = <String>[];
        runZoned(
          () {
            service.start();
            async.flushMicrotasks();
            expect(client.lastIntervalMs, 7000);
            expect(client.lastDistanceFilter, 25);

            client.emit(
              buildRawLocation(
                latitude: 0,
                longitude: 0,
                speed: 25 / 7,
                accuracy: 0,
                timestamp: clock.now,
              ),
            );
            async.flushMicrotasks();
            clock.advance(const Duration(seconds: 7));
            async.elapse(const Duration(seconds: 7));
            client.emit(
              buildRawLocation(
                latitude: latDeltaForMeters(1),
                longitude: 0,
                speed: 25 / 7,
                accuracy: 0,
                timestamp: clock.now,
              ),
            );
            async.flushMicrotasks();
            clock.advance(const Duration(minutes: 3));
            async.elapse(const Duration(minutes: 3));
            service.stop();
            async.flushMicrotasks();
          },
          zoneSpecification: ZoneSpecification(
            print: (self, parent, zone, message) {
              logs.add(message);
            },
          ),
        );

        expect(
          logs.any((line) => line.contains('Location update')),
          isTrue,
        );
        expect(
          logs.any((line) => line.contains('reason=interval')),
          isTrue,
        );
        expect(
          logs.any((line) => line.contains('No location updates')),
          isTrue,
        );
      });
    });
  });

  group('LocationTrackingServiceBase watchdog', () {
    test('Foreground no updates triggers message once per cycle', () {
      fakeAsync((async) {
        final client = FakeBackgroundLocationClient();
        final clock = TestClock(DateTime(2024, 1, 1));
        final service = TestLocationTrackingService(
          client: client,
          config: _serviceConfig(
            watchdogCheckMinutes: 1,
            noUpdateThresholdSeconds: 60,
          ),
          nowProvider: () => clock.now,
        );
        final logs = <String>[];

        runZoned(
          () {
            service.start();
            async.flushMicrotasks();
            client.emit(
              buildRawLocation(
                latitude: 0,
                longitude: 0,
                speed: 2,
                accuracy: 0,
                timestamp: clock.now,
              ),
            );
            async.flushMicrotasks();
            clock.advance(const Duration(minutes: 1));
            async.elapse(const Duration(minutes: 1));
            service.stop();
            async.flushMicrotasks();
          },
          zoneSpecification: ZoneSpecification(
            print: (self, parent, zone, message) {
              logs.add(message);
            },
          ),
        );

        final notices =
            logs.where((line) => line.contains('No location updates')).length;
        expect(notices, 1);
      });
    });

    test('Foreground updates resume clears no-update condition', () {
      fakeAsync((async) {
        final client = FakeBackgroundLocationClient();
        final clock = TestClock(DateTime(2024, 1, 1));
        final service = TestLocationTrackingService(
          client: client,
          config: _serviceConfig(
            watchdogCheckMinutes: 1,
            noUpdateThresholdSeconds: 60,
          ),
          nowProvider: () => clock.now,
        );
        final logs = <String>[];

        runZoned(
          () {
            service.start();
            async.flushMicrotasks();
            client.emit(
              buildRawLocation(
                latitude: 0,
                longitude: 0,
                speed: 2,
                accuracy: 0,
                timestamp: clock.now,
              ),
            );
            async.flushMicrotasks();
            clock.advance(const Duration(seconds: 30));
            async.elapse(const Duration(seconds: 30));
            clock.advance(const Duration(seconds: 30));
            async.elapse(const Duration(seconds: 30));
            clock.advance(const Duration(seconds: 30));
            async.elapse(const Duration(seconds: 30));
            client.emit(
              buildRawLocation(
                latitude: latDeltaForMeters(10),
                longitude: 0,
                speed: 2,
                accuracy: 0,
                timestamp: clock.now,
              ),
            );
            async.flushMicrotasks();
            clock.advance(const Duration(seconds: 30));
            async.elapse(const Duration(seconds: 30));
            service.stop();
            async.flushMicrotasks();
          },
          zoneSpecification: ZoneSpecification(
            print: (self, parent, zone, message) {
              logs.add(message);
            },
          ),
        );

        final notices =
            logs.where((line) => line.contains('No location updates')).length;
        expect(notices, 1);
      });
    });

    test('Background watchdog checks run on schedule', () {
      fakeAsync((async) {
        final client = FakeBackgroundLocationClient();
        final clock = TestClock(DateTime(2024, 1, 1));
        final service = TestLocationTrackingService(
          client: client,
          config: _serviceConfig(
            watchdogCheckMinutes: 15,
            noUpdateThresholdSeconds: 900,
            assumeBackground: true,
          ),
          nowProvider: () => clock.now,
        );
        final logs = <String>[];

        runZoned(
          () {
            service.start();
            async.flushMicrotasks();
            for (var i = 0; i < 3; i += 1) {
              clock.advance(const Duration(minutes: 15));
              async.elapse(const Duration(minutes: 15));
            }
            service.stop();
            async.flushMicrotasks();
          },
          zoneSpecification: ZoneSpecification(
            print: (self, parent, zone, message) {
              logs.add(message);
            },
          ),
        );

        final notices =
            logs.where((line) => line.contains('No location updates')).length;
        expect(notices, 3);
      });
    });

    test('Background watchdog stays quiet when updates arrive', () {
      fakeAsync((async) {
        final client = FakeBackgroundLocationClient();
        final clock = TestClock(DateTime(2024, 1, 1));
        final service = TestLocationTrackingService(
          client: client,
          config: _serviceConfig(
            watchdogCheckMinutes: 1,
            noUpdateThresholdSeconds: 60,
            assumeBackground: true,
          ),
          nowProvider: () => clock.now,
        );
        final logs = <String>[];

        runZoned(
          () {
            service.start();
            async.flushMicrotasks();
            client.emit(
              buildRawLocation(
                latitude: 0,
                longitude: 0,
                speed: 2,
                accuracy: 0,
                timestamp: clock.now,
              ),
            );
            async.flushMicrotasks();
            clock.advance(const Duration(seconds: 30));
            async.elapse(const Duration(seconds: 30));
            client.emit(
              buildRawLocation(
                latitude: latDeltaForMeters(10),
                longitude: 0,
                speed: 2,
                accuracy: 0,
                timestamp: clock.now,
              ),
            );
            async.flushMicrotasks();
            clock.advance(const Duration(seconds: 30));
            async.elapse(const Duration(seconds: 30));
            clock.advance(const Duration(seconds: 30));
            async.elapse(const Duration(seconds: 30));
            service.stop();
            async.flushMicrotasks();
          },
          zoneSpecification: ZoneSpecification(
            print: (self, parent, zone, message) {
              logs.add(message);
            },
          ),
        );

        expect(
          logs.any((line) => line.contains('No location updates')),
          isFalse,
        );
      });
    });

    test('Stop disables watchdog', () {
      fakeAsync((async) {
        final client = FakeBackgroundLocationClient();
        final clock = TestClock(DateTime(2024, 1, 1));
        final service = TestLocationTrackingService(
          client: client,
          config: _serviceConfig(
            watchdogCheckMinutes: 1,
            noUpdateThresholdSeconds: 60,
          ),
          nowProvider: () => clock.now,
        );
        final logs = <String>[];

        runZoned(
          () {
            service.start();
            async.flushMicrotasks();
            service.stop();
            async.flushMicrotasks();
            clock.advance(const Duration(minutes: 2));
            async.elapse(const Duration(minutes: 2));
          },
          zoneSpecification: ZoneSpecification(
            print: (self, parent, zone, message) {
              logs.add(message);
            },
          ),
        );

        expect(
          logs.any((line) => line.contains('No location updates')),
          isFalse,
        );
      });
    });

    test('Time jumps do not crash watchdog', () {
      fakeAsync((async) {
        final client = FakeBackgroundLocationClient();
        final clock = TestClock(DateTime(2024, 1, 1, 12));
        final service = TestLocationTrackingService(
          client: client,
          config: _serviceConfig(
            watchdogCheckMinutes: 1,
            noUpdateThresholdSeconds: 60,
          ),
          nowProvider: () => clock.now,
        );

        service.start();
        async.flushMicrotasks();
        clock.now = clock.now.subtract(const Duration(hours: 1));
        async.elapse(const Duration(minutes: 1));
        service.stop();
        async.flushMicrotasks();
      });
    });
  });

  group('LocationTrackingServiceBase logging/errors', () {
    test('Plugin errors are logged without crashing', () async {
      final client = FakeBackgroundLocationClient();
      final clock = TestClock(DateTime(2024, 1, 1));
      final service = TestLocationTrackingService(
        client: client,
        config: _serviceConfig(),
        nowProvider: () => clock.now,
      );

      final logs = await capturePrints(() async {
        await service.start();
        client.emit(
          RawLocationData(
            latitude: 0,
            longitude: 0,
            altitude: 0,
            accuracy: 0,
            bearing: 0,
            speed: 0,
            time: double.nan,
            isMock: false,
          ),
        );
        await Future<void>.delayed(Duration.zero);
        await service.stop();
      });

      expect(
        logs.any((line) => line.contains('Location update failed')),
        isTrue,
      );
    });
  });

  group('Platform-specific services', () {
    test('Android service configures Android interval', () async {
      final client = FakeBackgroundLocationClient();
      final clock = TestClock(DateTime(2024, 1, 1));
      final service = AndroidLocationTrackingService(
        client: client,
        config: _serviceConfig(updateIntervalSeconds: 9),
        nowProvider: () => clock.now,
      );

      await service.start();

      expect(client.androidConfigCalls, 1);
      expect(client.lastIntervalMs, 9000);

      await service.stop();
    });

    test('iOS service does not call Android configuration', () async {
      final client = FakeBackgroundLocationClient();
      final clock = TestClock(DateTime(2024, 1, 1));
      final service = IOSLocationTrackingService(
        client: client,
        config: _serviceConfig(),
        nowProvider: () => clock.now,
      );

      await service.start();

      expect(client.androidConfigCalls, 0);

      await service.stop();
    });
  });
}
