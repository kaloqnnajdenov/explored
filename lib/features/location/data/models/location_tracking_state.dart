import 'location_permission_level.dart';
import 'location_status.dart';
import 'location_tracking_mode.dart';
import 'location_update.dart';

/// Aggregates UI-facing state for location tracking status and data.
class LocationTrackingState {
  const LocationTrackingState({
    required this.permissionLevel,
    required this.trackingMode,
    required this.status,
    required this.isActionInProgress,
    required this.isServiceEnabled,
    required this.isNotificationPermissionGranted,
    this.lastLocation,
  });

  /// Builds a default state before permissions and tracking are configured.
  factory LocationTrackingState.initial() {
    return const LocationTrackingState(
      permissionLevel: LocationPermissionLevel.unknown,
      trackingMode: LocationTrackingMode.none,
      status: LocationStatus.idle,
      isActionInProgress: false,
      isServiceEnabled: true,
      isNotificationPermissionGranted: true,
    );
  }

  final LocationPermissionLevel permissionLevel;
  final LocationTrackingMode trackingMode;
  final LocationStatus status;
  final bool isActionInProgress;
  final bool isServiceEnabled;
  final bool isNotificationPermissionGranted;
  final LocationUpdate? lastLocation;

  bool get isTracking => trackingMode != LocationTrackingMode.none;

  bool get shouldShowOpenSettings {
    return permissionLevel == LocationPermissionLevel.deniedForever ||
        permissionLevel == LocationPermissionLevel.restricted ||
        status == LocationStatus.backgroundPermissionDenied ||
        status == LocationStatus.notificationPermissionDenied;
  }

  /// Creates a new state instance with selective overrides.
  LocationTrackingState copyWith({
    LocationPermissionLevel? permissionLevel,
    LocationTrackingMode? trackingMode,
    LocationStatus? status,
    bool? isActionInProgress,
    bool? isServiceEnabled,
    bool? isNotificationPermissionGranted,
    LocationUpdate? lastLocation,
    bool clearLastLocation = false,
  }) {
    return LocationTrackingState(
      permissionLevel: permissionLevel ?? this.permissionLevel,
      trackingMode: trackingMode ?? this.trackingMode,
      status: status ?? this.status,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      isServiceEnabled: isServiceEnabled ?? this.isServiceEnabled,
      isNotificationPermissionGranted:
          isNotificationPermissionGranted ?? this.isNotificationPermissionGranted,
      lastLocation: clearLastLocation ? null : (lastLocation ?? this.lastLocation),
    );
  }
}
