import 'package:latlong2/latlong.dart';

import '../models/region_boundary.dart';
import '../models/region_pack_bounds.dart';
import '../models/region_pack_kind.dart';
import '../models/region_pack_node.dart';
import '../models/selected_pack_ref.dart';
import '../services/region_pack_asset_service.dart';

abstract class RegionCatalogRepository {
  Future<List<RegionPackNode>> loadRootCountries();

  Future<List<RegionPackNode>> loadChildren(String parentId);

  Future<List<RegionPackNode>> loadNodesForSelectionRef(SelectedPackRef ref);

  Future<RegionBoundary> loadBoundary(String nodeId);
}

class DefaultRegionCatalogRepository implements RegionCatalogRepository {
  DefaultRegionCatalogRepository({required RegionPackAssetService assetService})
    : _assetService = assetService;

  final RegionPackAssetService _assetService;
  final Map<String, RegionPackNode> _nodeCache = <String, RegionPackNode>{};
  final Map<String, RegionBoundary> _boundaryCache = <String, RegionBoundary>{};
  List<String>? _rootIdsCache;
  final Map<String, List<String>> _childIdsByParent = <String, List<String>>{};

  @override
  Future<List<RegionPackNode>> loadRootCountries() async {
    final cachedRootIds = _rootIdsCache;
    if (cachedRootIds != null) {
      return cachedRootIds
          .map((id) => _nodeCache[id])
          .whereType<RegionPackNode>()
          .toList(growable: false);
    }

    final assetKeys = await _assetService.loadAssetKeys();
    final rootNodes = <RegionPackNode>[
      for (final countryRoot in _countryRootsFromAssetKeys(assetKeys))
        _buildCountryNode(
          manifest: await _assetService.loadJson('$countryRoot/manifest.json'),
          geometryAssetPath: '$countryRoot/country.geojson',
        ),
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    _rootIdsCache = rootNodes.map((node) => node.id).toList(growable: false);
    for (final node in rootNodes) {
      _nodeCache[node.id] = _mergeNode(_nodeCache[node.id], node);
    }
    return rootNodes;
  }

  @override
  Future<List<RegionPackNode>> loadChildren(String parentId) async {
    final cachedChildIds = _childIdsByParent[parentId];
    if (cachedChildIds != null) {
      return cachedChildIds
          .map((id) => _nodeCache[id])
          .whereType<RegionPackNode>()
          .toList(growable: false);
    }

    final parent = _nodeCache[parentId];
    if (parent == null) {
      throw StateError('Cannot load children for unknown pack: $parentId');
    }

    final children = switch (parent.kind) {
      RegionPackKind.country => await _loadRegionChildren(parent),
      RegionPackKind.region => await _loadCityChildren(parent),
      RegionPackKind.city => await _loadCityCenterChildren(parent),
      RegionPackKind.cityCenter => const <RegionPackNode>[],
    };
    final sortedChildren = children.toList(growable: false)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final childIds = sortedChildren
        .map((child) => child.id)
        .toList(growable: false);

    for (final child in sortedChildren) {
      _nodeCache[child.id] = _mergeNode(_nodeCache[child.id], child);
    }
    _childIdsByParent[parentId] = childIds;
    _nodeCache[parentId] = _mergeNode(
      parent,
      parent.copyWith(childIds: childIds, hasChildren: childIds.isNotEmpty),
    );
    return sortedChildren;
  }

  @override
  Future<List<RegionPackNode>> loadNodesForSelectionRef(
    SelectedPackRef ref,
  ) async {
    final assetKeys = await _assetService.loadAssetKeys();
    final lineage = ref.lineage;
    final loadedNodes = <RegionPackNode>[];

    for (var index = 0; index < lineage.length; index++) {
      final entry = lineage[index];
      if (!assetKeys.contains(entry.geometryAssetPath)) {
        throw StateError('Missing asset for selected pack: ${entry.id}');
      }

      final parentId = index == 0 ? null : lineage[index - 1].id;
      final nextChildId = index + 1 < lineage.length
          ? lineage[index + 1].id
          : null;
      final rawData = await _loadNodeDataForRef(entry, assetKeys);
      final node = _buildNode(
        rawData: rawData,
        kind: entry.kind,
        geometryAssetPath: entry.geometryAssetPath,
        parentId: parentId,
        overrideName: entry.name,
        displayPathSegments: [
          for (final segment in lineage.take(index)) segment.name,
        ],
        hasChildrenOverride:
            nextChildId != null || _rawDataHasChildren(entry.kind, rawData),
        childIds: nextChildId == null
            ? const <String>[]
            : <String>[nextChildId],
      );
      _nodeCache[node.id] = _mergeNode(_nodeCache[node.id], node);
      if (parentId != null) {
        _nodeCache[parentId] = _mergeNode(
          _nodeCache[parentId],
          _nodeCache[parentId]!.copyWith(
            childIds: _mergeChildIds(_nodeCache[parentId]!.childIds, <String>[
              node.id,
            ]),
            hasChildren: true,
          ),
        );
      }
      loadedNodes.add(_nodeCache[node.id]!);
    }

    return loadedNodes;
  }

  @override
  Future<RegionBoundary> loadBoundary(String nodeId) async {
    final cached = _boundaryCache[nodeId];
    if (cached != null) {
      return cached;
    }

    final node = _nodeCache[nodeId];
    if (node == null) {
      throw StateError('Unknown region pack node: $nodeId');
    }
    final boundary = await _assetService.loadBoundary(node.geometryAssetPath);
    _boundaryCache[nodeId] = boundary;
    return boundary;
  }

  Future<List<RegionPackNode>> _loadRegionChildren(
    RegionPackNode country,
  ) async {
    final assetKeys = await _assetService.loadAssetKeys();
    final countryRoot = _directoryOf(country.geometryAssetPath);
    final regionRoots = _childRoots(
      assetKeys,
      '$countryRoot/regions',
      'region.geojson',
    );
    return [
      for (final regionRoot in regionRoots)
        if (!_isHiddenDirectory(_lastPathSegment(regionRoot)))
          _buildNode(
            rawData: await _loadNodeData(
              assetKeys: assetKeys,
              metadataAssetPath: '$regionRoot/metadata.json',
              geoJsonAssetPath: '$regionRoot/region.geojson',
            ),
            kind: RegionPackKind.region,
            geometryAssetPath: '$regionRoot/region.geojson',
            parentId: country.id,
            displayPathSegments: [country.name],
          ),
    ];
  }

  Future<List<RegionPackNode>> _loadCityChildren(RegionPackNode region) async {
    final assetKeys = await _assetService.loadAssetKeys();
    final regionRoot = _directoryOf(region.geometryAssetPath);
    final cityRoots = _childRoots(
      assetKeys,
      '$regionRoot/cities',
      'city.geojson',
    );
    return [
      for (final cityRoot in cityRoots)
        if (!_isHiddenDirectory(_lastPathSegment(cityRoot)))
          _buildNode(
            rawData: await _loadNodeData(
              assetKeys: assetKeys,
              metadataAssetPath: '$cityRoot/metadata.json',
              geoJsonAssetPath: '$cityRoot/city.geojson',
            ),
            kind: RegionPackKind.city,
            geometryAssetPath: '$cityRoot/city.geojson',
            parentId: region.id,
            displayPathSegments: [region.displayPath],
          ),
    ];
  }

  Future<List<RegionPackNode>> _loadCityCenterChildren(
    RegionPackNode city,
  ) async {
    final assetKeys = await _assetService.loadAssetKeys();
    final cityRoot = _directoryOf(city.geometryAssetPath);
    final cityData = await _loadNodeData(
      assetKeys: assetKeys,
      metadataAssetPath: '$cityRoot/metadata.json',
      geoJsonAssetPath: city.geometryAssetPath,
    );
    final files = _asMap(cityData['files']);
    final cityCenterFile = files['city_center'] as String?;
    if (cityCenterFile == null) {
      return const <RegionPackNode>[];
    }

    final geometryAssetPath = '$cityRoot/$cityCenterFile';
    if (!assetKeys.contains(geometryAssetPath)) {
      return const <RegionPackNode>[];
    }

    return [
      _buildNode(
        rawData: await _loadNodeData(
          assetKeys: assetKeys,
          metadataAssetPath: null,
          geoJsonAssetPath: geometryAssetPath,
        ),
        kind: RegionPackKind.cityCenter,
        geometryAssetPath: geometryAssetPath,
        parentId: city.id,
        overrideName: cityData['city_center_name'] as String?,
        displayPathSegments: [city.displayPath],
      ),
    ];
  }

  RegionPackNode _buildCountryNode({
    required Map<String, dynamic> manifest,
    required String geometryAssetPath,
  }) {
    final countryData = Map<String, dynamic>.from(
      manifest['country'] as Map<dynamic, dynamic>,
    );
    final regionCount = manifest['region_count'] as num? ?? 0;
    return _buildNode(
      rawData: countryData,
      kind: RegionPackKind.country,
      geometryAssetPath: geometryAssetPath,
      parentId: null,
      displayPathSegments: const <String>[],
      hasChildrenOverride: regionCount > 0,
    );
  }

  Future<Map<String, dynamic>> _loadNodeDataForRef(
    SelectedPackAncestorRef ref,
    Set<String> assetKeys,
  ) async {
    return switch (ref.kind) {
      RegionPackKind.country => _loadCountryData(ref.geometryAssetPath),
      RegionPackKind.region || RegionPackKind.city => _loadNodeData(
        assetKeys: assetKeys,
        metadataAssetPath:
            '${_directoryOf(ref.geometryAssetPath)}/metadata.json',
        geoJsonAssetPath: ref.geometryAssetPath,
      ),
      RegionPackKind.cityCenter => _loadNodeData(
        assetKeys: assetKeys,
        metadataAssetPath: null,
        geoJsonAssetPath: ref.geometryAssetPath,
      ),
    };
  }

  Future<Map<String, dynamic>> _loadCountryData(
    String geometryAssetPath,
  ) async {
    final countryRoot = _directoryOf(geometryAssetPath);
    final manifest = await _assetService.loadJson('$countryRoot/manifest.json');
    return {
      ...Map<String, dynamic>.from(
        manifest['country'] as Map<dynamic, dynamic>,
      ),
      'region_count': manifest['region_count'],
      'regions': manifest['regions'],
    };
  }

  Future<Map<String, dynamic>> _loadNodeData({
    required Set<String> assetKeys,
    required String? metadataAssetPath,
    required String geoJsonAssetPath,
  }) async {
    if (metadataAssetPath != null && assetKeys.contains(metadataAssetPath)) {
      final metadata = await _assetService.loadJson(metadataAssetPath);
      if (_hasUsableNodeGeometry(metadata)) {
        return metadata;
      }

      final geoJsonProperties = await _loadGeoJsonProperties(geoJsonAssetPath);
      return <String, dynamic>{...geoJsonProperties, ...metadata};
    }

    return _loadGeoJsonProperties(geoJsonAssetPath);
  }

  Future<Map<String, dynamic>> _loadGeoJsonProperties(
    String geoJsonAssetPath,
  ) async {
    final geoJson = await _assetService.loadJson(geoJsonAssetPath);
    final featureCollectionFeatures =
        geoJson['features'] as List<dynamic>? ?? const <dynamic>[];
    if (featureCollectionFeatures.isEmpty) {
      return const <String, dynamic>{};
    }
    final firstFeature = Map<String, dynamic>.from(
      featureCollectionFeatures.first as Map<dynamic, dynamic>,
    );
    return Map<String, dynamic>.from(
      firstFeature['properties'] as Map<dynamic, dynamic>,
    );
  }

  bool _hasUsableNodeGeometry(Map<String, dynamic> rawData) {
    final bbox = rawData['bbox'];
    return bbox is List<dynamic> && bbox.isNotEmpty;
  }

  RegionPackNode _buildNode({
    required Map<String, dynamic> rawData,
    required RegionPackKind kind,
    required String geometryAssetPath,
    required String? parentId,
    required List<String> displayPathSegments,
    String? overrideName,
    bool? hasChildrenOverride,
    List<String> childIds = const <String>[],
  }) {
    final name = overrideName ?? rawData['name'] as String? ?? '';
    final bbox = RegionPackBounds.fromList(rawData['bbox'] as List<dynamic>);
    final centroid = rawData['centroid'] as List<dynamic>?;
    return RegionPackNode(
      id: rawData['entity_id'] as String,
      kind: kind,
      name: name,
      parentId: parentId,
      hasChildren: hasChildrenOverride ?? _rawDataHasChildren(kind, rawData),
      childIds: childIds,
      center: centroid == null
          ? bbox.center
          : LatLng(
              (centroid[1] as num).toDouble(),
              (centroid[0] as num).toDouble(),
            ),
      bounds: bbox,
      areaKm2: null,
      isDownloaded: false,
      geometryAssetPath: geometryAssetPath,
      displayPath: [...displayPathSegments, name].join(' / '),
    );
  }

  bool _rawDataHasChildren(RegionPackKind kind, Map<String, dynamic> rawData) {
    return switch (kind) {
      RegionPackKind.country =>
        (rawData['region_count'] as num? ?? 0) > 0 ||
            (rawData['regions'] as List<dynamic>? ?? const <dynamic>[])
                .isNotEmpty,
      RegionPackKind.region =>
        (rawData['cities'] as List<dynamic>? ?? const <dynamic>[]).isNotEmpty,
      RegionPackKind.city => _asMap(
        rawData['files'],
      ).containsKey('city_center'),
      RegionPackKind.cityCenter => false,
    };
  }

  List<String> _countryRootsFromAssetKeys(Set<String> assetKeys) {
    return assetKeys
        .where((key) => key.endsWith('/manifest.json'))
        .map(_legacyOrLayeredCountryRootForManifest)
        .whereType<String>()
        .toList(growable: false)
      ..sort();
  }

  String? _legacyOrLayeredCountryRootForManifest(String assetPath) {
    final parts = assetPath.split('/');
    if (parts.length == 4) {
      return assetPath.substring(0, assetPath.length - '/manifest.json'.length);
    }
    if (parts.length == 5 &&
        parts[0] == 'assets' &&
        parts[1] == 'region_packs' &&
        parts[2] == 'regions') {
      return assetPath.substring(0, assetPath.length - '/manifest.json'.length);
    }
    return null;
  }

  List<String> _childRoots(
    Set<String> assetKeys,
    String parentRoot,
    String expectedFileName,
  ) {
    final prefix = '$parentRoot/';
    final roots = <String>{};
    for (final key in assetKeys) {
      if (!key.startsWith(prefix) || !key.endsWith('/$expectedFileName')) {
        continue;
      }
      final relativePath = key.substring(prefix.length);
      final parts = relativePath.split('/');
      if (parts.length < 2) {
        continue;
      }
      roots.add('$parentRoot/${parts.first}');
    }
    return roots.toList(growable: false)..sort();
  }

  RegionPackNode _mergeNode(RegionPackNode? existing, RegionPackNode incoming) {
    if (existing == null) {
      return incoming;
    }

    return existing.copyWith(
      kind: incoming.kind,
      name: incoming.name,
      parentId: incoming.parentId,
      hasChildren: existing.hasChildren || incoming.hasChildren,
      childIds: _mergeChildIds(existing.childIds, incoming.childIds),
      center: incoming.center,
      bounds: incoming.bounds,
      areaKm2: incoming.areaKm2,
      isDownloaded: existing.isDownloaded || incoming.isDownloaded,
      geometryAssetPath: incoming.geometryAssetPath,
      displayPath: incoming.displayPath,
      features: incoming.features,
    );
  }

  List<String> _mergeChildIds(
    List<String> existingChildIds,
    List<String> incomingChildIds,
  ) {
    if (incomingChildIds.isEmpty) {
      return existingChildIds;
    }
    return <String>[
      ...incomingChildIds,
      for (final childId in existingChildIds)
        if (!incomingChildIds.contains(childId)) childId,
    ];
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const <String, dynamic>{};
  }

  bool _isHiddenDirectory(String name) => name.startsWith('_');

  String _directoryOf(String assetPath) {
    final lastSlashIndex = assetPath.lastIndexOf('/');
    return assetPath.substring(0, lastSlashIndex);
  }

  String _lastPathSegment(String path) {
    return path.substring(path.lastIndexOf('/') + 1);
  }
}
