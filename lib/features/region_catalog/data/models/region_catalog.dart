import 'region_pack_kind.dart';
import 'region_pack_node.dart';

class RegionCatalog {
  const RegionCatalog({required this.nodesById, required this.rootIds});

  static const RegionCatalog empty = RegionCatalog(
    nodesById: <String, RegionPackNode>{},
    rootIds: <String>[],
  );

  final Map<String, RegionPackNode> nodesById;
  final List<String> rootIds;

  List<RegionPackNode> get allNodes => nodesById.values.toList(growable: false);

  bool contains(String id) => nodesById.containsKey(id);

  RegionPackNode? maybeNodeById(String id) => nodesById[id];

  RegionPackNode nodeById(String id) {
    final node = maybeNodeById(id);
    if (node == null) {
      throw StateError('Unknown region pack node: $id');
    }
    return node;
  }

  List<RegionPackNode> get rootNodes =>
      rootIds.map(nodeById).toList(growable: false);

  List<RegionPackNode> childrenOf(String? parentId) {
    if (parentId == null) {
      return rootNodes;
    }
    return nodeById(parentId).childIds.map(nodeById).toList(growable: false);
  }

  List<RegionPackNode> ancestorsOf(String id) {
    final ancestors = <RegionPackNode>[];
    var current = maybeNodeById(id);
    while (current?.parentId != null) {
      current = maybeNodeById(current!.parentId!);
      if (current != null) {
        ancestors.add(current);
      }
    }
    return ancestors.reversed.toList(growable: false);
  }

  RegionPackNode? countryAncestorOf(String id) {
    final node = maybeNodeById(id);
    if (node == null) {
      return null;
    }
    if (node.kind == RegionPackKind.country) {
      return node;
    }
    return ancestorsOf(id).where((ancestor) {
      return ancestor.kind == RegionPackKind.country;
    }).lastOrNull;
  }

  RegionPackNode? regionAncestorOf(String id) {
    final node = maybeNodeById(id);
    if (node == null) {
      return null;
    }
    if (node.kind == RegionPackKind.region) {
      return node;
    }
    return ancestorsOf(id).where((ancestor) {
      return ancestor.kind == RegionPackKind.region;
    }).lastOrNull;
  }

  RegionCatalog copyWithDownloadedIds(Set<String> downloadedIds) {
    return RegionCatalog(
      rootIds: rootIds,
      nodesById: {
        for (final entry in nodesById.entries)
          entry.key: entry.value.copyWith(
            isDownloaded: downloadedIds.contains(entry.key),
          ),
      },
    );
  }

  RegionCatalog mergeNodes(Iterable<RegionPackNode> nodes) {
    final nextNodesById = <String, RegionPackNode>{...nodesById};
    var nextRootIds = List<String>.from(rootIds);

    for (final node in nodes) {
      final existing = nextNodesById[node.id];
      nextNodesById[node.id] = existing == null
          ? node
          : existing.copyWith(
              kind: node.kind,
              name: node.name,
              parentId: node.parentId,
              hasChildren: existing.hasChildren || node.hasChildren,
              childIds: _mergeChildIds(existing.childIds, node.childIds),
              center: node.center,
              bounds: node.bounds,
              areaKm2: node.areaKm2,
              isDownloaded: node.isDownloaded,
              geometryAssetPath: node.geometryAssetPath,
              displayPath: node.displayPath,
              features: node.features,
            );

      final rootParentMissing =
          node.parentId == null || !nextNodesById.containsKey(node.parentId);
      if (rootParentMissing && !nextRootIds.contains(node.id)) {
        nextRootIds.add(node.id);
      }
      if (!rootParentMissing) {
        nextRootIds.remove(node.id);
      }
    }

    return RegionCatalog(rootIds: nextRootIds, nodesById: nextNodesById);
  }

  static List<String> _mergeChildIds(
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
}
