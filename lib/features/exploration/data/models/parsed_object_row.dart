import '../../../../domain/objects/object_category.dart';

class ParsedObjectRow {
  const ParsedObjectRow({
    required this.objectId,
    required this.category,
    required this.geometryGeoJson,
    required this.countrySlug,
    this.subtype,
    this.name,
    this.countryId,
    this.regionId,
    this.cityId,
    this.cityCenterId,
    this.drivable,
    this.walkable,
    this.cycleway,
    this.lengthM,
  });

  final String objectId;
  final ObjectCategory category;
  final String? subtype;
  final String? name;
  final String geometryGeoJson;
  final String? countryId;
  final String? regionId;
  final String? cityId;
  final String? cityCenterId;
  final bool? drivable;
  final bool? walkable;
  final bool? cycleway;
  final double? lengthM;
  final String countrySlug;
}
