import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../../../../domain/shared/geo_bounds.dart';
import '../models/country_pack_descriptor.dart';
import 'entity_pack_parser.dart';

abstract class BundledPackAssetService {
  Future<List<CountryPackDescriptor>> listCountryPacks();

  Future<String> loadEntitiesPack(String countrySlug);

  Future<List<String>> listObjectPackFiles(String countrySlug);

  Future<String> loadObjectPack(String countrySlug, String fileName);

  Future<Map<String, String>> loadObjectPacks(String countrySlug);

  Future<String> loadTotalsPack(String countrySlug);
}

class _BundledPackLayout {
  const _BundledPackLayout({
    required this.countrySlug,
    required this.regionsRoot,
    this.objectsRoot,
    this.statsRoot,
  });

  final String countrySlug;
  final String regionsRoot;
  final String? objectsRoot;
  final String? statsRoot;

  _BundledPackLayout copyWith({
    String? regionsRoot,
    String? objectsRoot,
    String? statsRoot,
  }) {
    return _BundledPackLayout(
      countrySlug: countrySlug,
      regionsRoot: regionsRoot ?? this.regionsRoot,
      objectsRoot: objectsRoot ?? this.objectsRoot,
      statsRoot: statsRoot ?? this.statsRoot,
    );
  }
}

class BundleBundledPackAssetService implements BundledPackAssetService {
  BundleBundledPackAssetService({
    AssetBundle? assetBundle,
    EntityPackParser? entityPackParser,
  }) : _assetBundle = assetBundle ?? rootBundle,
       _entityPackParser = entityPackParser ?? const EntityPackParser();

  static const List<String> rootCandidates = <String>[
    'assets/region_packs',
    'assets/entity_packs',
  ];

  final AssetBundle _assetBundle;
  final EntityPackParser _entityPackParser;
  Set<String>? _assetKeysCache;
  List<CountryPackDescriptor>? _descriptorsCache;
  Map<String, _BundledPackLayout>? _layoutsByCountrySlugCache;

  @override
  Future<List<CountryPackDescriptor>> listCountryPacks() async {
    final cached = _descriptorsCache;
    if (cached != null) {
      return cached;
    }

    final descriptors = <CountryPackDescriptor>[];
    final layoutsByCountrySlug = await _layoutsByCountrySlug();
    for (final entry in layoutsByCountrySlug.entries) {
      descriptors.add(
        await _loadCountryDescriptor(
          countrySlug: entry.key,
          layout: entry.value,
        ),
      );
    }
    descriptors.sort(
      (left, right) => left.countryName.toLowerCase().compareTo(
        right.countryName.toLowerCase(),
      ),
    );
    _descriptorsCache = descriptors;
    return descriptors;
  }

  @override
  Future<String> loadEntitiesPack(String countrySlug) async {
    final layout = await _layoutForCountry(countrySlug);
    return _assetBundle.loadString(
      '${layout.regionsRoot}/$countrySlug/entities.ndjson',
    );
  }

  @override
  Future<Map<String, String>> loadObjectPacks(String countrySlug) async {
    final packs = <String, String>{};
    for (final fileName in await listObjectPackFiles(countrySlug)) {
      packs[fileName] = await loadObjectPack(countrySlug, fileName);
    }
    return packs;
  }

  @override
  Future<List<String>> listObjectPackFiles(String countrySlug) async {
    final layout = await _layoutForCountry(countrySlug);
    final objectsRoot = layout.objectsRoot;
    if (objectsRoot == null) {
      return const <String>[];
    }
    final prefix = '$objectsRoot/$countrySlug/';
    final fileNames = <String>[];
    for (final assetKey in await _assetKeys()) {
      if (!assetKey.startsWith(prefix) || !assetKey.endsWith('.ndjson')) {
        continue;
      }
      fileNames.add(assetKey.substring(prefix.length));
    }
    fileNames.sort();
    return fileNames;
  }

  @override
  Future<String> loadObjectPack(String countrySlug, String fileName) async {
    final layout = await _layoutForCountry(countrySlug);
    final objectsRoot = layout.objectsRoot;
    if (objectsRoot == null) {
      throw StateError('Country pack $countrySlug has no object packs');
    }
    return _assetBundle.loadString('$objectsRoot/$countrySlug/$fileName');
  }

  @override
  Future<String> loadTotalsPack(String countrySlug) async {
    final layout = await _layoutForCountry(countrySlug);
    final statsRoot = layout.statsRoot;
    if (statsRoot == null) {
      return '';
    }
    final assetPath = '$statsRoot/$countrySlug/entity_object_totals.ndjson';
    if (!(await _assetKeys()).contains(assetPath)) {
      return '';
    }
    return _assetBundle.loadString(assetPath);
  }

  Future<Set<String>> _assetKeys() async {
    final cached = _assetKeysCache;
    if (cached != null) {
      return cached;
    }
    final rawManifest = await _assetBundle.loadString('AssetManifest.json');
    final decoded = Map<String, dynamic>.from(
      // AssetManifest.json keys are all the asset paths we need.
      jsonDecode(rawManifest) as Map<dynamic, dynamic>,
    );
    final keys = decoded.keys.toSet();
    _assetKeysCache = keys;
    return keys;
  }

  Future<Map<String, _BundledPackLayout>> _layoutsByCountrySlug() async {
    final cached = _layoutsByCountrySlugCache;
    if (cached != null) {
      return cached;
    }

    final layouts = <String, _BundledPackLayout>{};
    final assetKeys = await _assetKeys();
    for (final root in rootCandidates) {
      final prefix = '$root/regions/';
      for (final assetKey in assetKeys) {
        if (!assetKey.startsWith(prefix) ||
            !assetKey.endsWith('/entities.ndjson')) {
          continue;
        }
        final relative = assetKey.substring(prefix.length);
        final parts = relative.split('/');
        if (parts.length != 2) {
          continue;
        }
        final countrySlug = parts.first;
        layouts.putIfAbsent(
          countrySlug,
          () => _BundledPackLayout(
            countrySlug: countrySlug,
            regionsRoot: '$root/regions',
          ),
        );
      }
    }

    for (final entry in layouts.entries.toList(growable: false)) {
      final countrySlug = entry.key;
      var layout = entry.value;
      for (final root in rootCandidates) {
        final objectsPrefix = '$root/objects/$countrySlug/';
        final hasObjects = assetKeys.any(
          (assetKey) =>
              assetKey.startsWith(objectsPrefix) &&
              assetKey.endsWith('.ndjson'),
        );
        if (hasObjects) {
          layout = layout.copyWith(objectsRoot: '$root/objects');
          break;
        }
      }

      for (final root in rootCandidates) {
        final totalsPath =
            '$root/stats/$countrySlug/entity_object_totals.ndjson';
        if (assetKeys.contains(totalsPath)) {
          layout = layout.copyWith(statsRoot: '$root/stats');
          break;
        }
      }

      layouts[countrySlug] = layout;
    }
    _layoutsByCountrySlugCache = layouts;
    return layouts;
  }

  Future<_BundledPackLayout> _layoutForCountry(String countrySlug) async {
    final layout = (await _layoutsByCountrySlug())[countrySlug];
    if (layout == null) {
      throw StateError('Unknown bundled country pack: $countrySlug');
    }
    return layout;
  }

  Future<CountryPackDescriptor> _loadCountryDescriptor({
    required String countrySlug,
    required _BundledPackLayout layout,
  }) async {
    final assetKeys = await _assetKeys();
    final manifestPath = '${layout.regionsRoot}/$countrySlug/manifest.json';
    if (assetKeys.contains(manifestPath)) {
      final rawManifest = await _assetBundle.loadString(manifestPath);
      final manifest = Map<String, dynamic>.from(
        jsonDecode(rawManifest) as Map<dynamic, dynamic>,
      );
      final country = manifest['country'];
      if (country is Map) {
        final countryData = Map<String, dynamic>.from(country);
        final entityId = countryData['entity_id'] as String?;
        final name = countryData['name'] as String?;
        if (entityId != null && name != null) {
          return CountryPackDescriptor(
            countrySlug: countrySlug,
            countryEntityId: entityId,
            countryName: name,
            packVersion: countryData['pack_version'] as String?,
            bbox: _parseBounds(countryData['bbox']),
            centroid: _parseLatLng(countryData['centroid']),
          );
        }
      }
    }

    final raw = await loadEntitiesPack(countrySlug);
    final entities = _entityPackParser.parse(raw, countrySlug: countrySlug);
    final country = entities.firstWhere((entity) => entity.countryId == null);
    return CountryPackDescriptor(
      countrySlug: countrySlug,
      countryEntityId: country.entityId,
      countryName: country.name,
      packVersion: country.packVersion,
      bbox: country.bbox,
      centroid: country.centroid,
    );
  }

  GeoBounds? _parseBounds(dynamic rawBounds) {
    if (rawBounds is! List || rawBounds.length < 4) {
      return null;
    }
    return GeoBounds.fromList(rawBounds);
  }

  LatLng? _parseLatLng(dynamic rawCentroid) {
    if (rawCentroid is! List || rawCentroid.length < 2) {
      return null;
    }
    return LatLng(
      (rawCentroid[1] as num).toDouble(),
      (rawCentroid[0] as num).toDouble(),
    );
  }
}
