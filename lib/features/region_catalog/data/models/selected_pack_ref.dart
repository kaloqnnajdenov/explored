import 'region_pack_kind.dart';

class SelectedPackAncestorRef {
  const SelectedPackAncestorRef({
    required this.id,
    required this.kind,
    required this.name,
    required this.geometryAssetPath,
  });

  final String id;
  final RegionPackKind kind;
  final String name;
  final String geometryAssetPath;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'kind': kind.rawValue,
      'name': name,
      'geometryAssetPath': geometryAssetPath,
    };
  }

  factory SelectedPackAncestorRef.fromJson(Map<String, dynamic> json) {
    return SelectedPackAncestorRef(
      id: json['id'] as String,
      kind: RegionPackKind.fromRaw(json['kind'] as String),
      name: json['name'] as String,
      geometryAssetPath: json['geometryAssetPath'] as String,
    );
  }
}

class SelectedPackRef {
  const SelectedPackRef({
    required this.id,
    required this.kind,
    required this.name,
    required this.geometryAssetPath,
    required this.ancestors,
  });

  final String id;
  final RegionPackKind kind;
  final String name;
  final String geometryAssetPath;
  final List<SelectedPackAncestorRef> ancestors;

  List<SelectedPackAncestorRef> get lineage => [
    ...ancestors,
    SelectedPackAncestorRef(
      id: id,
      kind: kind,
      name: name,
      geometryAssetPath: geometryAssetPath,
    ),
  ];

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'kind': kind.rawValue,
      'name': name,
      'geometryAssetPath': geometryAssetPath,
      'ancestors': ancestors.map((ancestor) => ancestor.toJson()).toList(),
    };
  }

  factory SelectedPackRef.fromJson(Map<String, dynamic> json) {
    return SelectedPackRef(
      id: json['id'] as String,
      kind: RegionPackKind.fromRaw(json['kind'] as String),
      name: json['name'] as String,
      geometryAssetPath: json['geometryAssetPath'] as String,
      ancestors: (json['ancestors'] as List<dynamic>? ?? const <dynamic>[])
          .map(
            (entry) => SelectedPackAncestorRef.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ),
          )
          .toList(growable: false),
    );
  }
}
