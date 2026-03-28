import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LegacySelectionService {
  const LegacySelectionService({required SharedPreferences preferences})
    : _preferences = preferences;

  static const String selectedPackIdKey = 'app_current_region_id';
  static const String selectedPackRefKey = 'app_selected_pack_ref_json';

  final SharedPreferences _preferences;

  String? readLegacySelectedEntityId() {
    final selectedId = _preferences.getString(selectedPackIdKey);
    if (selectedId != null && selectedId.isNotEmpty) {
      return selectedId;
    }

    final rawRef = _preferences.getString(selectedPackRefKey);
    if (rawRef == null || rawRef.isEmpty) {
      return null;
    }

    try {
      final decoded = Map<String, dynamic>.from(
        jsonDecode(rawRef) as Map<dynamic, dynamic>,
      );
      final id = decoded['id'] as String?;
      return id == null || id.isEmpty ? null : id;
    } catch (_) {
      return null;
    }
  }
}
