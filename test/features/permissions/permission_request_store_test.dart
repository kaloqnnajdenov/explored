import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:explored/features/permissions/data/services/permission_request_store.dart';

void main() {
  test('PermissionRequestStore persists the initial request flag', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = SharedPreferencesPermissionRequestStore(
      preferences: prefs,
    );

    final initial = await store.hasRequestedPermissions();
    expect(initial, isFalse);

    await store.markPermissionsRequested();

    final after = await store.hasRequestedPermissions();
    expect(after, isTrue);
  });
}
