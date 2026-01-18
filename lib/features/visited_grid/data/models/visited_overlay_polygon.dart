import 'package:latlong2/latlong.dart';

class VisitedOverlayPolygon {
  const VisitedOverlayPolygon({
    required this.outer,
    this.holes = const [],
  });

  final List<LatLng> outer;
  final List<List<LatLng>> holes;
}
