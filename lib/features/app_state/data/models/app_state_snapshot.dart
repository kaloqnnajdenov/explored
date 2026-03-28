import 'app_permission.dart';
import 'user_point.dart';

class AppStateSnapshot {
  const AppStateSnapshot({
    required this.hasSeenOnboarding,
    required this.permissions,
    required this.isTracking,
    required this.userPoints,
  });

  final bool hasSeenOnboarding;
  final Map<TrackingPermissionType, PermissionGrantState> permissions;
  final bool isTracking;
  final List<UserPoint> userPoints;

  AppStateSnapshot copyWith({
    bool? hasSeenOnboarding,
    Map<TrackingPermissionType, PermissionGrantState>? permissions,
    bool? isTracking,
    List<UserPoint>? userPoints,
  }) {
    return AppStateSnapshot(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      permissions: permissions ?? this.permissions,
      isTracking: isTracking ?? this.isTracking,
      userPoints: userPoints ?? this.userPoints,
    );
  }
}
