import 'package:h3_flutter/h3_flutter.dart';
import 'package:latlong2/latlong.dart';

import '../models/visited_grid_bounds.dart';
import '../models/visited_grid_cell_bounds.dart';

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

  GeoCoord cellToGeo(H3Index cell) => _h3.cellToGeo(cell);

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

  List<List<List<GeoCoord>>> cellsToMultiPolygon(List<H3Index> cells) {
    return _h3.cellsToMultiPolygon(cells);
  }

  double cellArea(H3Index cell, H3Units unit) {
    return _h3.cellArea(cell, unit);
  }

  List<H3Index> compactCells(List<H3Index> cells) {
    return _h3.compactCells(cells);
  }

  List<VisitedGridCellBounds> cellBounds(H3Index cell) {
    final center = _h3.cellToGeo(cell);
    final boundary = _h3.cellToBoundary(cell);
    if (boundary.isEmpty) {
      return const [];
    }

    var minLat = boundary.first.lat;
    var maxLat = boundary.first.lat;
    var minLon = _unwrapLon(boundary.first.lon, center.lon);
    var maxLon = minLon;

    for (final coord in boundary.skip(1)) {
      if (coord.lat < minLat) {
        minLat = coord.lat;
      }
      if (coord.lat > maxLat) {
        maxLat = coord.lat;
      }
      final lon = _unwrapLon(coord.lon, center.lon);
      if (lon < minLon) {
        minLon = lon;
      }
      if (lon > maxLon) {
        maxLon = lon;
      }
    }

    final resolution = _h3.getResolution(cell);
    final cellId = cell.toString();
    final minLatE5 = (minLat * 100000).floor();
    final maxLatE5 = (maxLat * 100000).ceil();

    if (maxLon > 180) {
      final first = VisitedGridCellBounds(
        resolution: resolution,
        cellId: cellId,
        segment: 0,
        minLatE5: minLatE5,
        maxLatE5: maxLatE5,
        minLonE5: (minLon * 100000).floor(),
        maxLonE5: 18000000,
      );
      final second = VisitedGridCellBounds(
        resolution: resolution,
        cellId: cellId,
        segment: 1,
        minLatE5: minLatE5,
        maxLatE5: maxLatE5,
        minLonE5: -18000000,
        maxLonE5: ((maxLon - 360) * 100000).ceil(),
      );
      return [first, second];
    }

    if (minLon < -180) {
      final first = VisitedGridCellBounds(
        resolution: resolution,
        cellId: cellId,
        segment: 0,
        minLatE5: minLatE5,
        maxLatE5: maxLatE5,
        minLonE5: ((minLon + 360) * 100000).floor(),
        maxLonE5: 18000000,
      );
      final second = VisitedGridCellBounds(
        resolution: resolution,
        cellId: cellId,
        segment: 1,
        minLatE5: minLatE5,
        maxLatE5: maxLatE5,
        minLonE5: -18000000,
        maxLonE5: (maxLon * 100000).ceil(),
      );
      return [first, second];
    }

    return [
      VisitedGridCellBounds(
        resolution: resolution,
        cellId: cellId,
        segment: 0,
        minLatE5: minLatE5,
        maxLatE5: maxLatE5,
        minLonE5: (minLon * 100000).floor(),
        maxLonE5: (maxLon * 100000).ceil(),
      ),
    ];
  }

  double _unwrapLon(double lon, double centerLon) {
    var adjusted = lon;
    while (adjusted - centerLon > 180) {
      adjusted -= 360;
    }
    while (adjusted - centerLon < -180) {
      adjusted += 360;
    }
    return adjusted;
  }

  String encodeCellId(H3Index cell) => cell.toString();

  H3Index decodeCellId(String cellId) => BigInt.parse(cellId);
}
