enum RegionPackKind {
  country,
  region,
  city,
  cityCenter;

  static RegionPackKind fromRaw(String raw) {
    switch (raw) {
      case 'country':
        return RegionPackKind.country;
      case 'region':
        return RegionPackKind.region;
      case 'city':
        return RegionPackKind.city;
      case 'city_center':
        return RegionPackKind.cityCenter;
    }

    throw ArgumentError.value(raw, 'raw', 'Unsupported region pack kind');
  }

  String get rawValue {
    switch (this) {
      case RegionPackKind.country:
        return 'country';
      case RegionPackKind.region:
        return 'region';
      case RegionPackKind.city:
        return 'city';
      case RegionPackKind.cityCenter:
        return 'city_center';
    }
  }
}
