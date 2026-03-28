import 'package:latlong2/latlong.dart';

import '../../../../domain/objects/object_category.dart';
import 'map_point_of_interest.dart';

class MapPointOfInterestMarker {
  const MapPointOfInterestMarker._({
    required this.id,
    required this.category,
    required this.position,
    required this.count,
    this.name,
  });

  factory MapPointOfInterestMarker.single(MapPointOfInterest point) {
    return MapPointOfInterestMarker._(
      id: point.id,
      category: point.category,
      position: point.position,
      count: 1,
      name: point.name,
    );
  }

  factory MapPointOfInterestMarker.cluster({
    required String id,
    required ObjectCategory category,
    required LatLng position,
    required int count,
  }) {
    return MapPointOfInterestMarker._(
      id: id,
      category: category,
      position: position,
      count: count,
    );
  }

  final String id;
  final ObjectCategory category;
  final LatLng position;
  final int count;
  final String? name;

  bool get isCluster => count > 1;
}
