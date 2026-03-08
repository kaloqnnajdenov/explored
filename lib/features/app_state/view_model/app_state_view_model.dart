import 'package:flutter/foundation.dart';

import '../data/models/app_permission.dart';
import '../data/models/app_state_snapshot.dart';
import '../data/models/gps_quality.dart';
import '../data/models/region.dart';
import '../data/models/user_point.dart';
import '../data/repositories/app_state_repository.dart';

class AppStateViewModel extends ChangeNotifier {
  AppStateViewModel({
    required AppStateRepository repository,
    required AppStateSnapshot initialState,
  }) : _repository = repository,
       _state = initialState;

  final AppStateRepository _repository;

  AppStateSnapshot _state;

  bool get hasSeenOnboarding => _state.hasSeenOnboarding;

  Map<TrackingPermissionType, PermissionGrantState> get permissions =>
      _state.permissions;

  bool get isTracking => _state.isTracking;

  GpsQuality get gpsQuality => _state.gpsQuality;

  List<Region> get regions => _state.regions;

  String get currentRegionId => _state.currentRegionId;

  Region get currentRegion {
    return _state.regions.firstWhere(
      (region) => region.id == _state.currentRegionId,
      orElse: () => _state.regions.first,
    );
  }

  List<UserPoint> get userPoints => _state.userPoints;

  Future<void> setHasSeenOnboarding(bool value) async {
    _state = _state.copyWith(hasSeenOnboarding: value);
    notifyListeners();
    await _repository.setHasSeenOnboarding(value);
  }

  Future<void> setPermission(
    TrackingPermissionType type,
    PermissionGrantState state,
  ) async {
    final updated = Map<TrackingPermissionType, PermissionGrantState>.from(
      _state.permissions,
    )..[type] = state;
    _state = _state.copyWith(permissions: updated);
    notifyListeners();
    await _repository.setPermissions(updated);
  }

  Future<void> setPermissions(
    Map<TrackingPermissionType, PermissionGrantState> values,
  ) async {
    _state = _state.copyWith(
      permissions: Map<TrackingPermissionType, PermissionGrantState>.from(
        values,
      ),
    );
    notifyListeners();
    await _repository.setPermissions(_state.permissions);
  }

  Future<void> setCurrentRegionId(String id) async {
    if (!_state.regions.any((region) => region.id == id)) {
      return;
    }
    _state = _state.copyWith(currentRegionId: id);
    notifyListeners();
    await _repository.setCurrentRegionId(id);
  }

  Future<void> downloadRegion(String id) async {
    final updatedRegions = _state.regions
        .map(
          (region) =>
              region.id == id ? region.copyWith(isDownloaded: true) : region,
        )
        .toList(growable: false);
    _state = _state.copyWith(regions: updatedRegions);
    notifyListeners();
    await _repository.setDownloadedRegionIds(
      updatedRegions
          .where((region) => region.isDownloaded)
          .map((region) => region.id)
          .toSet(),
    );
  }

  Future<void> setGpsQuality(GpsQuality quality) async {
    if (_state.gpsQuality == quality) {
      return;
    }
    _state = _state.copyWith(gpsQuality: quality);
    notifyListeners();
  }

  Future<void> addUserPoint(double latitude, double longitude) async {
    final newPoint = UserPoint(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      latitude: latitude,
      longitude: longitude,
      createdAt: DateTime.now().toUtc(),
    );
    final updatedPoints = List<UserPoint>.from(_state.userPoints)
      ..add(newPoint);
    _state = _state.copyWith(userPoints: updatedPoints);
    notifyListeners();
    await _repository.setUserPoints(updatedPoints);
  }

  Future<void> removeUserPoint(String id) async {
    final updatedPoints = _state.userPoints
        .where((point) => point.id != id)
        .toList(growable: false);
    _state = _state.copyWith(userPoints: updatedPoints);
    notifyListeners();
    await _repository.setUserPoints(updatedPoints);
  }
}
