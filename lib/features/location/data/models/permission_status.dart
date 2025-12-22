/// Describes the coarse permission status needed for tracking decisions.
enum PermissionStatus {
  granted,
  denied,
  restricted,
}

/// Adds convenience helpers for permission status checks.
extension PermissionStatusX on PermissionStatus {
  bool get isGranted => this == PermissionStatus.granted;
}
