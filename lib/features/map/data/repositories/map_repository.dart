import 'package:latlong2/latlong.dart';

import '../models/map_config.dart';
import '../models/map_point_of_interest.dart';
import '../models/map_point_of_interest_marker.dart';
import '../models/map_tile_source.dart';
import '../services/map_attribution_service.dart';
import '../services/map_point_cluster_service.dart';
import '../services/map_tile_service.dart';

/// Single source of truth for map configuration; keeps services hidden from
/// ViewModels and allows swapping providers later.
class MapRepository {
  MapRepository({
    required MapTileService tileService,
    required MapAttributionService attributionService,
    MapPointClusterService? pointClusterService,
  }) : _tileService = tileService,
       _attributionService = attributionService,
       _pointClusterService =
           pointClusterService ?? const GridMapPointClusterService();

  final MapTileService _tileService;
  final MapAttributionService _attributionService;
  final MapPointClusterService _pointClusterService;

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

  List<MapPointOfInterestMarker> buildPointOfInterestMarkers({
    required List<MapPointOfInterest> pointsOfInterest,
    required double zoom,
  }) {
    return _pointClusterService.buildMarkers(
      pointsOfInterest: pointsOfInterest,
      zoom: zoom,
    );
  }

  /// Opens the map attribution link as required by the tile provider.
  Future<void> openAttribution() {
    return _attributionService.openAttribution();
  }
}
