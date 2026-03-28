import 'package:latlong2/latlong.dart';

import '../../../../domain/entities/entity_type.dart';
import '../../../../domain/shared/geo_bounds.dart';

class ParsedEntityRow {
  const ParsedEntityRow({
    required this.entityId,
    required this.type,
    required this.name,
    required this.bbox,
    required this.centroid,
    required this.geometryGeoJson,
    required this.countrySlug,
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
}
