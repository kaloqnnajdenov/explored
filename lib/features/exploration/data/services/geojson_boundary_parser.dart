import 'dart:convert';

import 'package:latlong2/latlong.dart';

import '../../../../domain/shared/entity_boundary.dart';

class GeoJsonBoundaryParser {
  const GeoJsonBoundaryParser();

  EntityBoundary parseString(String raw) {
    return parseJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  EntityBoundary parseJson(Map<String, dynamic> geoJson) {
    final geometry = _extractGeometry(geoJson);
    if (geometry == null) {
      return EntityBoundary.empty;
    }

    final type = geometry['type'] as String?;
    final coordinates = geometry['coordinates'];
    if (type == null || coordinates == null) {
      return EntityBoundary.empty;
    }

    switch (type) {
      case 'Polygon':
        return EntityBoundary(
          polygons: [_parsePolygon(coordinates as List<dynamic>)],
        );
      case 'MultiPolygon':
        return EntityBoundary(
          polygons: (coordinates as List<dynamic>)
              .map((polygon) => _parsePolygon(polygon as List<dynamic>))
              .where((polygon) => polygon.outerRing.isNotEmpty)
              .toList(growable: false),
        );
      default:
        return EntityBoundary.empty;
    }
  }

  Map<String, dynamic>? _extractGeometry(Map<String, dynamic> geoJson) {
    final type = geoJson['type'];
    if (type == 'FeatureCollection') {
      final features = geoJson['features'] as List<dynamic>? ?? const <dynamic>[];
      if (features.isEmpty) {
        return null;
      }
      final feature = Map<String, dynamic>.from(features.first as Map);
      final geometry = feature['geometry'];
      if (geometry is Map) {
        return Map<String, dynamic>.from(geometry);
      }
      return null;
    }
    if (type == 'Feature') {
      final geometry = geoJson['geometry'];
      if (geometry is Map) {
        return Map<String, dynamic>.from(geometry);
      }
      return null;
    }
    return geoJson;
  }

  EntityBoundaryPolygon _parsePolygon(List<dynamic> rawPolygon) {
    if (rawPolygon.isEmpty) {
      return const EntityBoundaryPolygon(outerRing: <LatLng>[]);
    }

    final rings = rawPolygon
        .map((ring) => _parseRing(ring as List<dynamic>))
        .where((ring) => ring.isNotEmpty)
        .toList(growable: false);
    if (rings.isEmpty) {
      return const EntityBoundaryPolygon(outerRing: <LatLng>[]);
    }

    return EntityBoundaryPolygon(
      outerRing: rings.first,
      holeRings: rings.skip(1).toList(growable: false),
    );
  }

  List<LatLng> _parseRing(List<dynamic> rawRing) {
    final points = rawRing
        .map((point) => point as List<dynamic>)
        .map(
          (point) => LatLng(
            (point[1] as num).toDouble(),
            (point[0] as num).toDouble(),
          ),
        )
        .toList(growable: false);

    if (points.length >= 2 &&
        points.first.latitude == points.last.latitude &&
        points.first.longitude == points.last.longitude) {
      return points.sublist(0, points.length - 1);
    }

    return points;
  }
}
