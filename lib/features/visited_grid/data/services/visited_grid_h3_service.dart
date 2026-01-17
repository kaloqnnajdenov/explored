import 'package:h3_flutter/h3_flutter.dart';
import 'package:latlong2/latlong.dart';

import '../models/visited_grid_bounds.dart';

class VisitedGridH3Service {
  VisitedGridH3Service({H3? h3}) : _h3 = h3 ?? const H3Factory().load();

  final H3 _h3;

  H3Index cellForLatLng({
    required double latitude,
    required double longitude,
    required int resolution,
  }) {
    return _h3.geoToCell(
      GeoCoord(lat: latitude, lon: longitude),
      resolution,
    );
  }

  H3Index parentCell({
    required H3Index cell,
    required int resolution,
  }) {
    return _h3.cellToParent(cell, resolution);
  }

  List<H3Index> polygonToCells({
    required VisitedGridBounds bounds,
    required int resolution,
  }) {
    final perimeter = [
      GeoCoord(lat: bounds.north, lon: bounds.west),
      GeoCoord(lat: bounds.north, lon: bounds.east),
      GeoCoord(lat: bounds.south, lon: bounds.east),
      GeoCoord(lat: bounds.south, lon: bounds.west),
    ];
    return _h3.polygonToCells(
      perimeter: perimeter,
      resolution: resolution,
    );
  }

  List<LatLng> cellBoundary(H3Index cell) {
    final boundary = _h3.cellToBoundary(cell);
    return boundary
        .map((coord) => LatLng(coord.lat, coord.lon))
        .toList(growable: false);
  }

  String encodeCellId(H3Index cell) => cell.toString();

  H3Index decodeCellId(String cellId) => BigInt.parse(cellId);
}
