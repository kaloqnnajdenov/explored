import 'package:latlong2/latlong.dart';

import '../models/map_config.dart';
import '../models/map_tile_source.dart';
import '../services/map_attribution_service.dart';
import '../services/map_tile_service.dart';

/// Single source of truth for map configuration; keeps services hidden from
/// ViewModels and allows swapping providers later.
class MapRepository {
  MapRepository({
    required MapTileService tileService,
    required MapAttributionService attributionService,
  })  : _tileService = tileService,
        _attributionService = attributionService;

  final MapTileService _tileService;
  final MapAttributionService _attributionService;

  /// Returns the base map configuration used for initial render.
  MapConfig getMapConfig() {
    final tileSource = _tileService.getTileSource();

    return MapConfig(
      initialCenter: const LatLng(0, 0),
      initialZoom: 2.5,
      tileSource: tileSource,
    );
  }

  /// Exposes raw tile source; useful for specialized consumers if needed.
  MapTileSource getTileSource() => _tileService.getTileSource();

  /// Opens the map attribution link as required by the tile provider.
  Future<void> openAttribution() {
    return _attributionService.openAttribution();
  }
}
