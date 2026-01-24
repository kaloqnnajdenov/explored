import 'package:shared_preferences/shared_preferences.dart';

import '../../../../constants.dart';

abstract class MapOverlaySettingsService {
  Future<int?> loadTileSize();
  Future<void> saveTileSize(int size);
}

class SharedPreferencesMapOverlaySettingsService
    implements MapOverlaySettingsService {
  SharedPreferencesMapOverlaySettingsService({
    required SharedPreferences preferences,
  }) : _preferences = preferences;

  final SharedPreferences _preferences;

  @override
  Future<int?> loadTileSize() async {
    return _preferences.getInt(kMapOverlayTileSizeKey);
  }

  @override
  Future<void> saveTileSize(int size) async {
    await _preferences.setInt(kMapOverlayTileSizeKey, size);
  }
}
