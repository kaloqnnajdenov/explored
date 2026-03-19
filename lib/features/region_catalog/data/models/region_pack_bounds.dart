import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RegionPackBounds {
  const RegionPackBounds({
    required this.west,
    required this.south,
    required this.east,
    required this.north,
  });

  factory RegionPackBounds.fromList(List<dynamic> rawBounds) {
    return RegionPackBounds(
      west: (rawBounds[0] as num).toDouble(),
      south: (rawBounds[1] as num).toDouble(),
      east: (rawBounds[2] as num).toDouble(),
      north: (rawBounds[3] as num).toDouble(),
    );
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

  RegionPackBounds copyWith({
    double? west,
    double? south,
    double? east,
    double? north,
  }) {
    return RegionPackBounds(
      west: west ?? this.west,
      south: south ?? this.south,
      east: east ?? this.east,
      north: north ?? this.north,
    );
  }
}
