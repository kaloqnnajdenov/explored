import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_permission.dart';
import '../models/user_point.dart';

class AppStatePrefsService {
  AppStatePrefsService({required SharedPreferences preferences})
    : _preferences = preferences;

  static const String hasSeenOnboardingKey = 'app_has_seen_onboarding';
  static const String currentRegionIdKey = 'app_current_region_id';
  static const String permissionsKey = 'app_permissions_json';
  static const String userPointsKey = 'app_user_points_json';
  static const String downloadedRegionIdsKey = 'app_downloaded_region_ids';

  final SharedPreferences _preferences;

  bool readHasSeenOnboarding() {
    return _preferences.getBool(hasSeenOnboardingKey) ?? false;
  }

  Future<void> writeHasSeenOnboarding(bool value) {
    return _preferences.setBool(hasSeenOnboardingKey, value);
  }

  String? readCurrentRegionId() {
    return _preferences.getString(currentRegionIdKey);
  }

  Future<void> writeCurrentRegionId(String value) {
    return _preferences.setString(currentRegionIdKey, value);
  }

  Map<TrackingPermissionType, PermissionGrantState> readPermissions() {
    final raw = _preferences.getString(permissionsKey);
    if (raw == null || raw.isEmpty) {
      return _defaultPermissions();
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final values = <TrackingPermissionType, PermissionGrantState>{
        for (final permission in TrackingPermissionType.values)
          permission: PermissionGrantState.prompt,
      };
      for (final entry in decoded.entries) {
        final permission = TrackingPermissionTypeStorage.fromStorageKey(
          entry.key,
        );
        values[permission] = PermissionGrantStateStorage.fromStorageValue(
          entry.value as String,
        );
      }
      return values;
    } catch (_) {
      return _defaultPermissions();
    }
  }

  Future<void> writePermissions(
    Map<TrackingPermissionType, PermissionGrantState> values,
  ) {
    final map = <String, String>{
      for (final entry in values.entries)
        entry.key.storageKey: entry.value.storageValue,
    };
    return _preferences.setString(permissionsKey, jsonEncode(map));
  }

  Set<String> readDownloadedRegionIds() {
    final values = _preferences.getStringList(downloadedRegionIdsKey);
    if (values == null) {
      return <String>{};
    }
    return values.toSet();
  }

  Future<void> writeDownloadedRegionIds(Set<String> ids) {
    return _preferences.setStringList(downloadedRegionIdsKey, ids.toList());
  }

  List<UserPoint> readUserPoints() {
    final raw = _preferences.getString(userPointsKey);
    if (raw == null || raw.isEmpty) {
      return const <UserPoint>[];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((entry) => UserPoint.fromJson(entry as Map<String, Object?>))
          .toList(growable: false);
    } catch (_) {
      return const <UserPoint>[];
    }
  }

  Future<void> writeUserPoints(List<UserPoint> points) {
    final jsonList = points
        .map((point) => point.toJson())
        .toList(growable: false);
    return _preferences.setString(userPointsKey, jsonEncode(jsonList));
  }

  Map<TrackingPermissionType, PermissionGrantState> _defaultPermissions() {
    return {
      for (final permission in TrackingPermissionType.values)
        permission: PermissionGrantState.prompt,
    };
  }
}
