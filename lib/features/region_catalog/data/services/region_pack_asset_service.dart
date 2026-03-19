import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../models/region_boundary.dart';

abstract class RegionPackAssetService {
  Future<Set<String>> loadAssetKeys();

  Future<Map<String, dynamic>> loadJson(String assetPath);

  Future<RegionBoundary> loadBoundary(String assetPath);
}

class BundleRegionPackAssetService implements RegionPackAssetService {
  BundleRegionPackAssetService({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;
  Set<String>? _assetKeysCache;
  final Map<String, Map<String, dynamic>> _jsonCache =
      <String, Map<String, dynamic>>{};
  final Map<String, RegionBoundary> _boundaryCache = <String, RegionBoundary>{};

  @override
  Future<Set<String>> loadAssetKeys() async {
    final cached = _assetKeysCache;
    if (cached != null) {
      return cached;
    }

    final rawManifest = await _assetBundle.loadString('AssetManifest.json');
    final decoded = jsonDecode(rawManifest) as Map<String, dynamic>;
    final assetKeys = decoded.keys
        .where((key) => key.startsWith('assets/region_packs/'))
        .toSet();
    _assetKeysCache = assetKeys;
    return assetKeys;
  }

  @override
  Future<Map<String, dynamic>> loadJson(String assetPath) async {
    final cached = _jsonCache[assetPath];
    if (cached != null) {
      return cached;
    }

    final rawJson = await _assetBundle.loadString(assetPath);
    final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    _jsonCache[assetPath] = decoded;
    return decoded;
  }

  @override
  Future<RegionBoundary> loadBoundary(String assetPath) async {
    final cached = _boundaryCache[assetPath];
    if (cached != null) {
      return cached;
    }

    final geoJson = await loadJson(assetPath);
    final boundary = _parseBoundary(geoJson);
    _boundaryCache[assetPath] = boundary;
    return boundary;
  }

  RegionBoundary _parseBoundary(Map<String, dynamic> geoJson) {
    final geometry = _extractGeometry(geoJson);
    if (geometry == null) {
      return RegionBoundary.empty;
    }

    final type = geometry['type'] as String?;
    final coordinates = geometry['coordinates'];
    if (type == null || coordinates == null) {
      return RegionBoundary.empty;
    }

    switch (type) {
      case 'Polygon':
        return RegionBoundary(polygons: [_parsePolygon(coordinates as List)]);
      case 'MultiPolygon':
        return RegionBoundary(
          polygons: (coordinates as List)
              .map((polygon) => _parsePolygon(polygon as List))
              .where((polygon) => polygon.outerRing.isNotEmpty)
              .toList(growable: false),
        );
      default:
        return RegionBoundary.empty;
    }
  }

  Map<String, dynamic>? _extractGeometry(Map<String, dynamic> geoJson) {
    final type = geoJson['type'];
    if (type == 'FeatureCollection') {
      final features = geoJson['features'] as List<dynamic>? ?? const [];
      if (features.isEmpty) {
        return null;
      }
      return Map<String, dynamic>.from(
            features.first as Map<dynamic, dynamic>,
          )['geometry']
          as Map<String, dynamic>?;
    }
    if (type == 'Feature') {
      return Map<String, dynamic>.from(geoJson)['geometry']
          as Map<String, dynamic>?;
    }
    return geoJson;
  }

  RegionBoundaryPolygon _parsePolygon(List<dynamic> rawPolygon) {
    if (rawPolygon.isEmpty) {
      return const RegionBoundaryPolygon(outerRing: <LatLng>[]);
    }

    final rings = rawPolygon
        .map((ring) => _parseRing(ring as List<dynamic>))
        .where((ring) => ring.isNotEmpty)
        .toList(growable: false);
    if (rings.isEmpty) {
      return const RegionBoundaryPolygon(outerRing: <LatLng>[]);
    }

    return RegionBoundaryPolygon(
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
