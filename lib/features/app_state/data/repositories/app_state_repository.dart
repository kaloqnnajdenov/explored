import '../models/app_permission.dart';
import '../models/app_state_snapshot.dart';
import '../models/user_point.dart';
import '../services/app_state_prefs_service.dart';

abstract class AppStateRepository {
  AppStateSnapshot createInitialState();

  Future<void> setHasSeenOnboarding(bool value);

  Future<void> setPermissions(
    Map<TrackingPermissionType, PermissionGrantState> permissions,
  );

  Future<void> setUserPoints(List<UserPoint> points);
}

class DefaultAppStateRepository implements AppStateRepository {
  DefaultAppStateRepository({required AppStatePrefsService prefsService})
    : _prefsService = prefsService;

  final AppStatePrefsService _prefsService;

  @override
  AppStateSnapshot createInitialState() {
    return AppStateSnapshot(
      hasSeenOnboarding: _prefsService.readHasSeenOnboarding(),
      permissions: _prefsService.readPermissions(),
      isTracking: true,
      userPoints: _prefsService.readUserPoints(),
    );
  }

  @override
  Future<void> setHasSeenOnboarding(bool value) {
    return _prefsService.writeHasSeenOnboarding(value);
  }

  @override
  Future<void> setPermissions(
    Map<TrackingPermissionType, PermissionGrantState> permissions,
  ) {
    return _prefsService.writePermissions(permissions);
  }

  @override
  Future<void> setUserPoints(List<UserPoint> points) {
    return _prefsService.writeUserPoints(points);
  }
}
