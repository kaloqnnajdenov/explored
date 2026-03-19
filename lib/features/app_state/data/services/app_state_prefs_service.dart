import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_permission.dart';
import '../models/user_point.dart';
import '../../../region_catalog/data/models/selected_pack_ref.dart';

class AppStatePrefsService {
  AppStatePrefsService({required SharedPreferences preferences})
    : _preferences = preferences;

  static const String hasSeenOnboardingKey = 'app_has_seen_onboarding';
  static const String selectedPackIdKey = 'app_current_region_id';
  static const String currentRegionIdKey = selectedPackIdKey;
  static const String selectedPackRefKey = 'app_selected_pack_ref_json';
  static const String permissionsKey = 'app_permissions_json';
  static const String userPointsKey = 'app_user_points_json';
  static const String downloadedPackIdsKey = 'app_downloaded_region_ids';
  static const String downloadedRegionIdsKey = downloadedPackIdsKey;
  static const String downloadedPackRefsKey = 'app_downloaded_pack_refs_json';

  final SharedPreferences _preferences;

  bool readHasSeenOnboarding() {
    return _preferences.getBool(hasSeenOnboardingKey) ?? false;
  }

  Future<void> writeHasSeenOnboarding(bool value) {
    return _preferences.setBool(hasSeenOnboardingKey, value);
  }

  String? readSelectedPackId() {
    return _preferences.getString(selectedPackIdKey);
  }

  Future<void> writeSelectedPackId(String value) {
    return _preferences.setString(selectedPackIdKey, value);
  }

  SelectedPackRef? readSelectedPackRef() {
    final raw = _preferences.getString(selectedPackRefKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      return SelectedPackRef.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> writeSelectedPackRef(SelectedPackRef value) async {
    await _preferences.setString(selectedPackIdKey, value.id);
    await _preferences.setString(
      selectedPackRefKey,
      jsonEncode(value.toJson()),
    );
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

  Set<String> readDownloadedPackIds() {
    final values = _preferences.getStringList(downloadedPackIdsKey);
    if (values == null) {
      return <String>{};
    }
    return values.toSet();
  }

  Future<void> writeDownloadedPackIds(Set<String> ids) {
    return _preferences.setStringList(downloadedPackIdsKey, ids.toList());
  }

  List<SelectedPackRef> readDownloadedPackRefs() {
    final raw = _preferences.getString(downloadedPackRefsKey);
    if (raw == null || raw.isEmpty) {
      return const <SelectedPackRef>[];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (entry) => SelectedPackRef.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return const <SelectedPackRef>[];
    }
  }

  Future<void> writeDownloadedPackRefs(List<SelectedPackRef> refs) async {
    await _preferences.setStringList(
      downloadedPackIdsKey,
      refs.map((ref) => ref.id).toList(growable: false),
    );
    await _preferences.setString(
      downloadedPackRefsKey,
      jsonEncode(refs.map((ref) => ref.toJson()).toList(growable: false)),
    );
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
