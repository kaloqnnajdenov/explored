import 'package:latlong2/latlong.dart';

import '../../../../domain/objects/object_category.dart';

class MapPointOfInterest {
  const MapPointOfInterest({
    required this.id,
    required this.category,
    required this.position,
    this.name,
  });

  final String id;
  final ObjectCategory category;
  final LatLng position;
  final String? name;
}
