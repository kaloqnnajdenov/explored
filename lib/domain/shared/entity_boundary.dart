import 'package:latlong2/latlong.dart';

import 'geo_bounds.dart';

class EntityBoundaryPolygon {
  const EntityBoundaryPolygon({
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

class EntityBoundary {
  const EntityBoundary({required this.polygons});

  static const EntityBoundary empty = EntityBoundary(
    polygons: <EntityBoundaryPolygon>[],
  );

  final List<EntityBoundaryPolygon> polygons;

  bool get isEmpty => polygons.isEmpty;

  GeoBounds? get bounds {
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

    return GeoBounds(west: west, south: south, east: east, north: north);
  }
}
