import '../models/map_tile_source.dart';

/// Provides the tile source definition; keeps IO/platform concerns out of
/// higher layers.
abstract class MapTileService {
  /// Returns the tile source descriptor for the current map provider.
  MapTileSource getTileSource();
}

/// Static OpenStreetMap tile descriptor; replace or extend when adding other
/// providers (e.g., cached tiles or premium sources).
class OpenStreetMapTileService implements MapTileService {
  @override
  MapTileSource getTileSource() {
    return const MapTileSource(
      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      subdomains: ['a', 'b', 'c'],
      userAgentPackageName: 'com.explored.app',
    );
  }
}
