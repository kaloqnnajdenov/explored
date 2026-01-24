import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:explored/features/map/data/services/map_overlay_settings_service.dart';

void main() {
  test('Saves and loads overlay tile size', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final service = SharedPreferencesMapOverlaySettingsService(
      preferences: preferences,
    );

    expect(await service.loadTileSize(), isNull);

    await service.saveTileSize(512);
    expect(await service.loadTileSize(), 512);
  });
}
