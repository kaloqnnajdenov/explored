import 'package:shared_preferences/shared_preferences.dart';

class LocalUserPrefsService {
  LocalUserPrefsService({required SharedPreferences preferences})
    : _preferences = preferences;

  static const String localUserIdKey = 'local_user_id';
  static const String selectedCountrySlugKey = 'selected_country_slug';

  final SharedPreferences _preferences;

  String readOrCreateUserId() {
    final existing = _preferences.getString(localUserIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final created = 'local:${DateTime.now().toUtc().microsecondsSinceEpoch}';
    _preferences.setString(localUserIdKey, created);
    return created;
  }

  String? readSelectedCountrySlug() {
    final existing = _preferences.getString(selectedCountrySlugKey);
    if (existing == null || existing.isEmpty) {
      return null;
    }
    return existing;
  }

  void writeSelectedCountrySlug(String countrySlug) {
    if (countrySlug.isEmpty) {
      return;
    }
    _preferences.setString(selectedCountrySlugKey, countrySlug);
  }
}
