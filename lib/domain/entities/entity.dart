import 'package:latlong2/latlong.dart';

import '../shared/geo_bounds.dart';
import 'entity_type.dart';

class Entity {
  const Entity({
    required this.entityId,
    required this.type,
    required this.name,
    required this.bbox,
    required this.centroid,
    required this.geometryGeoJson,
    required this.countrySlug,
    required this.updatedAt,
    this.osmType,
    this.osmId,
    this.areaId,
    this.adminLevel,
    this.countryId,
    this.regionId,
    this.cityId,
    this.packVersion,
  });

  final String entityId;
  final EntityType type;
  final String name;
  final String? osmType;
  final int? osmId;
  final String? areaId;
  final int? adminLevel;
  final GeoBounds bbox;
  final LatLng centroid;
  final String? countryId;
  final String? regionId;
  final String? cityId;
  final String geometryGeoJson;
  final String countrySlug;
  final String? packVersion;
  final int updatedAt;

  String? get parentEntityId {
    switch (type) {
      case EntityType.country:
        return null;
      case EntityType.region:
        return countryId;
      case EntityType.city:
        return regionId ?? countryId;
      case EntityType.cityCenter:
        return cityId;
    }
  }
}
