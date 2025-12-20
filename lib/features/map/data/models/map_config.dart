import 'package:latlong2/latlong.dart';

import 'map_tile_source.dart';

/// Immutable map configuration used to seed the map view (center/zoom/tiles).
class MapConfig {
  const MapConfig({
    required this.initialCenter,
    required this.initialZoom,
    required this.tileSource,
  });

  final LatLng initialCenter;
  final double initialZoom;
  final MapTileSource tileSource;
}
