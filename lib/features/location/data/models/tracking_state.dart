import 'location_tracking_mode.dart';

/// Defines high-level tracking states for permission and service flows.
enum TrackingState {
  idle,
  permissionRequiredForeground,
  permissionRequiredBackground,
  trackingActiveForeground,
  trackingActiveBackground,
  trackingPausedLocationServicesOff,
  trackingStoppedPermissionRevoked,
  trackingStoppedNotificationsBlocked,
  trackingStopped,
}

/// Describes the next user action suggested by tracking logic.
enum TrackingAction {
  requestForegroundPermission,
  requestBackgroundPermission,
  openSettings,
  requestNotifications,
  stopTracking,
}

/// Enumerates the outcomes of starting a tracking session.
enum TrackingStartResult {
  startedForeground,
  startedBackground,
  permissionDeniedForeground,
  permissionDeniedBackground,
  permissionDeniedForever,
  locationServicesDisabled,
  notificationsBlocked,
  alreadyActive,
}

/// Captures the latest tracking state, mode, and suggested action.
class TrackingStateSnapshot {
  /// Builds an immutable snapshot for the tracking controller.
  const TrackingStateSnapshot({
    required this.state,
    required this.trackingMode,
    this.action,
  });

  final TrackingState state;
  final LocationTrackingMode trackingMode;
  final TrackingAction? action;

  bool get isTracking => trackingMode != LocationTrackingMode.none;

  TrackingStateSnapshot copyWith({
    TrackingState? state,
    LocationTrackingMode? trackingMode,
    TrackingAction? action,
    bool clearAction = false,
  }) {
    return TrackingStateSnapshot(
      state: state ?? this.state,
      trackingMode: trackingMode ?? this.trackingMode,
      action: clearAction ? null : action ?? this.action,
    );
  }
}

/// Wraps a start attempt result with the state snapshot to apply.
class TrackingDecision {
  /// Packages the decision payload used by tracking starts.
  const TrackingDecision({
    required this.snapshot,
    required this.result,
  });

  final TrackingStateSnapshot snapshot;
  final TrackingStartResult result;
}
