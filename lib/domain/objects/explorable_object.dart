import 'object_category.dart';

class ExplorableObject {
  const ExplorableObject({
    required this.objectId,
    required this.category,
    required this.geometryGeoJson,
    required this.countrySlug,
    required this.updatedAt,
    this.subtype,
    this.name,
    this.countryId,
    this.regionId,
    this.cityId,
    this.cityCenterId,
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
  final String countrySlug;
  final int updatedAt;
}
