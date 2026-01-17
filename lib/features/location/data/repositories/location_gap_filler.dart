import 'dart:math' as math;

import '../models/lat_lng_sample.dart';

/// Fills small gaps between consecutive real samples with linear interpolation.
class LocationGapFiller {
  LocationGapFiller({
    required Duration expectedInterval,
    required double maxSpeedMps,
    required double maxDistanceMeters,
    this.maxMissingPoints = 4,
  })  : _expectedInterval = expectedInterval,
        _maxSpeedMps = maxSpeedMps,
        _maxDistanceMeters = maxDistanceMeters;

  final Duration _expectedInterval;
  final double _maxSpeedMps;
  final double _maxDistanceMeters;
  final int maxMissingPoints;

  LatLngSample? _lastRealSample;

  void reset() {
    _lastRealSample = null;
  }

  Iterable<LatLngSample> handleSample(LatLngSample sample) {
    final outputs = <LatLngSample>[];
    final previous = _lastRealSample;

    if (previous != null && !previous.isInterpolated && !sample.isInterpolated) {
      outputs.addAll(
        interpolateMissingPoints(
          start: previous,
          end: sample,
          expectedInterval: _expectedInterval,
          maxSpeedMps: _maxSpeedMps,
          maxDistanceMeters: _maxDistanceMeters,
          maxMissingPoints: maxMissingPoints,
        ),
      );
    }

    outputs.add(sample);

    if (!sample.isInterpolated &&
        (previous == null || sample.timestamp.isAfter(previous.timestamp))) {
      _lastRealSample = sample;
    }

    return outputs;
  }
}

List<LatLngSample> interpolateMissingPoints({
  required LatLngSample start,
  required LatLngSample end,
  required Duration expectedInterval,
  required double maxSpeedMps,
  required double maxDistanceMeters,
  int minMissingPoints = 1,
  int maxMissingPoints = 4,
}) {
  if (start.isInterpolated || end.isInterpolated) {
    return const [];
  }
  if (!_isValidCoordinate(start.latitude, start.longitude) ||
      !_isValidCoordinate(end.latitude, end.longitude)) {
    return const [];
  }

  final delta = end.timestamp.difference(start.timestamp);
  if (delta.inMicroseconds <= 0) {
    return const [];
  }

  final distanceMeters = _haversineMeters(
    start.latitude,
    start.longitude,
    end.latitude,
    end.longitude,
  );

  final missingCountTime = _missingCountByTime(
    delta: delta,
    expectedInterval: expectedInterval,
  );
  final missingCountDistance =
      _missingCountByDistance(distanceMeters, maxDistanceMeters);
  // Use the stricter (larger) missing count so both time and distance gaps
  // can trigger interpolation when they stay within the 1–4 range.
  final missingCount = math.max(missingCountTime, missingCountDistance);
  if (missingCount < minMissingPoints || missingCount > maxMissingPoints) {
    return const [];
  }

  if (maxSpeedMps <= 0) {
    return const [];
  }

  final deltaSeconds = delta.inMicroseconds / 1000000;
  final speedMps = distanceMeters / deltaSeconds;
  if (!speedMps.isFinite || speedMps > maxSpeedMps) {
    return const [];
  }

  final results = <LatLngSample>[];
  final steps = missingCount + 1;
  final deltaMicros = delta.inMicroseconds;
  final accuracyMeters = _interpolatedAccuracy(start, end);

  for (var i = 1; i <= missingCount; i += 1) {
    final fraction = i / steps;
    final timestamp = start.timestamp.add(
      Duration(microseconds: (deltaMicros * fraction).round()),
    );
    final latitude = _roundTo5(
      start.latitude + (end.latitude - start.latitude) * fraction,
    );
    final longitude = _roundTo5(
      start.longitude + (end.longitude - start.longitude) * fraction,
    );

    results.add(
      LatLngSample(
        latitude: latitude,
        longitude: longitude,
        timestamp: timestamp,
        accuracyMeters: accuracyMeters,
        isInterpolated: true,
      ),
    );
  }

  return results;
}

int _missingCountByTime({
  required Duration delta,
  required Duration expectedInterval,
}) {
  final intervalMicros = expectedInterval.inMicroseconds;
  if (intervalMicros <= 0) {
    return 0;
  }
  final deltaMicros = delta.inMicroseconds;
  if (deltaMicros <= 0) {
    return 0;
  }

  // Use ceiling so the interval represents the maximum allowed time span
  // between consecutive points, while keeping integer math deterministic.
  final intervalCount =
      (deltaMicros + intervalMicros - 1) ~/ intervalMicros;
  final missingCount = intervalCount - 1;
  return missingCount > 0 ? missingCount : 0;
}

int _missingCountByDistance(double distanceMeters, double maxDistanceMeters) {
  if (!distanceMeters.isFinite || distanceMeters <= 0) {
    return 0;
  }
  if (!maxDistanceMeters.isFinite || maxDistanceMeters <= 0) {
    return 0;
  }

  final segments =
      (distanceMeters / maxDistanceMeters).ceil();
  final missingCount = segments - 1;
  return missingCount > 0 ? missingCount : 0;
}

double _roundTo5(double value) {
  // Keep deterministic 5-decimal rounding and normalize -0.0 to 0.0.
  final rounded = (value * 100000).roundToDouble() / 100000;
  return rounded == 0 ? 0.0 : rounded;
}

double? _interpolatedAccuracy(LatLngSample start, LatLngSample end) {
  final startAccuracy = start.accuracyMeters;
  final endAccuracy = end.accuracyMeters;
  if (startAccuracy == null) {
    return endAccuracy;
  }
  if (endAccuracy == null) {
    return startAccuracy;
  }
  return math.max(startAccuracy, endAccuracy);
}

bool _isValidCoordinate(double latitude, double longitude) {
  if (!latitude.isFinite || !longitude.isFinite) {
    return false;
  }
  return latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180;
}

double _haversineMeters(
  double startLat,
  double startLng,
  double endLat,
  double endLng,
) {
  const earthRadiusMeters = 6371000;
  final dLat = _degToRad(endLat - startLat);
  final dLng = _degToRad(_wrapDeltaDegrees(endLng - startLng));
  final lat1 = _degToRad(startLat);
  final lat2 = _degToRad(endLat);

  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLng / 2), 2);
  final c = 2 * math.asin(math.sqrt(a.toDouble()));
  return earthRadiusMeters * c;
}

double _degToRad(double degrees) => degrees * (math.pi / 180);

double _wrapDeltaDegrees(double delta) {
  var wrapped = delta % 360;
  if (wrapped > 180) {
    wrapped -= 360;
  } else if (wrapped < -180) {
    wrapped += 360;
  }
  return wrapped;
}
