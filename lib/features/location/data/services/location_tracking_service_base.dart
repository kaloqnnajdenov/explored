import 'dart:async';
import 'dart:math' as math;

import '../location_tracking_config.dart';
import '../models/lat_lng_sample.dart';
import 'background_location_client.dart';
import 'location_tracking_service.dart';

/// Indicates which trigger caused a sample emission.
enum LocationEmitTrigger {
  interval,
  distance,
}

/// Base implementation that filters raw updates using OR policy + watchdog.
abstract class LocationTrackingServiceBase implements LocationTrackingService {
  LocationTrackingServiceBase({
    required this.client,
    required this.config,
    required String platformLabel,
  }) : _platformLabel = platformLabel;

  final BackgroundLocationClient client;
  final LocationTrackingConfig config;

  final String _platformLabel;
  final StreamController<LatLngSample> _controller =
      StreamController<LatLngSample>.broadcast();

  bool _isRunning = false;
  bool _isListening = false;
  Timer? _watchdogTimer;
  DateTime? _lastEmitTime;
  _RawPoint? _lastEmitPoint;
  DateTime? _lastUpdateReceivedAt;
  DateTime? _lastWatchdogNoticeAt;

  @override
  Stream<LatLngSample> get stream => _controller.stream;

  @override
  bool get isRunning => _isRunning;

  /// Hook for platform-specific configuration before starting the service.
  Future<void> configurePlatform();

  @override
  Future<void> start() async {
    if (_isRunning) {
      return;
    }
    _ensureListening();
    await configurePlatform();
    _isRunning = true;
    try {
      await client.startLocationService(
        distanceFilter: config.distanceFilterMeters,
      );
    } catch (error) {
      _isRunning = false;
      rethrow;
    }
    _startWatchdog();
    _log('Location tracking started');
  }

  @override
  Future<void> stop() async {
    if (!_isRunning) {
      return;
    }
    await client.stopLocationService();
    _isRunning = false;
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
    _lastEmitTime = null;
    _lastEmitPoint = null;
    _lastUpdateReceivedAt = null;
    _lastWatchdogNoticeAt = null;
    _log('Location tracking stopped');
  }

  void _ensureListening() {
    if (_isListening) {
      return;
    }
    _isListening = true;
    client.getLocationUpdates(_handleRawUpdate);
  }

  /// Applies OR policy (interval OR distance) to decide when to emit.
  void _handleRawUpdate(RawLocationData data) {
    try {
      if (!_isRunning) {
        return;
      }
      final now = DateTime.now();
      _lastUpdateReceivedAt = now;
      final timestamp = _timestampFor(data);
      final latitude = data.latitude;
      final longitude = data.longitude;

      final trigger = _triggerFor(latitude, longitude, now);
      if (trigger == null) {
        return;
      }

      final sample = LatLngSample(
        latitude: _roundTo5(latitude),
        longitude: _roundTo5(longitude),
        timestamp: timestamp,
      );
      _lastEmitTime = now;
      _lastEmitPoint = _RawPoint(latitude, longitude);
      _controller.add(sample);
      _logEmit(sample, trigger);
    } catch (error) {
      _log('Location update failed: $error');
    }
  }

  LocationEmitTrigger? _triggerFor(
    double latitude,
    double longitude,
    DateTime now,
  ) {
    if (_lastEmitTime == null || _lastEmitPoint == null) {
      return LocationEmitTrigger.interval;
    }

    final elapsed = now.difference(_lastEmitTime!);
    final intervalReached = elapsed >= config.updateInterval;
    if (intervalReached) {
      return LocationEmitTrigger.interval;
    }

    final distanceMeters = _distanceMeters(
      _lastEmitPoint!,
      _RawPoint(latitude, longitude),
    );
    final distanceReached = distanceMeters >= config.distanceFilterMeters;
    if (distanceReached) {
      return LocationEmitTrigger.distance;
    }

    return null;
  }

  void _startWatchdog() {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer.periodic(config.watchdogInterval, (_) {
      if (!_isRunning) {
        return;
      }
      final now = DateTime.now();
      final lastReceived = _lastUpdateReceivedAt;
      final threshold = config.noUpdateThreshold;

      final hasNoUpdates = lastReceived == null ||
          now.difference(lastReceived) >= threshold;
      if (!hasNoUpdates) {
        return;
      }

      if (_lastWatchdogNoticeAt == null ||
          now.difference(_lastWatchdogNoticeAt!) >= config.watchdogInterval) {
        _lastWatchdogNoticeAt = now;
        _logNoUpdates(lastReceived, threshold);
      }
    });
  }

  void _logEmit(LatLngSample sample, LocationEmitTrigger trigger) {
    final latitude = sample.latitude.toStringAsFixed(5);
    final longitude = sample.longitude.toStringAsFixed(5);
    final timestamp = sample.timestamp.toIso8601String();
    _log(
      'Location update $timestamp lat=$latitude lng=$longitude '
      'trigger=${_triggerLabel(trigger)}',
    );
  }

  void _logNoUpdates(DateTime? lastReceived, Duration threshold) {
    final lastSeen = lastReceived?.toIso8601String() ?? 'never';
    _log(
      'No location updates within ${threshold.inSeconds}s '
      '(last received: $lastSeen).',
    );
  }

  String _triggerLabel(LocationEmitTrigger trigger) {
    switch (trigger) {
      case LocationEmitTrigger.interval:
        return 'interval';
      case LocationEmitTrigger.distance:
        return 'distance';
    }
  }

  DateTime _timestampFor(RawLocationData data) {
    final timestampMs = data.time.round();
    if (timestampMs <= 0) {
      return DateTime.now();
    }
    return DateTime.fromMillisecondsSinceEpoch(timestampMs);
  }

  // Rounds coordinates to 5 decimal places as required by the stream contract.
  double _roundTo5(double value) {
    return (value * 100000).roundToDouble() / 100000;
  }

  double _distanceMeters(_RawPoint start, _RawPoint end) {
    const earthRadiusMeters = 6371000;
    final dLat = _degToRad(end.latitude - start.latitude);
    final dLng = _degToRad(end.longitude - start.longitude);
    final lat1 = _degToRad(start.latitude);
    final lat2 = _degToRad(end.latitude);

    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLng / 2), 2);
    final c = 2 * math.asin(math.sqrt(a.toDouble()));
    return earthRadiusMeters * c;
  }

  double _degToRad(double degrees) => degrees * (math.pi / 180);

  void _log(String message) {
    // Console-only logging for now, per requirements.
    // ignore: avoid_print
    print('[LocationTracking][$_platformLabel] $message');
  }
}

class _RawPoint {
  const _RawPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}
