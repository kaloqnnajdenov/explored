import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/location/data/location_tracking_config.dart';
import 'package:explored/features/location/data/models/lat_lng_sample.dart';
import 'package:explored/features/location/data/services/adaptive_tracking_policy.dart';
import 'package:explored/features/location/data/services/background_location_client.dart';

import 'location_test_utils.dart';

LocationTrackingConfig _basePolicyConfig({
  int updateIntervalSeconds = 5,
  double distanceFilterMeters = 10,
  double baseDistanceOffsetMeters = 10,
  double baseDistanceMinMeters = 10,
  double baseDistanceMaxMeters = 50,
  double minSpeedForIntervalMps = 2,
  double speedEmaAlpha = 1,
  double minMovementMeters = 0,
  double accuracyMovementFactor = 0,
  double minMovementConfidence = 0,
  double stillSpeedMaxMps = 0.5,
  double driveSpeedMinMps = 6,
  int stateConsecutiveUpdates = 1,
  int downshiftConsecutiveUpdates = 1,
  int downshiftCooldownSeconds = 0,
  int watchdogCheckMinutes = 15,
  double baseIntervalMinSeconds = 1,
  double baseIntervalMaxSeconds = 120,
  double backgroundIntervalMultiplier = 2,
  double backgroundIntervalFloorSeconds = 5,
  double backgroundIntervalClampMinSeconds = 1,
  double backgroundIntervalMaxSeconds = 300,
  double backgroundDistanceMultiplier = 1.5,
  double backgroundDistanceFloorMeters = 15,
  double backgroundDistanceClampMinMeters = 10,
  double backgroundDistanceMaxMeters = 200,
  int unreliableAccuracyDurationSeconds = 30,
  double poorAccuracyMeters = 50,
  double unreliableMaxRawGapSeconds = 20,
  int unreliableSporadicCount = 2,
  int unreliableRecoveryConsecutiveUpdates = 3,
  int unreliableIntervalSeconds = 8,
  int unreliableIntervalMinSeconds = 5,
  int unreliableIntervalMaxSeconds = 10,
  double unreliableAccuracyFactor = 0.8,
  int reliabilityLogCooldownSeconds = 60,
  double turnHeadingDeltaDegrees = 25,
  int turnDetectionWindowSeconds = 10,
  int turnBoostSeconds = 15,
  double turnBoostIntervalSeconds = 2,
  double turnBoostDistanceMeters = 15,
  double policyChangeDistanceEpsilonMeters = 1,
  double policyChangeIntervalEpsilonSeconds = 1,
  double minRawDeltaSeconds = 0.5,
  double minBearingDistanceMeters = 5,
  int invalidCoordinateLogCooldownSeconds = 60,
}) {
  return LocationTrackingConfig(
    updateIntervalSeconds: updateIntervalSeconds,
    distanceFilterMeters: distanceFilterMeters,
    watchdogCheckMinutes: watchdogCheckMinutes,
    baseDistanceOffsetMeters: baseDistanceOffsetMeters,
    baseDistanceMinMeters: baseDistanceMinMeters,
    baseDistanceMaxMeters: baseDistanceMaxMeters,
    minSpeedForIntervalMps: minSpeedForIntervalMps,
    speedEmaAlpha: speedEmaAlpha,
    minMovementMeters: minMovementMeters,
    accuracyMovementFactor: accuracyMovementFactor,
    minMovementConfidence: minMovementConfidence,
    stillSpeedMaxMps: stillSpeedMaxMps,
    driveSpeedMinMps: driveSpeedMinMps,
    stateConsecutiveUpdates: stateConsecutiveUpdates,
    downshiftConsecutiveUpdates: downshiftConsecutiveUpdates,
    downshiftCooldownSeconds: downshiftCooldownSeconds,
    baseIntervalMinSeconds: baseIntervalMinSeconds,
    baseIntervalMaxSeconds: baseIntervalMaxSeconds,
    backgroundIntervalMultiplier: backgroundIntervalMultiplier,
    backgroundIntervalFloorSeconds: backgroundIntervalFloorSeconds,
    backgroundIntervalClampMinSeconds: backgroundIntervalClampMinSeconds,
    backgroundIntervalMaxSeconds: backgroundIntervalMaxSeconds,
    backgroundDistanceMultiplier: backgroundDistanceMultiplier,
    backgroundDistanceFloorMeters: backgroundDistanceFloorMeters,
    backgroundDistanceClampMinMeters: backgroundDistanceClampMinMeters,
    backgroundDistanceMaxMeters: backgroundDistanceMaxMeters,
    unreliableAccuracyDurationSeconds: unreliableAccuracyDurationSeconds,
    poorAccuracyMeters: poorAccuracyMeters,
    unreliableMaxRawGapSeconds: unreliableMaxRawGapSeconds,
    unreliableSporadicCount: unreliableSporadicCount,
    unreliableRecoveryConsecutiveUpdates: unreliableRecoveryConsecutiveUpdates,
    unreliableIntervalSeconds: unreliableIntervalSeconds,
    unreliableIntervalMinSeconds: unreliableIntervalMinSeconds,
    unreliableIntervalMaxSeconds: unreliableIntervalMaxSeconds,
    unreliableAccuracyFactor: unreliableAccuracyFactor,
    reliabilityLogCooldownSeconds: reliabilityLogCooldownSeconds,
    turnHeadingDeltaDegrees: turnHeadingDeltaDegrees,
    turnDetectionWindowSeconds: turnDetectionWindowSeconds,
    turnBoostSeconds: turnBoostSeconds,
    turnBoostIntervalSeconds: turnBoostIntervalSeconds,
    turnBoostDistanceMeters: turnBoostDistanceMeters,
    policyChangeDistanceEpsilonMeters: policyChangeDistanceEpsilonMeters,
    policyChangeIntervalEpsilonSeconds: policyChangeIntervalEpsilonSeconds,
    minRawDeltaSeconds: minRawDeltaSeconds,
    minBearingDistanceMeters: minBearingDistanceMeters,
    invalidCoordinateLogCooldownSeconds: invalidCoordinateLogCooldownSeconds,
  );
}

AdaptiveTrackingDecision _updatePolicy({
  required AdaptiveTrackingPolicy policy,
  required TestClock clock,
  required RawLocationData raw,
  Duration? advanceBy,
  bool isBackground = false,
}) {
  if (advanceBy != null) {
    clock.advance(advanceBy);
  }
  return policy.updateWithRawLocation(
    raw: raw,
    now: clock.now,
    isBackground: isBackground,
  );
}

RawLocationData _rawAt({
  required DateTime time,
  required double latitude,
  required double longitude,
  double speed = 0,
  double bearing = 0,
  double accuracy = 0,
}) {
  return buildRawLocation(
    latitude: latitude,
    longitude: longitude,
    speed: speed,
    bearing: bearing,
    accuracy: accuracy,
    timestamp: time,
  );
}

void main() {
  group('AdaptiveTrackingPolicy OR semantics', () {
    test('First update always emits', () {
      final logs = <String>[];
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          stillSpeedMaxMps: 100,
          driveSpeedMinMps: 200,
        ),
        log: logs.add,
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      final decision = _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 2,
        ),
      );

      expect(decision.shouldEmit, isTrue);
      expect(decision.reason, 'initial');
      expect(logs.any((line) => line.contains('reason=initial')), isTrue);
    });

    test('Interval trigger emits even if distance small', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          stillSpeedMaxMps: 100,
          driveSpeedMinMps: 200,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 2,
        ),
      );

      final decision = _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 11),
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 11)),
          latitude: latDeltaForMeters(1),
          longitude: 0,
          speed: 2,
        ),
      );

      expect(decision.shouldEmit, isTrue);
      expect(decision.reason, 'interval');
    });

    test('Distance trigger emits even if interval not reached', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          stillSpeedMaxMps: 100,
          driveSpeedMinMps: 200,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 2,
        ),
      );

      final decision = _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 2),
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 2)),
          latitude: latDeltaForMeters(30),
          longitude: 0,
          speed: 2,
        ),
      );

      expect(decision.shouldEmit, isTrue);
      expect(decision.reason, 'distance');
    });

    test('Neither interval nor distance: no emit', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          stillSpeedMaxMps: 100,
          driveSpeedMinMps: 200,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 2,
        ),
      );

      final decision = _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 4),
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 4)),
          latitude: latDeltaForMeters(5),
          longitude: 0,
          speed: 2,
        ),
      );

      expect(decision.shouldEmit, isFalse);
    });

    test('Equal threshold counts as emit', () {
      final config = _basePolicyConfig(
        baseDistanceOffsetMeters: 20,
        baseDistanceMinMeters: 20,
        baseDistanceMaxMeters: 20,
        minSpeedForIntervalMps: 2,
        stillSpeedMaxMps: 100,
        driveSpeedMinMps: 200,
      );
      final policy = AdaptiveTrackingPolicy(
        config: config,
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 2,
        ),
      );

      final decision = _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 10),
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 10)),
          latitude: latDeltaForMeters(20),
          longitude: 0,
          speed: 2,
        ),
      );

      expect(decision.shouldEmit, isTrue);
    });

    test('Below threshold does not emit due to precision drift', () {
      final config = _basePolicyConfig(
        baseDistanceOffsetMeters: 20,
        baseDistanceMinMeters: 20,
        baseDistanceMaxMeters: 20,
        minSpeedForIntervalMps: 2,
        stillSpeedMaxMps: 100,
        driveSpeedMinMps: 200,
      );
      final policy = AdaptiveTrackingPolicy(
        config: config,
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 2,
        ),
      );

      final decision = _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 2),
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 2)),
          latitude: latDeltaForMeters(19.999),
          longitude: 0,
          speed: 2,
        ),
      );

      expect(decision.shouldEmit, isFalse);
    });

    test('Burst updates do not spam emissions', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          stillSpeedMaxMps: 100,
          driveSpeedMinMps: 200,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 2,
        ),
      );

      var emits = 1;
      for (var i = 0; i < 150; i += 1) {
        final decision = _updatePolicy(
          policy: policy,
          clock: clock,
          advanceBy: const Duration(milliseconds: 200),
          raw: _rawAt(
            time: clock.now.add(const Duration(milliseconds: 200)),
            latitude: latDeltaForMeters(2),
            longitude: 0,
            speed: 2,
          ),
        );
        if (decision.shouldEmit) {
          emits += 1;
        }
      }

      expect(emits <= 7, isTrue);
    });

    test('GPS jump emits without crashing', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          stillSpeedMaxMps: 100,
          driveSpeedMinMps: 200,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 2,
        ),
      );

      final decision = _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 1),
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 1)),
          latitude: latDeltaForMeters(5000),
          longitude: 0,
          speed: 2,
        ),
      );

      expect(decision.shouldEmit, isTrue);
    });
  });

  group('AdaptiveTrackingPolicy formatting & logging', () {
    test('Rounds emitted coordinates to 5 decimals', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      final decision = _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 52.520008,
          longitude: 13.404954,
          speed: 2,
        ),
      );

      expect(decision.sample, isNotNull);
      expect(decision.sample!.latitude, 52.52001);
      expect(decision.sample!.longitude, 13.40495);
    });

    test('Invalid coordinates are ignored with warning', () {
      final logs = <String>[];
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(),
        log: logs.add,
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      final decision = _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 200,
          longitude: 0,
        ),
      );

      expect(decision.shouldEmit, isFalse);
      expect(logs.any((line) => line.contains('Invalid coordinate')), isTrue);
    });

    test('NaN coordinates are ignored safely', () {
      final logs = <String>[];
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(),
        log: logs.add,
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      final decision = _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: double.nan,
          longitude: 0,
        ),
      );

      expect(decision.shouldEmit, isFalse);
      expect(
        logs.where((line) => line.contains('Invalid coordinate')).length,
        1,
      );
    });

    test('Emission log includes timestamp, rounded coords, and reason', () {
      final logs = <String>[];
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(),
        log: logs.add,
      );
      final clock = TestClock(DateTime(2024, 1, 1, 12, 0, 0));

      _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 1.123456,
          longitude: 2.654321,
          speed: 2,
        ),
      );

      final logLine =
          logs.firstWhere((line) => line.contains('Location update'));
      expect(logLine.contains('lat=1.12346'), isTrue);
      expect(logLine.contains('lng=2.65432'), isTrue);
      expect(logLine.contains('reason=initial'), isTrue);
      expect(logLine.contains('2024-01-01T12:00:00.000'), isTrue);
    });
  });

  group('AdaptiveTrackingPolicy adaptive mapping', () {
    test('Policy clamps at low speed', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          minSpeedForIntervalMps: 0.5,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      final decision = _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 0,
          accuracy: 0,
        ),
      );

      expect(decision.policy.distanceFilterMeters, closeTo(10, 0.1));
      expect(
        decision.policy.interval.inSeconds.toDouble(),
        closeTo(20, 0.5),
      );
    });

    test('Policy at walking speed', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          minSpeedForIntervalMps: 0.5,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      final decision = _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 1.5,
          accuracy: 0,
        ),
      );

      expect(decision.policy.distanceFilterMeters, closeTo(13, 0.2));
      expect(
        decision.policy.interval.inMilliseconds / 1000,
        closeTo(8.7, 0.4),
      );
    });

    test('Policy at driving speed', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          minSpeedForIntervalMps: 0.5,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      final decision = _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 15,
          accuracy: 0,
        ),
      );

      expect(decision.policy.distanceFilterMeters, closeTo(40, 0.5));
      expect(
        decision.policy.interval.inMilliseconds / 1000,
        closeTo(2.7, 0.3),
      );
    });

    test('Extreme speed clamps', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          minSpeedForIntervalMps: 0.5,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      final decision = _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 80,
          accuracy: 0,
        ),
      );

      expect(decision.policy.distanceFilterMeters, closeTo(50, 0.1));
      expect(decision.policy.interval.inSeconds, 1);
    });

    test('Policy change logs are rate-limited', () {
      final logs = <String>[];
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          minSpeedForIntervalMps: 0.5,
          policyChangeDistanceEpsilonMeters: 5,
          policyChangeIntervalEpsilonSeconds: 5,
        ),
        log: logs.add,
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      for (var i = 0; i < 20; i += 1) {
        _updatePolicy(
          policy: policy,
          clock: clock,
          advanceBy: const Duration(seconds: 1),
          raw: _rawAt(
            time: clock.now.add(const Duration(seconds: 1)),
            latitude: 0,
            longitude: 0,
            speed: 1.0 + (i * 0.05),
            accuracy: 0,
          ),
        );
      }

      final policyLogs =
          logs.where((line) => line.startsWith('Policy update')).toList();
      expect(policyLogs.length <= 4, isTrue);
    });
  });

  group('AdaptiveTrackingPolicy time heartbeat', () {
    test('Interval emissions occur even without distance movement', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          baseDistanceOffsetMeters: 20,
          baseDistanceMinMeters: 20,
          baseDistanceMaxMeters: 20,
          minSpeedForIntervalMps: 2,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      var emits = 0;
      for (var i = 0; i < 31; i += 1) {
        final decision = _updatePolicy(
          policy: policy,
          clock: clock,
          advanceBy: i == 0 ? null : const Duration(seconds: 1),
          raw: _rawAt(
            time: clock.now.add(Duration(seconds: i == 0 ? 0 : 1)),
            latitude: latDeltaForMeters(1) * (i / 30),
            longitude: 0,
            speed: 0,
            accuracy: 0,
          ),
        );
        if (decision.shouldEmit) {
          emits += 1;
          expect(decision.reason != 'distance', isTrue);
        }
      }

      expect(emits >= 3, isTrue);
    });

    test('Interval emits with heavy jitter and poor accuracy', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          baseDistanceOffsetMeters: 20,
          baseDistanceMinMeters: 20,
          baseDistanceMaxMeters: 20,
          minSpeedForIntervalMps: 2,
          minMovementMeters: 5,
          accuracyMovementFactor: 0.5,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      var emits = 0;
      for (var i = 0; i < 25; i += 1) {
        final decision = _updatePolicy(
          policy: policy,
          clock: clock,
          advanceBy: i == 0 ? null : const Duration(seconds: 1),
          raw: _rawAt(
            time: clock.now.add(Duration(seconds: i == 0 ? 0 : 1)),
            latitude: latDeltaForMeters(2),
            longitude: 0,
            speed: 0,
            accuracy: 50,
          ),
        );
        if (decision.shouldEmit) {
          emits += 1;
        }
      }

      expect(emits >= 2, isTrue);
    });

    test('Slow traffic jam continues interval emissions', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          baseDistanceOffsetMeters: 10,
          baseDistanceMinMeters: 10,
          baseDistanceMaxMeters: 10,
          minSpeedForIntervalMps: 0.5,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      var emits = 0;
      for (var i = 0; i < 61; i += 1) {
        final decision = _updatePolicy(
          policy: policy,
          clock: clock,
          advanceBy: i == 0 ? null : const Duration(seconds: 1),
          raw: _rawAt(
            time: clock.now.add(Duration(seconds: i == 0 ? 0 : 1)),
            latitude: latDeltaForMeters(0.3) * i,
            longitude: 0,
            speed: 0.3,
            accuracy: 0,
          ),
        );
        if (decision.shouldEmit) {
          emits += 1;
        }
      }

      expect(emits >= 2, isTrue);
    });
  });

  group('AdaptiveTrackingPolicy hysteresis', () {
    test('No rapid switching around walk/drive boundary', () {
      final logs = <String>[];
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          minSpeedForIntervalMps: 0.5,
          stateConsecutiveUpdates: 3,
          downshiftConsecutiveUpdates: 4,
          downshiftCooldownSeconds: 30,
          stillSpeedMaxMps: 0.5,
          driveSpeedMinMps: 6,
        ),
        log: logs.add,
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      for (var i = 0; i < 3; i += 1) {
        _updatePolicy(
          policy: policy,
          clock: clock,
          advanceBy: const Duration(seconds: 1),
          raw: _rawAt(
            time: clock.now.add(const Duration(seconds: 1)),
            latitude: 0,
            longitude: 0,
            speed: 4,
            accuracy: 0,
          ),
        );
      }

      var transitions = 0;
      var lastState = policy.state;
      for (var i = 0; i < 60; i += 1) {
        final speed = i.isEven ? 5.8 : 6.2;
        final decision = _updatePolicy(
          policy: policy,
          clock: clock,
          advanceBy: const Duration(seconds: 1),
          raw: _rawAt(
            time: clock.now.add(const Duration(seconds: 1)),
            latitude: 0,
            longitude: 0,
            speed: speed,
            accuracy: 0,
          ),
        );
        if (decision.policy.state != lastState) {
          transitions += 1;
          lastState = decision.policy.state;
        }
      }

      expect(transitions <= 1, isTrue);
    });

    test('Fast upshift and slow downshift with cooldown', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          minSpeedForIntervalMps: 0.5,
          stateConsecutiveUpdates: 2,
          downshiftConsecutiveUpdates: 4,
          downshiftCooldownSeconds: 30,
          stillSpeedMaxMps: 0.5,
          driveSpeedMinMps: 6,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 0.3,
          accuracy: 0,
        ),
      );

      for (var i = 0; i < 2; i += 1) {
        _updatePolicy(
          policy: policy,
          clock: clock,
          advanceBy: const Duration(seconds: 1),
          raw: _rawAt(
            time: clock.now.add(const Duration(seconds: 1)),
            latitude: 0,
            longitude: 0,
            speed: 10,
            accuracy: 0,
          ),
        );
      }

      expect(policy.state, AdaptiveTrackingState.drive);

      for (var i = 0; i < 10; i += 1) {
        _updatePolicy(
          policy: policy,
          clock: clock,
          advanceBy: const Duration(seconds: 1),
          raw: _rawAt(
            time: clock.now.add(const Duration(seconds: 1)),
            latitude: 0,
            longitude: 0,
            speed: 0.3,
            accuracy: 0,
          ),
        );
      }

      expect(policy.state, AdaptiveTrackingState.drive);

      for (var i = 0; i < 30; i += 1) {
        _updatePolicy(
          policy: policy,
          clock: clock,
          advanceBy: const Duration(seconds: 1),
          raw: _rawAt(
            time: clock.now.add(const Duration(seconds: 1)),
            latitude: 0,
            longitude: 0,
            speed: 0.3,
            accuracy: 0,
          ),
        );
      }

      expect(policy.state, isNot(AdaptiveTrackingState.drive));
    });

    test('Sporadic high-speed outlier does not permanently upshift', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          minSpeedForIntervalMps: 0.5,
          stateConsecutiveUpdates: 3,
          downshiftConsecutiveUpdates: 3,
          downshiftCooldownSeconds: 10,
          stillSpeedMaxMps: 0.5,
          driveSpeedMinMps: 6,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      for (var i = 0; i < 3; i += 1) {
        _updatePolicy(
          policy: policy,
          clock: clock,
          advanceBy: const Duration(seconds: 1),
          raw: _rawAt(
            time: clock.now.add(const Duration(seconds: 1)),
            latitude: 0,
            longitude: 0,
            speed: 3,
            accuracy: 0,
          ),
        );
      }
      expect(policy.state, AdaptiveTrackingState.walk);

      _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 1),
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 1)),
          latitude: 0,
          longitude: 0,
          speed: 10,
          accuracy: 0,
        ),
      );

      _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 1),
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 1)),
          latitude: 0,
          longitude: 0,
          speed: 3,
          accuracy: 0,
        ),
      );

      expect(policy.state, AdaptiveTrackingState.walk);
    });
  });

  group('AdaptiveTrackingPolicy turn detection', () {
    test('Heading change triggers turn boost', () {
      final logs = <String>[];
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          minSpeedForIntervalMps: 0.5,
        ),
        log: logs.add,
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 4,
          bearing: 0,
          accuracy: 0,
        ),
      );

      final decision = _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 5),
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 5)),
          latitude: latDeltaForMeters(10),
          longitude: 0,
          speed: 4,
          bearing: 40,
          accuracy: 0,
        ),
      );

      expect(decision.policy.interval.inSeconds, lessThanOrEqualTo(2));
      expect(decision.policy.distanceFilterMeters, lessThanOrEqualTo(15));
      expect(logs.any((line) => line.contains('Turn boost started')), isTrue);
    });

    test('Bearing-based turn detection works without heading', () {
      final logs = <String>[];
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          minSpeedForIntervalMps: 0.5,
        ),
        log: logs.add,
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      final start = _rawAt(
        time: clock.now,
        latitude: 0,
        longitude: 0,
        speed: 0,
        bearing: double.nan,
        accuracy: 0,
      );
      _updatePolicy(policy: policy, clock: clock, raw: start);

      final north = _rawAt(
        time: clock.now.add(const Duration(seconds: 5)),
        latitude: latDeltaForMeters(20),
        longitude: 0,
        speed: 0,
        bearing: double.nan,
        accuracy: 0,
      );
      _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 5),
        raw: north,
      );

      final east = _rawAt(
        time: clock.now.add(const Duration(seconds: 5)),
        latitude: latDeltaForMeters(20),
        longitude: lngDeltaForMeters(20),
        speed: 0,
        bearing: double.nan,
        accuracy: 0,
      );
      final decision = _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 5),
        raw: east,
      );

      expect(decision.reason, 'turn');
      expect(logs.any((line) => line.contains('Turn boost started')), isTrue);
    });

    test('Turn boost expires and policy returns', () {
      final logs = <String>[];
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          minSpeedForIntervalMps: 0.5,
          turnBoostSeconds: 5,
        ),
        log: logs.add,
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 4,
          bearing: 0,
          accuracy: 0,
        ),
      );

      _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 2),
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 2)),
          latitude: latDeltaForMeters(10),
          longitude: 0,
          speed: 4,
          bearing: 50,
          accuracy: 0,
        ),
      );

      _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 6),
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 6)),
          latitude: latDeltaForMeters(20),
          longitude: 0,
          speed: 4,
          bearing: 50,
          accuracy: 0,
        ),
      );

      expect(logs.any((line) => line.contains('Turn boost ended')), isTrue);
    });

    test('No false-positive turn from jitter in still state', () {
      final logs = <String>[];
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          minSpeedForIntervalMps: 0.5,
          stillSpeedMaxMps: 0.6,
        ),
        log: logs.add,
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      for (var i = 0; i < 5; i += 1) {
        _updatePolicy(
          policy: policy,
          clock: clock,
          advanceBy: const Duration(seconds: 1),
          raw: _rawAt(
            time: clock.now.add(const Duration(seconds: 1)),
            latitude: latDeltaForMeters(1),
            longitude: 0,
            speed: 0,
            bearing: 10,
            accuracy: 30,
          ),
        );
      }

      expect(logs.any((line) => line.contains('Turn boost started')), isFalse);
    });

    test('Turn triggers immediate emit', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          minSpeedForIntervalMps: 0.5,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 4,
          bearing: 0,
          accuracy: 0,
        ),
      );

      final decision = _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 1),
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 1)),
          latitude: latDeltaForMeters(2),
          longitude: 0,
          speed: 4,
          bearing: 40,
          accuracy: 0,
        ),
      );

      expect(decision.shouldEmit, isTrue);
      expect(decision.reason, 'turn');
    });
  });

  group('AdaptiveTrackingPolicy background bias', () {
    test('Background multiplies interval and distance', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          minSpeedForIntervalMps: 0.5,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));
      final baseDecision = _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 2,
          accuracy: 0,
        ),
      );

      final backgroundDecision = _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 1),
        isBackground: true,
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 1)),
          latitude: 0,
          longitude: 0,
          speed: 2,
          accuracy: 0,
        ),
      );

      final baseIntervalSeconds =
          baseDecision.policy.interval.inMilliseconds / 1000;
      final baseDistance = baseDecision.policy.distanceFilterMeters;
      final expectedInterval = baseIntervalSeconds * 2 >= 5
          ? baseIntervalSeconds * 2
          : 5;
      final expectedDistance = baseDistance * 1.5 >= 15
          ? baseDistance * 1.5
          : 15;

      expect(
        backgroundDecision.policy.interval.inMilliseconds / 1000,
        closeTo(expectedInterval, 0.2),
      );
      expect(
        backgroundDecision.policy.distanceFilterMeters,
        closeTo(expectedDistance, 0.5),
      );
    });

    test('Turn boost still applies in background', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          minSpeedForIntervalMps: 0.5,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      _updatePolicy(
        policy: policy,
        clock: clock,
        isBackground: true,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 4,
          bearing: 0,
          accuracy: 0,
        ),
      );

      final decision = _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 5),
        isBackground: true,
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 5)),
          latitude: latDeltaForMeters(10),
          longitude: 0,
          speed: 4,
          bearing: 50,
          accuracy: 0,
        ),
      );

      expect(decision.policy.interval.inSeconds, lessThanOrEqualTo(2));
      expect(decision.policy.distanceFilterMeters, lessThanOrEqualTo(15));
    });

    test('Switching foreground/background preserves state', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          minSpeedForIntervalMps: 0.5,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 10,
          accuracy: 0,
        ),
      );

      final backgroundDecision = _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 1),
        isBackground: true,
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 1)),
          latitude: 0,
          longitude: 0,
          speed: 10,
          accuracy: 0,
        ),
      );

      expect(backgroundDecision.policy.state, AdaptiveTrackingState.drive);
    });
  });

  group('AdaptiveTrackingPolicy reliability', () {
    test('Enters UNRELIABLE after sustained poor accuracy', () {
      final logs = <String>[];
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          minSpeedForIntervalMps: 0.5,
          unreliableAccuracyDurationSeconds: 30,
          poorAccuracyMeters: 50,
        ),
        log: logs.add,
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      for (var i = 0; i < 4; i += 1) {
        _updatePolicy(
          policy: policy,
          clock: clock,
          advanceBy: const Duration(seconds: 10),
          raw: _rawAt(
            time: clock.now.add(const Duration(seconds: 10)),
            latitude: 0,
            longitude: 0,
            speed: 1,
            accuracy: 80,
          ),
        );
      }

      expect(policy.state, AdaptiveTrackingState.unreliable);
      expect(logs.any((line) => line.contains('GPS accuracy poor')), isTrue);
    });

    test('GPS poor accuracy warning is not spammed', () {
      final logs = <String>[];
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          minSpeedForIntervalMps: 0.5,
          unreliableAccuracyDurationSeconds: 1,
          poorAccuracyMeters: 50,
        ),
        log: logs.add,
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      for (var i = 0; i < 10; i += 1) {
        _updatePolicy(
          policy: policy,
          clock: clock,
          advanceBy: const Duration(seconds: 2),
          raw: _rawAt(
            time: clock.now.add(const Duration(seconds: 2)),
            latitude: 0,
            longitude: 0,
            speed: 1,
            accuracy: 80,
          ),
        );
      }

      expect(
        logs.where((line) => line.contains('GPS accuracy poor')).length,
        1,
      );
    });

    test('UNRELIABLE suppresses noisy emissions', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          minSpeedForIntervalMps: 0.5,
          unreliableAccuracyDurationSeconds: 1,
          poorAccuracyMeters: 50,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 2,
          accuracy: 80,
        ),
      );

      _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 2),
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 2)),
          latitude: 0,
          longitude: 0,
          speed: 2,
          accuracy: 80,
        ),
      );

      expect(policy.state, AdaptiveTrackingState.unreliable);

      final decision = _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 10),
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 10)),
          latitude: latDeltaForMeters(5),
          longitude: 0,
          speed: 2,
          accuracy: 80,
        ),
      );

      expect(decision.shouldEmit, isFalse);
    });

    test('Recovers from UNRELIABLE when accuracy improves', () {
      final logs = <String>[];
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          minSpeedForIntervalMps: 0.5,
          unreliableAccuracyDurationSeconds: 1,
          poorAccuracyMeters: 50,
        ),
        log: logs.add,
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 2,
          accuracy: 80,
        ),
      );

      _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 2),
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 2)),
          latitude: 0,
          longitude: 0,
          speed: 2,
          accuracy: 80,
        ),
      );

      expect(policy.state, AdaptiveTrackingState.unreliable);

      for (var i = 0; i < 3; i += 1) {
        _updatePolicy(
          policy: policy,
          clock: clock,
          advanceBy: const Duration(seconds: 1),
          raw: _rawAt(
            time: clock.now.add(const Duration(seconds: 1)),
            latitude: 0,
            longitude: 0,
            speed: 2,
            accuracy: 10,
          ),
        );
      }

      expect(policy.state, isNot(AdaptiveTrackingState.unreliable));
      expect(logs.any((line) => line.contains('GPS accuracy recovered')), isTrue);
    });

    test('Sporadic updates trigger unreliable warning', () {
      final logs = <String>[];
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          minSpeedForIntervalMps: 0.5,
          unreliableMaxRawGapSeconds: 2,
          unreliableSporadicCount: 2,
        ),
        log: logs.add,
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 0,
          speed: 2,
          accuracy: 0,
        ),
      );

      _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 3),
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 3)),
          latitude: latDeltaForMeters(10),
          longitude: 0,
          speed: 2,
          accuracy: 0,
        ),
      );

      _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 3),
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 3)),
          latitude: latDeltaForMeters(20),
          longitude: 0,
          speed: 2,
          accuracy: 0,
        ),
      );

      expect(logs.any((line) => line.contains('Location stream unreliable')), isTrue);
    });
  });

  group('AdaptiveTrackingPolicy edge cases', () {
    test('dt=0 does not crash', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));
      final raw = _rawAt(
        time: clock.now,
        latitude: 0,
        longitude: 0,
        speed: 1,
      );

      _updatePolicy(policy: policy, clock: clock, raw: raw);
      expect(
        () => _updatePolicy(policy: policy, clock: clock, raw: raw),
        returnsNormally,
      );
    });

    test('Antimeridian crossing does not emit huge distance', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          baseDistanceOffsetMeters: 1000,
          baseDistanceMinMeters: 1000,
          baseDistanceMaxMeters: 1000,
          minSpeedForIntervalMps: 1,
          stillSpeedMaxMps: 100,
          driveSpeedMinMps: 200,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 0,
          longitude: 179.999,
          speed: 1,
        ),
      );

      final decision = _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 1),
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 1)),
          latitude: 0,
          longitude: -179.999,
          speed: 1,
        ),
      );

      expect(decision.shouldEmit, isFalse);
    });

    test('Near poles remains stable', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          baseDistanceOffsetMeters: 1000,
          baseDistanceMinMeters: 1000,
          baseDistanceMaxMeters: 1000,
          minSpeedForIntervalMps: 1,
          stillSpeedMaxMps: 100,
          driveSpeedMinMps: 200,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      _updatePolicy(
        policy: policy,
        clock: clock,
        raw: _rawAt(
          time: clock.now,
          latitude: 89.999,
          longitude: 0,
          speed: 1,
        ),
      );

      final decision = _updatePolicy(
        policy: policy,
        clock: clock,
        advanceBy: const Duration(seconds: 1),
        raw: _rawAt(
          time: clock.now.add(const Duration(seconds: 1)),
          latitude: 89.999,
          longitude: lngDeltaForMeters(20, atLatitude: 89.999),
          speed: 1,
        ),
      );

      expect(decision.shouldEmit, isFalse);
    });

    test('Rapid emissions keep rounding to 5 decimals', () {
      final policy = AdaptiveTrackingPolicy(
        config: _basePolicyConfig(
          baseDistanceOffsetMeters: 1,
          baseDistanceMinMeters: 1,
          baseDistanceMaxMeters: 1,
          minSpeedForIntervalMps: 10,
          baseIntervalMinSeconds: 1,
          baseIntervalMaxSeconds: 1,
        ),
        log: (_) {},
      );
      final clock = TestClock(DateTime(2024, 1, 1));

      final samples = <LatLngSample>[];
      for (var i = 0; i < 5; i += 1) {
        final decision = _updatePolicy(
          policy: policy,
          clock: clock,
          advanceBy: const Duration(seconds: 1),
          raw: _rawAt(
            time: clock.now.add(const Duration(seconds: 1)),
            latitude: 10.123456 + i / 100000,
            longitude: 20.654321 + i / 100000,
            speed: 10,
          ),
        );
        if (decision.sample != null) {
          samples.add(decision.sample!);
        }
      }

      for (final sample in samples) {
        final latScaled = sample.latitude * 100000;
        final lngScaled = sample.longitude * 100000;
        expect((latScaled - latScaled.round()).abs(), lessThan(1e-6));
        expect((lngScaled - lngScaled.round()).abs(), lessThan(1e-6));
      }
    });
  });
}
