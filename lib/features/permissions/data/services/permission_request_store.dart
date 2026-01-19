import 'package:shared_preferences/shared_preferences.dart';

abstract class PermissionRequestStore {
  Future<bool> hasRequestedPermissions();

  Future<void> markPermissionsRequested();
}

class SharedPreferencesPermissionRequestStore implements PermissionRequestStore {
  SharedPreferencesPermissionRequestStore({
    required SharedPreferences preferences,
  }) : _preferences = preferences;

  static const String _requestedKey = 'permissions_requested_once';

  final SharedPreferences _preferences;

  @override
  Future<bool> hasRequestedPermissions() async {
    return _preferences.getBool(_requestedKey) ?? false;
  }

  @override
  Future<void> markPermissionsRequested() async {
    await _preferences.setBool(_requestedKey, true);
  }
}
