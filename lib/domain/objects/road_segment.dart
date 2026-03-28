class RoadSegment {
  const RoadSegment({
    required this.objectId,
    required this.lengthM,
    required this.geometryGeoJson,
    required this.countrySlug,
    required this.updatedAt,
    this.drivable,
    this.walkable,
    this.cycleway,
    this.name,
    this.countryId,
    this.regionId,
    this.cityId,
    this.cityCenterId,
  });

  final String objectId;
  final bool? drivable;
  final bool? walkable;
  final bool? cycleway;
  final double lengthM;
  final String geometryGeoJson;
  final String? name;
  final String? countryId;
  final String? regionId;
  final String? cityId;
  final String? cityCenterId;
  final String countrySlug;
  final int updatedAt;
}
