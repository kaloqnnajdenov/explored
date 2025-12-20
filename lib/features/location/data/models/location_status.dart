/// Represents the latest user-facing status for location tracking.
enum LocationStatus {
  idle,
  requestingPermission,
  permissionDenied,
  backgroundPermissionDenied,
  permissionDeniedForever,
  permissionRestricted,
  notificationPermissionDenied,
  locationServicesDisabled,
  trackingStartedForeground,
  trackingStartedBackground,
  trackingStopped,
  error,
}
