enum EntityType {
  country,
  region,
  city,
  cityCenter;

  static EntityType fromRaw(String raw) {
    switch (raw) {
      case 'country':
        return EntityType.country;
      case 'region':
        return EntityType.region;
      case 'city':
        return EntityType.city;
      case 'city_center':
        return EntityType.cityCenter;
    }
    throw ArgumentError.value(raw, 'raw', 'Unsupported entity type');
  }

  String get rawValue {
    switch (this) {
      case EntityType.country:
        return 'country';
      case EntityType.region:
        return 'region';
      case EntityType.city:
        return 'city';
      case EntityType.cityCenter:
        return 'city_center';
    }
  }
}
