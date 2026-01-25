import 'package:h3_flutter/h3_flutter.dart';

import '../../../../constants.dart';

/// Computes canonical H3 cell ids for persisted location history rows.
class LocationHistoryH3Service {
  LocationHistoryH3Service({
    H3? h3,
    int baseResolution = kBaseH3Resolution,
    String Function(double latitude, double longitude)? cellIdResolver,
  })  : _h3 = cellIdResolver == null
            ? (h3 ?? const H3Factory().load())
            : null,
        _baseResolution = baseResolution,
        _cellIdResolver = cellIdResolver;

  final H3? _h3;
  final int _baseResolution;
  final String Function(double latitude, double longitude)? _cellIdResolver;

  H3Index cellForLatLng({
    required double latitude,
    required double longitude,
  }) {
    final h3 = _h3;
    if (h3 == null) {
      throw StateError('H3 engine not available for cellForLatLng.');
    }
    return h3.geoToCell(
      GeoCoord(lat: latitude, lon: longitude),
      _baseResolution,
    );
  }

  String cellIdForLatLng({
    required double latitude,
    required double longitude,
  }) {
    final resolver = _cellIdResolver;
    if (resolver != null) {
      return resolver(latitude, longitude);
    }
    return cellForLatLng(latitude: latitude, longitude: longitude).toString();
  }
}
