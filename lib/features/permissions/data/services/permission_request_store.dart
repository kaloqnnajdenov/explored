import 'package:shared_preferences/shared_preferences.dart';

import 'package:explored/constants.dart';

abstract class PermissionRequestStore {
  Future<bool> hasRequestedPermissions();

  Future<void> markPermissionsRequested();
}

class SharedPreferencesPermissionRequestStore implements PermissionRequestStore {
  SharedPreferencesPermissionRequestStore({
    required SharedPreferences preferences,
  }) : _preferences = preferences;

  final SharedPreferences _preferences;

  @override
  Future<bool> hasRequestedPermissions() async {
    return _preferences.getBool(kPermissionsRequestedOnceKey) ?? false;
  }

  @override
  Future<void> markPermissionsRequested() async {
    await _preferences.setBool(kPermissionsRequestedOnceKey, true);
  }
}
