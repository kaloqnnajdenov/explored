import 'package:latlong2/latlong.dart';

class VisitedGridOverlay {
  const VisitedGridOverlay({
    required this.resolution,
    required this.polygons,
  });

  final int resolution;
  final List<List<LatLng>> polygons;
}
