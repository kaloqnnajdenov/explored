import 'dart:convert';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class GeoBounds {
  const GeoBounds({
    required this.west,
    required this.south,
    required this.east,
    required this.north,
  });

  factory GeoBounds.fromList(List<dynamic> raw) {
    return GeoBounds(
      west: (raw[0] as num).toDouble(),
      south: (raw[1] as num).toDouble(),
      east: (raw[2] as num).toDouble(),
      north: (raw[3] as num).toDouble(),
    );
  }

  factory GeoBounds.fromJsonString(String raw) {
    return GeoBounds.fromList(jsonDecode(raw) as List<dynamic>);
  }

  final double west;
  final double south;
  final double east;
  final double north;

  LatLng get center => LatLng((south + north) / 2, (west + east) / 2);

  LatLngBounds toLatLngBounds() {
    return LatLngBounds.unsafe(
      west: west,
      south: south,
      east: east,
      north: north,
    );
  }

  String toJsonString() => jsonEncode([west, south, east, north]);
}
