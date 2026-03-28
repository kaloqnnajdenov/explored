import 'package:latlong2/latlong.dart';

import '../../../../domain/shared/geo_bounds.dart';

class CountryPackDescriptor {
  const CountryPackDescriptor({
    required this.countrySlug,
    required this.countryEntityId,
    required this.countryName,
    this.packVersion,
    this.bbox,
    this.centroid,
  });

  final String countrySlug;
  final String countryEntityId;
  final String countryName;
  final String? packVersion;
  final GeoBounds? bbox;
  final LatLng? centroid;
}
