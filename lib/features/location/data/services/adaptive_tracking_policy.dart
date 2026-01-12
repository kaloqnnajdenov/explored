import 'dart:math' as math;

import '../location_tracking_config.dart';
import '../models/lat_lng_sample.dart';
import 'background_location_client.dart';

/// High-level motion buckets used by the adaptive tracking policy.
enum AdaptiveTrackingState {
  still,
  walk,
  drive,
  unreliable,
}

/// Snapshot of the current adaptive policy output.
class AdaptiveTrackingPolicySnapshot {
  const AdaptiveTrackingPolicySnapshot({
    required this.interval,
    required this.distanceFilterMeters,
    required this.state,
    required this.smoothedSpeedMps,
    required this.isBackground,
  });

  final Duration interval;
  final double distanceFilterMeters;
  final AdaptiveTrackingState state;
  final double smoothedSpeedMps;
  final bool isBackground;
}

/// Outcome of a raw location update after applying the adaptive policy.
class AdaptiveTrackingDecision {
  const AdaptiveTrackingDecision({
    required this.shouldEmit,
    required this.sample,
    required this.policy,
    required this.reason,
  });

  final bool shouldEmit;
  final LatLngSample? sample;
  final AdaptiveTrackingPolicySnapshot policy;
  final String reason;
}

/// Adaptive tracking policy that smooths speed, applies hysteresis, and emits.
class AdaptiveTrackingPolicy {
  AdaptiveTrackingPolicy({
    required this.config,
    required this.log,
  });

  final LocationTrackingConfig config;
  final void Function(String message) log;

  RawLocationData? _lastRaw;
  DateTime? _lastRawAt;
  DateTime? _lastEmitAt;
  _GeoPoint? _lastEmitPoint;
  double _smoothedSpeedMps = 0.0;
  AdaptiveTrackingState _state = AdaptiveTrackingState.still;
  AdaptiveTrackingState? _pendingState;
  int _pendingCount = 0;
  DateTime _lastStateChangeAt = DateTime.fromMillisecondsSinceEpoch(0);
  Duration _poorAccuracyDuration = Duration.zero;
  int _sporadicCount = 0;
  DateTime? _lastStreamWarningAt;
  DateTime? _turnBoostUntil;
  double? _lastHeading;
  DateTime? _lastHeadingAt;
  double? _lastAccuracyMeters;
  AdaptiveTrackingPolicySnapshot? _lastPolicy;
  DateTime? _lastInvalidCoordinateLogAt;
  bool _wasTurnBoostActive = false;

  AdaptiveTrackingState get state => _state;

  void reset() {
    _lastRaw = null;
    _lastRawAt = null;
    _lastEmitAt = null;
    _lastEmitPoint = null;
    _smoothedSpeedMps = 0.0;
    _state = AdaptiveTrackingState.still;
    _pendingState = null;
    _pendingCount = 0;
    _lastStateChangeAt = DateTime.fromMillisecondsSinceEpoch(0);
    _poorAccuracyDuration = Duration.zero;
    _sporadicCount = 0;
    _lastStreamWarningAt = null;
    _turnBoostUntil = null;
    _lastHeading = null;
    _lastHeadingAt = null;
    _lastAccuracyMeters = null;
    _lastPolicy = null;
    _lastInvalidCoordinateLogAt = null;
    _wasTurnBoostActive = false;
  }

  AdaptiveTrackingDecision updateWithRawLocation({
    required RawLocationData raw,
    required DateTime now,
    required bool isBackground,
  }) {
    if (!_isValidCoordinate(raw.latitude, raw.longitude)) {
      _logWithCooldown(
        message: 'Invalid coordinate received; update ignored.',
        now: now,
        lastLog: _lastInvalidCoordinateLogAt,
        updateLast: (value) => _lastInvalidCoordinateLogAt = value,
        cooldownSeconds: config.invalidCoordinateLogCooldownSeconds,
      );
      final policy = _lastPolicy ??
          _computePolicy(
            isBackground: isBackground,
            turnBoostActive: false,
          );
      return AdaptiveTrackingDecision(
        shouldEmit: false,
        sample: null,
        policy: policy,
        reason: 'invalid',
      );
    }
    final timestamp = _timestampFor(raw, now);
    final currentPoint = _GeoPoint(raw.latitude, raw.longitude);
    final lastPoint = _lastRaw == null
        ? null
        : _GeoPoint(_lastRaw!.latitude, _lastRaw!.longitude);
    final dtSeconds = _deltaSeconds(_lastRawAt, now);
    final distanceRaw =
        lastPoint == null ? 0.0 : haversineMeters(lastPoint, currentPoint);
    final accuracyMeters = _normalizeAccuracy(raw.accuracy);
    final noiseThreshold = _noiseThresholdMeters(accuracyMeters);
    final distanceForSpeed = distanceRaw < noiseThreshold ? 0.0 : distanceRaw;
    final movementConfidence =
        _movementConfidence(distanceForSpeed, accuracyMeters);

    final derivedSpeed = dtSeconds <= 0
        ? 0.0
        : distanceForSpeed / math.max(dtSeconds, config.minRawDeltaSeconds);
    final rawSpeed = _normalizeSpeed(raw.speed);
    var measuredSpeed = rawSpeed > 0 ? rawSpeed : derivedSpeed;
    measuredSpeed = _clampDouble(
      measuredSpeed,
      0.0,
      config.speedMaxMetersPerSecond,
    );
    if (movementConfidence < config.minMovementConfidence) {
      measuredSpeed = 0.0;
    } else {
      measuredSpeed *= movementConfidence;
    }
    _smoothedSpeedMps = _ema(
      previous: _smoothedSpeedMps,
      value: measuredSpeed,
      alpha: config.speedEmaAlpha,
      seed: _lastRawAt == null,
    );

    final unreliableCondition = _updateReliability(
      accuracyMeters: accuracyMeters,
      dtSeconds: dtSeconds,
      now: now,
    );
    final previousState = _state;
    final candidateState = _candidateState(movementConfidence);
    _updateState(
      candidate: candidateState,
      now: now,
      unreliable: unreliableCondition,
    );
    final stateChanged = _state != previousState;
    final stateUpShift = _isHigherDetail(_state, previousState);

    final turnDetected = _detectTurn(
      raw: raw,
      now: now,
      lastPoint: lastPoint,
      currentPoint: currentPoint,
      distanceRaw: distanceRaw,
    );
    if (turnDetected) {
      _turnBoostUntil = now.add(
        Duration(seconds: config.turnBoostSeconds),
      );
    }
    final turnBoostActive =
        _turnBoostUntil != null && now.isBefore(_turnBoostUntil!);
    if (!_wasTurnBoostActive && turnBoostActive) {
      log('Turn boost started.');
    } else if (_wasTurnBoostActive && !turnBoostActive) {
      log('Turn boost ended.');
    }
    _wasTurnBoostActive = turnBoostActive;

    final policy = _computePolicy(
      isBackground: isBackground,
      turnBoostActive: turnBoostActive,
    );
    _maybeLogPolicyChange(
      policy: policy,
      now: now,
      stateChanged: stateChanged,
      turnBoostActive: turnBoostActive,
    );

    final decision = _decideEmission(
      policy: policy,
      currentPoint: currentPoint,
      now: now,
      timestamp: timestamp,
      accuracyMeters: accuracyMeters,
      stateUpShift: stateUpShift,
      turnDetected: turnDetected,
    );
    if (decision.shouldEmit && decision.sample != null) {
      _lastEmitAt = now;
      _lastEmitPoint = currentPoint;
      final sample = decision.sample!;
      log(
        'Location update ${sample.timestamp.toIso8601String()} '
        'lat=${sample.latitude.toStringAsFixed(5)} '
        'lng=${sample.longitude.toStringAsFixed(5)} '
        'state=${_stateLabel(_state)} reason=${decision.reason}',
      );
    }

    _lastRaw = raw;
    _lastRawAt = now;
    _lastAccuracyMeters = accuracyMeters;

    return decision;
  }

  AdaptiveTrackingState _candidateState(double movementConfidence) {
    if (movementConfidence < config.minMovementConfidence) {
      return AdaptiveTrackingState.still;
    }
    if (_smoothedSpeedMps <= config.stillSpeedMaxMps) {
      return AdaptiveTrackingState.still;
    }
    if (_smoothedSpeedMps < config.driveSpeedMinMps) {
      return AdaptiveTrackingState.walk;
    }
    return AdaptiveTrackingState.drive;
  }

  void _updateState({
    required AdaptiveTrackingState candidate,
    required DateTime now,
    required bool unreliable,
  }) {
    if (unreliable) {
      _setState(AdaptiveTrackingState.unreliable, now);
      return;
    }
    if (_state == AdaptiveTrackingState.unreliable) {
      _attemptTransition(
        candidate: candidate,
        now: now,
        requiredUpdates: config.unreliableRecoveryConsecutiveUpdates,
        enforceCooldown: false,
      );
      return;
    }
    _attemptTransition(
      candidate: candidate,
      now: now,
      requiredUpdates: config.stateConsecutiveUpdates,
      enforceCooldown: true,
    );
  }

  void _attemptTransition({
    required AdaptiveTrackingState candidate,
    required DateTime now,
    required int requiredUpdates,
    required bool enforceCooldown,
  }) {
    if (candidate == _state) {
      _pendingState = null;
      _pendingCount = 0;
      return;
    }
    if (_pendingState != candidate) {
      _pendingState = candidate;
      _pendingCount = 1;
      return;
    }
    _pendingCount += 1;

    final isDownshift = _isDownshift(candidate, _state);
    final threshold =
        isDownshift ? config.downshiftConsecutiveUpdates : requiredUpdates;
    if (_pendingCount < threshold) {
      return;
    }
    if (enforceCooldown &&
        isDownshift &&
        now.difference(_lastStateChangeAt) <
            Duration(seconds: config.downshiftCooldownSeconds)) {
      return;
    }
    _setState(candidate, now);
  }

  void _setState(AdaptiveTrackingState next, DateTime now) {
    if (_state == next) {
      return;
    }
    final previous = _state;
    _state = next;
    _lastStateChangeAt = now;
    _pendingState = null;
    _pendingCount = 0;
    if (previous == AdaptiveTrackingState.unreliable &&
        next != AdaptiveTrackingState.unreliable) {
      log('GPS accuracy recovered.');
    }
    if (next == AdaptiveTrackingState.unreliable &&
        previous != AdaptiveTrackingState.unreliable) {
      log('GPS accuracy poor.');
    }
  }

  bool _isHigherDetail(
    AdaptiveTrackingState next,
    AdaptiveTrackingState previous,
  ) {
    return _stateRank(next) > _stateRank(previous);
  }

  bool _isDownshift(
    AdaptiveTrackingState candidate,
    AdaptiveTrackingState current,
  ) {
    return _stateRank(candidate) < _stateRank(current);
  }

  int _stateRank(AdaptiveTrackingState state) {
    switch (state) {
      case AdaptiveTrackingState.unreliable:
        return -1;
      case AdaptiveTrackingState.still:
        return 0;
      case AdaptiveTrackingState.walk:
        return 1;
      case AdaptiveTrackingState.drive:
        return 2;
    }
  }

  bool _updateReliability({
    required double? accuracyMeters,
    required double dtSeconds,
    required DateTime now,
  }) {
    final accuracyPoor =
        accuracyMeters != null && accuracyMeters > config.poorAccuracyMeters;
    if (accuracyPoor) {
      _poorAccuracyDuration +=
          Duration(milliseconds: (dtSeconds * 1000).round());
    } else {
      _poorAccuracyDuration = Duration.zero;
    }

    final sporadic = dtSeconds > config.unreliableMaxRawGapSeconds;
    if (sporadic) {
      _sporadicCount += 1;
      if (_sporadicCount >= config.unreliableSporadicCount) {
        _logWithCooldown(
          message: 'Location stream unreliable.',
          now: now,
          lastLog: _lastStreamWarningAt,
          updateLast: (value) => _lastStreamWarningAt = value,
        );
      }
    } else {
      _sporadicCount = 0;
    }

    final accuracyUnreliable = _poorAccuracyDuration >=
        Duration(seconds: config.unreliableAccuracyDurationSeconds);
    final streamUnreliable =
        _sporadicCount >= config.unreliableSporadicCount;
    return accuracyUnreliable || streamUnreliable;
  }

  bool _detectTurn({
    required RawLocationData raw,
    required DateTime now,
    required _GeoPoint? lastPoint,
    required _GeoPoint currentPoint,
    required double distanceRaw,
  }) {
    if (_smoothedSpeedMps <= config.stillSpeedMaxMps) {
      return false;
    }
    final heading = _resolveHeading(
      raw: raw,
      lastPoint: lastPoint,
      currentPoint: currentPoint,
      distanceRaw: distanceRaw,
    );
    if (heading == null) {
      return false;
    }

    var turnDetected = false;
    if (_lastHeading != null &&
        _lastHeadingAt != null &&
        now.difference(_lastHeadingAt!).inSeconds <=
            config.turnDetectionWindowSeconds) {
      final delta = headingDeltaDegrees(heading, _lastHeading!);
      if (delta >= config.turnHeadingDeltaDegrees) {
        turnDetected = true;
      }
    }

    _lastHeading = heading;
    _lastHeadingAt = now;
    return turnDetected;
  }

  double? _resolveHeading({
    required RawLocationData raw,
    required _GeoPoint? lastPoint,
    required _GeoPoint currentPoint,
    required double distanceRaw,
  }) {
    final rawHeading = raw.bearing;
    if (rawHeading.isFinite &&
        rawHeading >= 0 &&
        rawHeading <= 360 &&
        raw.speed > 0) {
      return rawHeading;
    }
    if (lastPoint == null ||
        distanceRaw < config.minBearingDistanceMeters) {
      return null;
    }
    return bearingDegrees(lastPoint, currentPoint);
  }

  AdaptiveTrackingPolicySnapshot _computePolicy({
    required bool isBackground,
    required bool turnBoostActive,
  }) {
    final baseDistance = _clampDouble(
      config.baseDistanceOffsetMeters +
          _smoothedSpeedMps * config.baseDistanceSpeedFactor,
      config.baseDistanceMinMeters,
      config.baseDistanceMaxMeters,
    );
    final speedForInterval =
        math.max(_smoothedSpeedMps, config.minSpeedForIntervalMps);
    var intervalSeconds = _clampDouble(
      baseDistance / speedForInterval,
      config.baseIntervalMinSeconds,
      config.baseIntervalMaxSeconds,
    );
    var distanceMeters = baseDistance;

    if (isBackground) {
      intervalSeconds = _clampDouble(
        math.max(
          intervalSeconds * config.backgroundIntervalMultiplier,
          config.backgroundIntervalFloorSeconds,
        ),
        config.backgroundIntervalClampMinSeconds,
        config.backgroundIntervalMaxSeconds,
      );
      distanceMeters = _clampDouble(
        math.max(
          distanceMeters * config.backgroundDistanceMultiplier,
          config.backgroundDistanceFloorMeters,
        ),
        config.backgroundDistanceClampMinMeters,
        config.backgroundDistanceMaxMeters,
      );
    }

    if (_state == AdaptiveTrackingState.unreliable) {
      intervalSeconds = _clampDouble(
        config.unreliableIntervalSeconds.toDouble(),
        config.unreliableIntervalMinSeconds.toDouble(),
        config.unreliableIntervalMaxSeconds.toDouble(),
      );
    }

    if (turnBoostActive) {
      intervalSeconds =
          math.min(intervalSeconds, config.turnBoostIntervalSeconds);
      distanceMeters =
          math.min(distanceMeters, config.turnBoostDistanceMeters);
    }

    return AdaptiveTrackingPolicySnapshot(
      interval: Duration(milliseconds: (intervalSeconds * 1000).round()),
      distanceFilterMeters: distanceMeters,
      state: _state,
      smoothedSpeedMps: _smoothedSpeedMps,
      isBackground: isBackground,
    );
  }

  AdaptiveTrackingDecision _decideEmission({
    required AdaptiveTrackingPolicySnapshot policy,
    required _GeoPoint currentPoint,
    required DateTime now,
    required DateTime timestamp,
    required double? accuracyMeters,
    required bool stateUpShift,
    required bool turnDetected,
  }) {
    if (_lastEmitAt == null || _lastEmitPoint == null) {
      final sample = _buildSample(currentPoint, timestamp);
      return AdaptiveTrackingDecision(
        shouldEmit: true,
        sample: sample,
        policy: policy,
        reason: 'initial',
      );
    }

    final distanceSinceEmit =
        haversineMeters(_lastEmitPoint!, currentPoint);
    final intervalReached =
        now.difference(_lastEmitAt!) >= policy.interval;
    final distanceReached = distanceSinceEmit >= policy.distanceFilterMeters;

    var shouldEmit =
        intervalReached || distanceReached || turnDetected || stateUpShift;
    var reason = 'interval';
    if (turnDetected) {
      reason = 'turn';
    } else if (stateUpShift) {
      reason = 'state';
    } else if (distanceReached) {
      reason = 'distance';
    } else if (!intervalReached) {
      reason = 'interval';
    }

    if (_state == AdaptiveTrackingState.unreliable) {
      final accuracyGate = accuracyMeters == null
          ? 0.0
          : accuracyMeters * config.unreliableAccuracyFactor;
      final requiredDistance =
          math.max(policy.distanceFilterMeters, accuracyGate);
      final accuracyImproved = _accuracyImproved(accuracyMeters);
      shouldEmit =
          shouldEmit && (distanceSinceEmit >= requiredDistance || accuracyImproved);
      if (accuracyImproved) {
        reason = 'accuracy';
      }
    }

    final sample = shouldEmit ? _buildSample(currentPoint, timestamp) : null;
    return AdaptiveTrackingDecision(
      shouldEmit: shouldEmit,
      sample: sample,
      policy: policy,
      reason: reason,
    );
  }

  LatLngSample _buildSample(_GeoPoint point, DateTime timestamp) {
    return LatLngSample(
      latitude: _roundTo5(point.latitude),
      longitude: _roundTo5(point.longitude),
      timestamp: timestamp,
    );
  }

  void _maybeLogPolicyChange({
    required AdaptiveTrackingPolicySnapshot policy,
    required DateTime now,
    required bool stateChanged,
    required bool turnBoostActive,
  }) {
    final previous = _lastPolicy;
    final intervalSeconds = policy.interval.inMilliseconds / 1000;
    final distanceMeters = policy.distanceFilterMeters;
    final intervalChanged = previous == null ||
        (intervalSeconds -
                    previous.interval.inMilliseconds / 1000)
                .abs() >=
            config.policyChangeIntervalEpsilonSeconds;
    final distanceChanged = previous == null ||
        (distanceMeters - previous.distanceFilterMeters).abs() >=
            config.policyChangeDistanceEpsilonMeters;

    if (!(intervalChanged || distanceChanged || stateChanged)) {
      return;
    }

    final reasons = <String>[];
    if (stateChanged) {
      reasons.add('state');
    }
    if (_state == AdaptiveTrackingState.unreliable) {
      reasons.add('unreliable');
    }
    if (policy.isBackground) {
      reasons.add('background');
    }
    if (turnBoostActive) {
      reasons.add('turn');
    }
    if (reasons.isEmpty) {
      reasons.add('speed');
    }

    log(
      'Policy update interval=${intervalSeconds.toStringAsFixed(1)}s '
      'distance=${distanceMeters.toStringAsFixed(1)}m '
      'state=${_stateLabel(policy.state)} '
      'reason=${reasons.join(",")}',
    );
    _lastPolicy = policy;
  }

  void _logWithCooldown({
    required String message,
    required DateTime now,
    required DateTime? lastLog,
    required void Function(DateTime) updateLast,
    int? cooldownSeconds,
  }) {
    final cooldown = Duration(
      seconds: cooldownSeconds ?? config.reliabilityLogCooldownSeconds,
    );
    if (lastLog == null ||
        now.difference(lastLog) >= cooldown) {
      updateLast(now);
      log(message);
    }
  }

  bool _accuracyImproved(double? accuracyMeters) {
    if (_lastAccuracyMeters == null || accuracyMeters == null) {
      return false;
    }
    return _lastAccuracyMeters! > config.poorAccuracyMeters &&
        accuracyMeters <= config.poorAccuracyMeters;
  }

  double _movementConfidence(double distanceMeters, double? accuracyMeters) {
    if (accuracyMeters == null || accuracyMeters <= 0) {
      return 1.0;
    }
    final baseline = math.max(accuracyMeters, config.minMovementMeters);
    return _clampDouble(distanceMeters / baseline, 0.0, 1.0);
  }

  double _noiseThresholdMeters(double? accuracyMeters) {
    if (accuracyMeters == null || accuracyMeters <= 0) {
      return config.minMovementMeters;
    }
    return math.max(
      accuracyMeters * config.accuracyMovementFactor,
      config.minMovementMeters,
    );
  }

  double _normalizeSpeed(double speed) {
    if (!speed.isFinite || speed < 0) {
      return 0.0;
    }
    return speed;
  }

  double? _normalizeAccuracy(double accuracy) {
    if (!accuracy.isFinite || accuracy <= 0) {
      return null;
    }
    return accuracy;
  }

  double _ema({
    required double previous,
    required double value,
    required double alpha,
    required bool seed,
  }) {
    if (seed) {
      return value;
    }
    return alpha * value + (1 - alpha) * previous;
  }

  double _roundTo5(double value) {
    return (value * 100000).roundToDouble() / 100000;
  }

  DateTime _timestampFor(RawLocationData raw, DateTime now) {
    final timestampMs = raw.time.round();
    if (timestampMs <= 0) {
      return now;
    }
    return DateTime.fromMillisecondsSinceEpoch(timestampMs);
  }

  double _deltaSeconds(DateTime? last, DateTime now) {
    if (last == null) {
      return 0.0;
    }
    return math.max(
      now.difference(last).inMilliseconds / 1000,
      0.0,
    );
  }

  double _clampDouble(double value, double minValue, double maxValue) {
    return math.min(math.max(value, minValue), maxValue);
  }

  bool _isValidCoordinate(double latitude, double longitude) {
    if (!latitude.isFinite || !longitude.isFinite) {
      return false;
    }
    return latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180;
  }

  String _stateLabel(AdaptiveTrackingState state) {
    switch (state) {
      case AdaptiveTrackingState.still:
        return 'still';
      case AdaptiveTrackingState.walk:
        return 'walk';
      case AdaptiveTrackingState.drive:
        return 'drive';
      case AdaptiveTrackingState.unreliable:
        return 'unreliable';
    }
  }
}

class _GeoPoint {
  const _GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

double haversineMeters(_GeoPoint start, _GeoPoint end) {
  const earthRadiusMeters = 6371000;
  final dLat = _degToRad(end.latitude - start.latitude);
  final dLng = _degToRad(_wrapDeltaDegrees(end.longitude - start.longitude));
  final lat1 = _degToRad(start.latitude);
  final lat2 = _degToRad(end.latitude);

  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLng / 2), 2);
  final c = 2 * math.asin(math.sqrt(a.toDouble()));
  return earthRadiusMeters * c;
}

double bearingDegrees(_GeoPoint start, _GeoPoint end) {
  final lat1 = _degToRad(start.latitude);
  final lat2 = _degToRad(end.latitude);
  final dLng = _degToRad(_wrapDeltaDegrees(end.longitude - start.longitude));
  final y = math.sin(dLng) * math.cos(lat2);
  final x = math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
  final bearing = math.atan2(y, x);
  final bearingDegrees = _radToDeg(bearing);
  return (bearingDegrees + 360) % 360;
}

double headingDeltaDegrees(double heading1, double heading2) {
  final delta = (heading1 - heading2).abs() % 360;
  return delta > 180 ? 360 - delta : delta;
}

double _degToRad(double degrees) => degrees * (math.pi / 180);

double _radToDeg(double radians) => radians * (180 / math.pi);

double _wrapDeltaDegrees(double delta) {
  var wrapped = delta % 360;
  if (wrapped > 180) {
    wrapped -= 360;
  } else if (wrapped < -180) {
    wrapped += 360;
  }
  return wrapped;
}
