import 'package:latlong2/latlong.dart';

import 'region_features.dart';
import 'region_pack_bounds.dart';
import 'region_pack_kind.dart';

class RegionPackNode {
  const RegionPackNode({
    required this.id,
    required this.kind,
    required this.name,
    this.hasChildren = false,
    required this.childIds,
    required this.center,
    required this.bounds,
    required this.isDownloaded,
    required this.geometryAssetPath,
    required this.displayPath,
    this.parentId,
    this.areaKm2,
    this.features = RegionFeatures.empty,
  });

  final String id;
  final RegionPackKind kind;
  final String name;
  final String? parentId;
  final bool hasChildren;
  final List<String> childIds;
  final LatLng center;
  final RegionPackBounds bounds;
  final double? areaKm2;
  final bool isDownloaded;
  final String geometryAssetPath;
  final String displayPath;
  final RegionFeatures features;

  RegionPackNode copyWith({
    String? id,
    RegionPackKind? kind,
    String? name,
    String? parentId,
    bool? hasChildren,
    List<String>? childIds,
    LatLng? center,
    RegionPackBounds? bounds,
    double? areaKm2,
    bool? isDownloaded,
    String? geometryAssetPath,
    String? displayPath,
    RegionFeatures? features,
  }) {
    return RegionPackNode(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      hasChildren: hasChildren ?? this.hasChildren,
      childIds: childIds ?? this.childIds,
      center: center ?? this.center,
      bounds: bounds ?? this.bounds,
      areaKm2: areaKm2 ?? this.areaKm2,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      geometryAssetPath: geometryAssetPath ?? this.geometryAssetPath,
      displayPath: displayPath ?? this.displayPath,
      features: features ?? this.features,
    );
  }
}
