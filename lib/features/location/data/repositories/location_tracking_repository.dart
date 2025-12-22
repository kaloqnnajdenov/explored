import 'dart:async';

import '../models/location_tracking_mode.dart';
import '../models/permission_status.dart';
import '../models/tracking_state.dart';
import '../services/location_services_gateway.dart';
import '../services/logger.dart';
import '../services/permission_gateway.dart';
import '../services/platform_info.dart';

/// Coordinates permission checks and tracking IO for the tracking controller.
class LocationTrackingRepository {
  /// Builds the repository with injected permission, location, and logging IO.
  LocationTrackingRepository({
    required PermissionGateway permissionGateway,
    required LocationServicesGateway locationServicesGateway,
    required PlatformInfo platformInfo,
    required Logger logger,
  })  : _permissionGateway = permissionGateway,
        _locationServicesGateway = locationServicesGateway,
        _platformInfo = platformInfo,
        _logger = logger;

  final PermissionGateway _permissionGateway;
  final LocationServicesGateway _locationServicesGateway;
  final PlatformInfo _platformInfo;
  final Logger _logger;

  StreamSubscription? _subscription;
  LocationTrackingMode _activeMode = LocationTrackingMode.none;

  /// Attempts to start foreground-only tracking with permission checks.
  Future<TrackingDecision> startForegroundTracking() async {
    if (_activeMode == LocationTrackingMode.foreground) {
      return TrackingDecision(
        snapshot: _snapshotFor(
          TrackingState.trackingActiveForeground,
          TrackingAction.stopTracking,
        ),
        result: TrackingStartResult.alreadyActive,
      );
    }

    final servicesEnabled =
        await _locationServicesGateway.isLocationServicesEnabled();
    if (!servicesEnabled) {
      _logger.log('location_services_disabled', {
        'tracking_active': false,
        'next_action': 'open_settings',
      });
      return TrackingDecision(
        snapshot: _snapshotFor(
          TrackingState.trackingPausedLocationServicesOff,
          TrackingAction.openSettings,
        ),
        result: TrackingStartResult.locationServicesDisabled,
      );
    }

    var foregroundStatus = await _permissionGateway.getForegroundStatus();
    if (!foregroundStatus.isGranted) {
      final permanentlyDenied = await _permissionGateway.isPermanentlyDenied();
      if (permanentlyDenied) {
        _logger.log('permission_foreground_denied', {
          'tracking_active': false,
          'next_action': 'open_settings',
          'reason': 'permanently_denied',
        });
        return TrackingDecision(
          snapshot: _snapshotFor(
            TrackingState.permissionRequiredForeground,
            TrackingAction.openSettings,
          ),
          result: TrackingStartResult.permissionDeniedForever,
        );
      }

      foregroundStatus = await _permissionGateway.requestForeground();
    }

    if (!foregroundStatus.isGranted) {
      _logger.log('permission_foreground_denied', {
        'tracking_active': false,
        'next_action': 'show_permission_rationale',
      });
      return TrackingDecision(
        snapshot: _snapshotFor(
          TrackingState.permissionRequiredForeground,
          TrackingAction.requestForegroundPermission,
        ),
        result: TrackingStartResult.permissionDeniedForeground,
      );
    }

    await _transitionTo(LocationTrackingMode.foreground);
    _logger.log('tracking_started_foreground', {
      'tracking_active': true,
    });
    return TrackingDecision(
      snapshot: _snapshotFor(
        TrackingState.trackingActiveForeground,
        TrackingAction.stopTracking,
      ),
      result: TrackingStartResult.startedForeground,
    );
  }

  /// Attempts to start background tracking with full permission checks.
  Future<TrackingDecision> startBackgroundTracking() async {
    if (_activeMode == LocationTrackingMode.background) {
      return TrackingDecision(
        snapshot: _snapshotFor(
          TrackingState.trackingActiveBackground,
          TrackingAction.stopTracking,
        ),
        result: TrackingStartResult.alreadyActive,
      );
    }

    final servicesEnabled =
        await _locationServicesGateway.isLocationServicesEnabled();
    if (!servicesEnabled) {
      _logger.log('location_services_disabled', {
        'tracking_active': false,
        'next_action': 'open_settings',
      });
      return TrackingDecision(
        snapshot: _snapshotFor(
          TrackingState.trackingPausedLocationServicesOff,
          TrackingAction.openSettings,
        ),
        result: TrackingStartResult.locationServicesDisabled,
      );
    }

    var foregroundStatus = await _permissionGateway.getForegroundStatus();
    if (!foregroundStatus.isGranted) {
      final permanentlyDenied = await _permissionGateway.isPermanentlyDenied();
      if (permanentlyDenied) {
        _logger.log('permission_foreground_denied', {
          'tracking_active': false,
          'next_action': 'open_settings',
          'reason': 'permanently_denied',
        });
        return TrackingDecision(
          snapshot: _snapshotFor(
            TrackingState.permissionRequiredForeground,
            TrackingAction.openSettings,
          ),
          result: TrackingStartResult.permissionDeniedForever,
        );
      }
      foregroundStatus = await _permissionGateway.requestForeground();
    }

    if (!foregroundStatus.isGranted) {
      _logger.log('permission_foreground_denied', {
        'tracking_active': false,
        'next_action': 'show_permission_rationale',
      });
      return TrackingDecision(
        snapshot: _snapshotFor(
          TrackingState.permissionRequiredForeground,
          TrackingAction.requestForegroundPermission,
        ),
        result: TrackingStartResult.permissionDeniedForeground,
      );
    }

    if (_requiresBackgroundPermission()) {
      var backgroundStatus = await _permissionGateway.getBackgroundStatus();
      if (!backgroundStatus.isGranted) {
        final permanentlyDenied = await _permissionGateway.isPermanentlyDenied();
        if (permanentlyDenied) {
          _logger.log('permission_background_denied', {
            'tracking_active_background': false,
            'foreground_permission': foregroundStatus.name,
            'next_action': 'open_settings',
            'reason': 'permanently_denied',
          });
          return TrackingDecision(
            snapshot: _snapshotFor(
              TrackingState.permissionRequiredBackground,
              TrackingAction.openSettings,
            ),
            result: TrackingStartResult.permissionDeniedForever,
          );
        }

        backgroundStatus = await _permissionGateway.requestBackground();
        if (!backgroundStatus.isGranted) {
          final nextAction =
              _platformInfo.isIOS ? 'open_settings' : 'show_permission_rationale';
          _logger.log('permission_background_denied', {
            'tracking_active_background': false,
            'foreground_permission': foregroundStatus.name,
            'next_action': nextAction,
          });
          return TrackingDecision(
            snapshot: _snapshotFor(
              TrackingState.permissionRequiredBackground,
              _platformInfo.isIOS
                  ? TrackingAction.openSettings
                  : TrackingAction.requestBackgroundPermission,
            ),
            result: TrackingStartResult.permissionDeniedBackground,
          );
        }
      }
    }

    if (_platformInfo.isAndroid) {
      final canNotify = await _locationServicesGateway.canPostNotifications();
      if (!canNotify) {
        _logger.log('notifications_blocked', {
          'tracking_active_background': false,
          'next_action': 'request_notifications',
        });
        return TrackingDecision(
          snapshot: _snapshotFor(
            TrackingState.trackingStoppedNotificationsBlocked,
            TrackingAction.requestNotifications,
          ),
          result: TrackingStartResult.notificationsBlocked,
        );
      }
    }

    await _transitionTo(LocationTrackingMode.background);
    _logger.log('tracking_started_background', {
      'tracking_active_background': true,
    });
    return TrackingDecision(
      snapshot: _snapshotFor(
        TrackingState.trackingActiveBackground,
        TrackingAction.stopTracking,
      ),
      result: TrackingStartResult.startedBackground,
    );
  }

  /// Stops any active tracking session and clears listeners.
  Future<TrackingStateSnapshot> stopTracking() async {
    await _subscription?.cancel();
    _subscription = null;
    if (_activeMode == LocationTrackingMode.background) {
      await _locationServicesGateway.stopBackgroundService();
    }
    _activeMode = LocationTrackingMode.none;
    _logger.log('tracking_stopped', {'tracking_active': false});
    return _snapshotFor(TrackingState.trackingStopped, null);
  }

  /// Re-evaluates permissions and services without duplicating listeners.
  Future<TrackingStateSnapshot> refreshTrackingState() async {
    final servicesEnabled =
        await _locationServicesGateway.isLocationServicesEnabled();
    if (!servicesEnabled) {
      if (_activeMode != LocationTrackingMode.none) {
        await stopTracking();
      }
      _logger.log('location_services_disabled', {
        'tracking_active': false,
        'next_action': 'open_settings',
      });
      return _snapshotFor(
        TrackingState.trackingPausedLocationServicesOff,
        TrackingAction.openSettings,
      );
    }

    final foregroundStatus = await _permissionGateway.getForegroundStatus();
    if (!foregroundStatus.isGranted) {
      if (_activeMode != LocationTrackingMode.none) {
        await stopTracking();
        _logger.log('permission_revoked', {
          'tracking_active': false,
          'scope': 'foreground',
        });
        return _snapshotFor(
          TrackingState.trackingStoppedPermissionRevoked,
          TrackingAction.requestForegroundPermission,
        );
      }
      return _snapshotFor(
        TrackingState.permissionRequiredForeground,
        TrackingAction.requestForegroundPermission,
      );
    }

    if (_activeMode == LocationTrackingMode.foreground) {
      return _snapshotFor(
        TrackingState.trackingActiveForeground,
        TrackingAction.stopTracking,
      );
    }

    if (_activeMode == LocationTrackingMode.background) {
      if (_requiresBackgroundPermission()) {
        final backgroundStatus = await _permissionGateway.getBackgroundStatus();
        if (!backgroundStatus.isGranted) {
          await stopTracking();
          _logger.log('permission_revoked', {
            'tracking_active': false,
            'scope': 'background',
          });
          return _snapshotFor(
            TrackingState.trackingStoppedPermissionRevoked,
            TrackingAction.requestBackgroundPermission,
          );
        }
      }
      if (_platformInfo.isAndroid) {
        final canNotify = await _locationServicesGateway.canPostNotifications();
        if (!canNotify) {
          await stopTracking();
          _logger.log('notifications_blocked', {
            'tracking_active_background': false,
            'next_action': 'request_notifications',
          });
          return _snapshotFor(
            TrackingState.trackingStoppedNotificationsBlocked,
            TrackingAction.requestNotifications,
          );
        }
      }
      return _snapshotFor(
        TrackingState.trackingActiveBackground,
        TrackingAction.stopTracking,
      );
    }

    return _snapshotFor(TrackingState.idle, null);
  }

  bool _requiresBackgroundPermission() {
    if (_platformInfo.isIOS) {
      return true;
    }
    if (_platformInfo.isAndroid) {
      return (_platformInfo.androidSdkInt ?? 0) >= 29;
    }
    return false;
  }

  TrackingStateSnapshot _snapshotFor(
    TrackingState state,
    TrackingAction? action,
  ) {
    return TrackingStateSnapshot(
      state: state,
      trackingMode: _trackingModeForState(state),
      action: action,
    );
  }

  LocationTrackingMode _trackingModeForState(TrackingState state) {
    switch (state) {
      case TrackingState.trackingActiveForeground:
        return LocationTrackingMode.foreground;
      case TrackingState.trackingActiveBackground:
        return LocationTrackingMode.background;
      case TrackingState.idle:
      case TrackingState.permissionRequiredForeground:
      case TrackingState.permissionRequiredBackground:
      case TrackingState.trackingPausedLocationServicesOff:
      case TrackingState.trackingStoppedPermissionRevoked:
      case TrackingState.trackingStoppedNotificationsBlocked:
      case TrackingState.trackingStopped:
        return LocationTrackingMode.none;
    }
  }

  Future<void> _transitionTo(LocationTrackingMode mode) async {
    if (_activeMode == mode) {
      return;
    }
    if (_activeMode == LocationTrackingMode.background &&
        mode != LocationTrackingMode.background) {
      await _locationServicesGateway.stopBackgroundService();
    }
    if (mode == LocationTrackingMode.background) {
      await _locationServicesGateway.startBackgroundService();
    }
    _subscription ??=
        _locationServicesGateway.locationStream().listen((_) {});
    _activeMode = mode;
  }
}
