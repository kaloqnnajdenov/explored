import 'visited_overlay_polygon.dart';

class VisitedGridOverlay {
  const VisitedGridOverlay({
    required this.resolution,
    required this.polygons,
  });

  final int resolution;
  final List<VisitedOverlayPolygon> polygons;
}
