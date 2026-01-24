import 'package:latlong2/latlong.dart';

import '../models/map_config.dart';
import '../models/map_tile_source.dart';
import '../models/overlay_tile_size.dart';
import '../services/map_attribution_service.dart';
import '../services/map_tile_service.dart';
import '../services/map_overlay_settings_service.dart';

/// Single source of truth for map configuration; keeps services hidden from
/// ViewModels and allows swapping providers later.
class MapRepository {
  MapRepository({
    required MapTileService tileService,
    required MapAttributionService attributionService,
    required MapOverlaySettingsService overlaySettingsService,
  })  : _tileService = tileService,
        _attributionService = attributionService,
        _overlaySettingsService = overlaySettingsService;

  final MapTileService _tileService;
  final MapAttributionService _attributionService;
  final MapOverlaySettingsService _overlaySettingsService;

  /// Returns the base map configuration used for initial render.
  MapConfig getMapConfig() {
    final tileSource = _tileService.getTileSource();

    return MapConfig(
      initialCenter: const LatLng(0, 0),
      initialZoom: 2.5,
      recenterZoom: 10.5,
      tileSource: tileSource,
    );
  }

  /// Exposes raw tile source; useful for specialized consumers if needed.
  MapTileSource getTileSource() => _tileService.getTileSource();

  /// Opens the map attribution link as required by the tile provider.
  Future<void> openAttribution() {
    return _attributionService.openAttribution();
  }

  /// Returns the persisted overlay tile size selection.
  Future<OverlayTileSize> fetchOverlayTileSize({
    OverlayTileSize fallback = OverlayTileSize.s256,
  }) async {
    final stored = await _overlaySettingsService.loadTileSize();
    if (stored == null) {
      return fallback;
    }
    return OverlayTileSize.fromSize(stored);
  }

  /// Persists the overlay tile size selection.
  Future<void> setOverlayTileSize(OverlayTileSize size) {
    return _overlaySettingsService.saveTileSize(size.size);
  }
}
