import '../models/map_tile_source.dart';

/// Provides the tile source definition; keeps IO/platform concerns out of
/// higher layers.
abstract class MapTileService {
  /// Returns the tile source descriptor for the current map provider.
  MapTileSource getTileSource();
}

/// MapTiler tile descriptor for raster map rendering.
class MapTilerTileService implements MapTileService {
  MapTilerTileService({
    required String apiKey,
    this.mapId = 'streets-v2',
    this.userAgentPackageName = 'com.explored.app',
  }) : _apiKey = apiKey.trim();

  final String _apiKey;
  final String mapId;
  final String userAgentPackageName;

  @override
  MapTileSource getTileSource() {
    return MapTileSource(
      urlTemplate:
          'https://api.maptiler.com/maps/$mapId/{z}/{x}/{y}.png?key=$_apiKey',
      subdomains: const [],
      userAgentPackageName: userAgentPackageName,
    );
  }
}

/// Static OpenStreetMap tile descriptor; replace or extend when adding other
/// providers (e.g., cached tiles or premium sources).
class OpenStreetMapTileService implements MapTileService {
  @override
  MapTileSource getTileSource() {
    return const MapTileSource(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      subdomains: ['a', 'b', 'c'],
      userAgentPackageName: 'com.explored.app',
    );
  }
}
