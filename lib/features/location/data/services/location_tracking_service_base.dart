import 'dart:async';
import '../location_tracking_config.dart';
import '../models/lat_lng_sample.dart';
import 'adaptive_tracking_policy.dart';
import 'background_location_client.dart';
import 'location_tracking_service.dart';

/// Base implementation that filters raw updates using OR policy + watchdog.
abstract class LocationTrackingServiceBase implements LocationTrackingService {
  LocationTrackingServiceBase({
    required this.client,
    required this.config,
    required String platformLabel,
    DateTime Function()? nowProvider,
  })  : _platformLabel = platformLabel,
        _now = nowProvider ?? DateTime.now,
        _policy = AdaptiveTrackingPolicy(
          config: config,
          log: (message) => _logMessage(platformLabel, message),
        );

  final BackgroundLocationClient client;
  final LocationTrackingConfig config;

  final String _platformLabel;
  final DateTime Function() _now;
  final AdaptiveTrackingPolicy _policy;
  final StreamController<LatLngSample> _controller =
      StreamController<LatLngSample>.broadcast();

  bool _isRunning = false;
  bool _isListening = false;
  bool _isBackground = false;
  Timer? _watchdogTimer;
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
    _policy.reset();
    _isBackground = config.assumeBackground;
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
    _policy.reset();
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
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
      final now = _now();
      _lastUpdateReceivedAt = now;
      final decision = _policy.updateWithRawLocation(
        raw: data,
        now: now,
        isBackground: _isBackground,
      );
      if (!decision.shouldEmit || decision.sample == null) {
        return;
      }
      _controller.add(decision.sample!);
    } catch (error) {
      _log('Location update failed: $error');
    }
  }

  void _startWatchdog() {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer.periodic(config.watchdogInterval, (_) {
      if (!_isRunning) {
        return;
      }
      final now = _now();
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

  void _logNoUpdates(DateTime? lastReceived, Duration threshold) {
    final lastSeen = lastReceived?.toIso8601String() ?? 'never';
    _log(
      'No location updates within ${threshold.inSeconds}s '
      '(last received: $lastSeen).',
    );
  }

  void _log(String message) {
    // Console-only logging for now, per requirements.
    // ignore: avoid_print
    print('[LocationTracking][$_platformLabel] $message');
  }
}

void _logMessage(String platformLabel, String message) {
  // Console-only logging for now, per requirements.
  // ignore: avoid_print
  print('[LocationTracking][$platformLabel] $message');
}
