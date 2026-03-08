import 'app_permission.dart';
import 'gps_quality.dart';
import 'region.dart';
import 'user_point.dart';

class AppStateSnapshot {
  const AppStateSnapshot({
    required this.hasSeenOnboarding,
    required this.permissions,
    required this.isTracking,
    required this.gpsQuality,
    required this.regions,
    required this.currentRegionId,
    required this.userPoints,
  });

  final bool hasSeenOnboarding;
  final Map<TrackingPermissionType, PermissionGrantState> permissions;
  final bool isTracking;
  final GpsQuality gpsQuality;
  final List<Region> regions;
  final String currentRegionId;
  final List<UserPoint> userPoints;

  AppStateSnapshot copyWith({
    bool? hasSeenOnboarding,
    Map<TrackingPermissionType, PermissionGrantState>? permissions,
    bool? isTracking,
    GpsQuality? gpsQuality,
    List<Region>? regions,
    String? currentRegionId,
    List<UserPoint>? userPoints,
  }) {
    return AppStateSnapshot(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      permissions: permissions ?? this.permissions,
      isTracking: isTracking ?? this.isTracking,
      gpsQuality: gpsQuality ?? this.gpsQuality,
      regions: regions ?? this.regions,
      currentRegionId: currentRegionId ?? this.currentRegionId,
      userPoints: userPoints ?? this.userPoints,
    );
  }
}
