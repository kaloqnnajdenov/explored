enum AppPermissionType {
  locationForeground,
  locationBackground,
  motionActivity,
  notifications,
  fileAccess,
}

class AppPermissionStatus {
  const AppPermissionStatus({
    required this.type,
    required this.isGranted,
    this.isInteractive = true,
    this.helperMessageKey,
  });

  final AppPermissionType type;
  final bool isGranted;
  final bool isInteractive;
  final String? helperMessageKey;
}
