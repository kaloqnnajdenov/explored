import 'dart:convert';
import 'dart:io';

import 'package:explored/features/region_catalog/data/models/region_boundary.dart';
import 'package:explored/features/region_catalog/data/models/region_pack_kind.dart';
import 'package:explored/features/region_catalog/data/models/selected_pack_ref.dart';
import 'package:explored/features/region_catalog/data/repositories/region_catalog_repository.dart';
import 'package:explored/features/region_catalog/data/services/region_pack_asset_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

class FakeRegionPackAssetService implements RegionPackAssetService {
  FakeRegionPackAssetService({
    required this.assetKeys,
    required this.jsonByPath,
    required this.boundaryByPath,
  });

  final Set<String> assetKeys;
  final Map<String, Map<String, dynamic>> jsonByPath;
  final Map<String, RegionBoundary> boundaryByPath;
  final Map<String, int> boundaryLoads = <String, int>{};

  @override
  Future<Set<String>> loadAssetKeys() async => assetKeys;

  @override
  Future<Map<String, dynamic>> loadJson(String assetPath) async {
    return jsonByPath[assetPath]!;
  }

  @override
  Future<RegionBoundary> loadBoundary(String assetPath) async {
    boundaryLoads.update(assetPath, (value) => value + 1, ifAbsent: () => 1);
    return boundaryByPath[assetPath]!;
  }
}

class DirectoryRegionPackAssetService implements RegionPackAssetService {
  DirectoryRegionPackAssetService({
    this.regionPacksRoot = 'assets/region_packs',
  });

  final String regionPacksRoot;
  Set<String>? _assetKeys;

  @override
  Future<Set<String>> loadAssetKeys() async {
    final cached = _assetKeys;
    if (cached != null) {
      return cached;
    }

    final keys = Directory(regionPacksRoot)
        .listSync(recursive: true)
        .whereType<File>()
        .map((file) => file.path.replaceAll('\\', '/'))
        .toSet();
    _assetKeys = keys;
    return keys;
  }

  @override
  Future<Map<String, dynamic>> loadJson(String assetPath) async {
    final raw = await File(assetPath).readAsString();
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  @override
  Future<RegionBoundary> loadBoundary(String assetPath) async {
    throw UnimplementedError('Boundary loading is not used in this test');
  }
}

void main() {
  test(
    'lazy loading builds hierarchy, ignores hidden folders, and adds city centers',
    () async {
      final service = FakeRegionPackAssetService(
        assetKeys: {
          'assets/region_packs/testland/manifest.json',
          'assets/region_packs/testland/country.geojson',
          'assets/region_packs/testland/regions/valid/metadata.json',
          'assets/region_packs/testland/regions/valid/region.geojson',
          'assets/region_packs/testland/regions/valid/cities/sample/metadata.json',
          'assets/region_packs/testland/regions/valid/cities/sample/city.geojson',
          'assets/region_packs/testland/regions/valid/cities/sample/city_center.geojson',
          'assets/region_packs/testland/regions/_unassigned/region.geojson',
          'assets/region_packs/testland/regions/fallback-region/region.geojson',
        },
        jsonByPath: {
          'assets/region_packs/testland/manifest.json': {
            'country': {
              'entity_id': 'country-1',
              'name': 'Testland',
              'bbox': [0, 0, 5, 5],
              'centroid': [2.5, 2.5],
            },
            'region_count': 2,
            'regions': [
              {'entity_id': 'region-1'},
              {'entity_id': 'region-2'},
            ],
          },
          'assets/region_packs/testland/regions/valid/metadata.json': {
            'entity_id': 'region-1',
            'name': 'Valid Region',
            'bbox': [1, 1, 4, 4],
            'centroid': [2.5, 2.5],
          },
          'assets/region_packs/testland/regions/valid/cities/sample/metadata.json':
              {
                'entity_id': 'city-1',
                'name': 'Sample City',
                'bbox': [2, 2, 3, 3],
                'centroid': [2.5, 2.5],
                'files': {'city_center': 'city_center.geojson'},
                'city_center_name': 'Old Town',
              },
          'assets/region_packs/testland/regions/valid/cities/sample/city_center.geojson':
              {
                'type': 'FeatureCollection',
                'features': [
                  {
                    'type': 'Feature',
                    'properties': {
                      'entity_id': 'center-1',
                      'name': 'Center Geometry Name',
                      'bbox': [2.1, 2.1, 2.2, 2.2],
                      'centroid': [2.15, 2.15],
                    },
                  },
                ],
              },
          'assets/region_packs/testland/regions/fallback-region/region.geojson':
              {
                'type': 'FeatureCollection',
                'features': [
                  {
                    'type': 'Feature',
                    'properties': {
                      'entity_id': 'region-2',
                      'name': 'Fallback Region',
                      'bbox': [4, 4, 5, 5],
                      'centroid': [4.5, 4.5],
                    },
                  },
                ],
              },
        },
        boundaryByPath: {
          'assets/region_packs/testland/country.geojson': RegionBoundary(
            polygons: [
              const RegionBoundaryPolygon(
                outerRing: [
                  LatLng(0, 0),
                  LatLng(0, 5),
                  LatLng(5, 5),
                  LatLng(5, 0),
                ],
              ),
            ],
          ),
          'assets/region_packs/testland/regions/valid/region.geojson':
              RegionBoundary(
                polygons: [
                  const RegionBoundaryPolygon(
                    outerRing: [
                      LatLng(1, 1),
                      LatLng(1, 4),
                      LatLng(4, 4),
                      LatLng(4, 1),
                    ],
                  ),
                ],
              ),
        },
      );
      final repository = DefaultRegionCatalogRepository(assetService: service);

      final rootCountries = await repository.loadRootCountries();
      final regions = await repository.loadChildren('country-1');
      final cities = await repository.loadChildren('region-1');
      final cityCenters = await repository.loadChildren('city-1');
      final restoredSelection = await repository.loadNodesForSelectionRef(
        const SelectedPackRef(
          id: 'center-1',
          kind: RegionPackKind.cityCenter,
          name: 'Old Town',
          geometryAssetPath:
              'assets/region_packs/testland/regions/valid/cities/sample/city_center.geojson',
          ancestors: <SelectedPackAncestorRef>[
            SelectedPackAncestorRef(
              id: 'country-1',
              kind: RegionPackKind.country,
              name: 'Testland',
              geometryAssetPath: 'assets/region_packs/testland/country.geojson',
            ),
            SelectedPackAncestorRef(
              id: 'region-1',
              kind: RegionPackKind.region,
              name: 'Valid Region',
              geometryAssetPath:
                  'assets/region_packs/testland/regions/valid/region.geojson',
            ),
            SelectedPackAncestorRef(
              id: 'city-1',
              kind: RegionPackKind.city,
              name: 'Sample City',
              geometryAssetPath:
                  'assets/region_packs/testland/regions/valid/cities/sample/city.geojson',
            ),
          ],
        ),
      );

      expect(rootCountries.single.name, 'Testland');
      expect(regions.map((node) => node.name).toList(), [
        'Fallback Region',
        'Valid Region',
      ]);
      expect(cities.single.id, 'city-1');
      expect(cityCenters.single.name, 'Old Town');
      expect(cityCenters.single.id, 'center-1');
      expect(
        restoredSelection.last.displayPath,
        'Testland / Valid Region / Sample City / Old Town',
      );
    },
  );

  test('loadBoundary caches boundaries by node id', () async {
    final service = FakeRegionPackAssetService(
      assetKeys: {
        'assets/region_packs/testland/manifest.json',
        'assets/region_packs/testland/country.geojson',
      },
      jsonByPath: {
        'assets/region_packs/testland/manifest.json': {
          'country': {
            'entity_id': 'country-1',
            'name': 'Testland',
            'bbox': [0, 0, 5, 5],
            'centroid': [2.5, 2.5],
          },
        },
      },
      boundaryByPath: {
        'assets/region_packs/testland/country.geojson': RegionBoundary(
          polygons: [
            const RegionBoundaryPolygon(
              outerRing: [
                LatLng(0, 0),
                LatLng(0, 5),
                LatLng(5, 5),
                LatLng(5, 0),
              ],
            ),
          ],
        ),
      },
    );
    final repository = DefaultRegionCatalogRepository(assetService: service);

    await repository.loadRootCountries();
    await repository.loadBoundary('country-1');
    await repository.loadBoundary('country-1');

    expect(
      service.boundaryLoads['assets/region_packs/testland/country.geojson'],
      1,
    );
  });

  test(
    'region metadata without bbox falls back to geojson properties',
    () async {
      final service = FakeRegionPackAssetService(
        assetKeys: {
          'assets/region_packs/testland/manifest.json',
          'assets/region_packs/testland/country.geojson',
          'assets/region_packs/testland/regions/bayern/metadata.json',
          'assets/region_packs/testland/regions/bayern/region.geojson',
        },
        jsonByPath: {
          'assets/region_packs/testland/manifest.json': {
            'country': {
              'entity_id': 'country-1',
              'name': 'Testland',
              'bbox': [0, 0, 5, 5],
              'centroid': [2.5, 2.5],
            },
            'region_count': 1,
          },
          'assets/region_packs/testland/regions/bayern/metadata.json': {
            'entity_id': 'region-1',
            'name': 'Bayern',
            'cities': const <String>[],
          },
          'assets/region_packs/testland/regions/bayern/region.geojson': {
            'type': 'FeatureCollection',
            'features': [
              {
                'type': 'Feature',
                'properties': {
                  'entity_id': 'region-1',
                  'name': 'Bayern',
                  'bbox': [1, 1, 4, 4],
                  'centroid': [2.5, 2.5],
                },
              },
            ],
          },
        },
        boundaryByPath: const <String, RegionBoundary>{},
      );
      final repository = DefaultRegionCatalogRepository(assetService: service);

      final countries = await repository.loadRootCountries();
      final regions = await repository.loadChildren(countries.single.id);

      expect(regions.single.id, 'region-1');
      expect(regions.single.name, 'Bayern');
      expect(regions.single.bounds.west, 1);
      expect(regions.single.hasChildren, isFalse);
    },
  );

  test(
    'real Deutschland pack enumerates region children from shipped assets',
    () async {
      final repository = DefaultRegionCatalogRepository(
        assetService: DirectoryRegionPackAssetService(),
      );

      final rootCountries = await repository.loadRootCountries();
      final germany = rootCountries.firstWhere(
        (node) => node.name == 'Deutschland',
      );
      final regions = await repository.loadChildren(germany.id);

      expect(regions, hasLength(16));
      expect(regions.any((node) => node.name == 'Bayern'), isTrue);
      expect(regions.any((node) => node.name == 'Berlin'), isTrue);
      expect(regions.any((node) => node.name == '_unassigned'), isFalse);
    },
  );
}
