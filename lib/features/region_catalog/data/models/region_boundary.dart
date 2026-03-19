import 'package:latlong2/latlong.dart';

import 'region_pack_bounds.dart';

class RegionBoundaryPolygon {
  const RegionBoundaryPolygon({
    required this.outerRing,
    this.holeRings = const <List<LatLng>>[],
  });

  final List<LatLng> outerRing;
  final List<List<LatLng>> holeRings;

  Iterable<LatLng> get allPoints sync* {
    yield* outerRing;
    for (final holeRing in holeRings) {
      yield* holeRing;
    }
  }
}

class RegionBoundary {
  const RegionBoundary({required this.polygons});

  static const empty = RegionBoundary(polygons: <RegionBoundaryPolygon>[]);

  final List<RegionBoundaryPolygon> polygons;

  bool get isEmpty => polygons.isEmpty;

  RegionPackBounds? get bounds {
    if (isEmpty) {
      return null;
    }

    var west = polygons.first.outerRing.first.longitude;
    var south = polygons.first.outerRing.first.latitude;
    var east = west;
    var north = south;

    for (final polygon in polygons) {
      for (final point in polygon.allPoints) {
        if (point.longitude < west) {
          west = point.longitude;
        }
        if (point.longitude > east) {
          east = point.longitude;
        }
        if (point.latitude < south) {
          south = point.latitude;
        }
        if (point.latitude > north) {
          north = point.latitude;
        }
      }
    }

    return RegionPackBounds(west: west, south: south, east: east, north: north);
  }
}
