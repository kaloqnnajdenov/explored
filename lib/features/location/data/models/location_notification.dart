/// Holds Android notification metadata for background location tracking.
class LocationNotification {
  const LocationNotification({
    required this.title,
    required this.message,
    required this.iconName,
  });

  final String title;
  final String message;
  final String iconName;
}
