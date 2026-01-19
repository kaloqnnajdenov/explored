enum AppPermissionType {
  locationForeground,
  locationBackground,
  notifications,
  fileAccess,
}

class AppPermissionStatus {
  const AppPermissionStatus({required this.type, required this.isGranted});

  final AppPermissionType type;
  final bool isGranted;
}
