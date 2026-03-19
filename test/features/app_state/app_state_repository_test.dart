import 'dart:convert';

import 'package:explored/features/app_state/data/repositories/app_state_repository.dart';
import 'package:explored/features/app_state/data/services/app_state_prefs_service.dart';
import 'package:explored/features/region_catalog/data/models/region_boundary.dart';
import 'package:explored/features/region_catalog/data/models/region_pack_bounds.dart';
import 'package:explored/features/region_catalog/data/models/region_pack_kind.dart';
import 'package:explored/features/region_catalog/data/models/region_pack_node.dart';
import 'package:explored/features/region_catalog/data/models/selected_pack_ref.dart';
import 'package:explored/features/region_catalog/data/repositories/region_catalog_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeRegionCatalogRepository implements RegionCatalogRepository {
  const FakeRegionCatalogRepository();

  static const List<RegionPackNode> packs = [
    RegionPackNode(
      id: 'northern-alps',
      kind: RegionPackKind.region,
      name: 'Northern Alps',
      parentId: null,
      childIds: [],
      center: LatLng(47.3, 10.7),
      bounds: RegionPackBounds(
        west: 10.0,
        south: 46.9,
        east: 11.2,
        north: 47.7,
      ),
      areaKm2: 100,
      isDownloaded: false,
      geometryAssetPath: 'northern-alps',
      displayPath: 'Northern Alps',
    ),
    RegionPackNode(
      id: 'otztal-alps',
      kind: RegionPackKind.region,
      name: 'Otztal Alps',
      parentId: null,
      childIds: [],
      center: LatLng(46.8, 10.8),
      bounds: RegionPackBounds(
        west: 10.3,
        south: 46.4,
        east: 11.4,
        north: 47.2,
      ),
      areaKm2: 100,
      isDownloaded: false,
      geometryAssetPath: 'otztal-alps',
      displayPath: 'Otztal Alps',
    ),
  ];

  @override
  Future<List<RegionPackNode>> loadRootCountries() async {
    return packs;
  }

  @override
  Future<List<RegionPackNode>> loadChildren(String parentId) async {
    return const <RegionPackNode>[];
  }

  @override
  Future<List<RegionPackNode>> loadNodesForSelectionRef(
    SelectedPackRef ref,
  ) async {
    return packs.where((pack) => pack.id == ref.id).toList(growable: false);
  }

  @override
  Future<RegionBoundary> loadBoundary(String nodeId) async {
    return RegionBoundary(
      polygons: [
        const RegionBoundaryPolygon(
          outerRing: [LatLng(0, 0), LatLng(0, 1), LatLng(1, 1), LatLng(1, 0)],
        ),
      ],
    );
  }
}

void main() {
  test('createInitialState returns lightweight defaults', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = DefaultAppStateRepository(
      prefsService: AppStatePrefsService(preferences: preferences),
      regionCatalogRepository: const FakeRegionCatalogRepository(),
    );

    final snapshot = repository.createInitialState();

    expect(snapshot.hasSeenOnboarding, isFalse);
    expect(snapshot.regions, isEmpty);
    expect(snapshot.currentRegionId, isEmpty);
    expect(snapshot.userPoints, isEmpty);
    expect(snapshot.hasLoadedRootPacks, isFalse);
  });

  test('loadRootPacks returns seeded root nodes', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = DefaultAppStateRepository(
      prefsService: AppStatePrefsService(preferences: preferences),
      regionCatalogRepository: const FakeRegionCatalogRepository(),
    );

    final packs = await repository.loadRootPacks();

    expect(packs.length, 2);
    expect(packs.first.id, 'northern-alps');
  });

  test(
    'restoreSelectedPack applies persisted pack ref, downloads, and user points',
    () async {
      final points = [
        {
          'id': 'p1',
          'latitude': 47.1,
          'longitude': 11.2,
          'createdAt': DateTime.utc(2026, 1, 1).toIso8601String(),
        },
      ];

      SharedPreferences.setMockInitialValues({
        AppStatePrefsService.hasSeenOnboardingKey: true,
        AppStatePrefsService.selectedPackRefKey: jsonEncode(
          const SelectedPackRef(
            id: 'otztal-alps',
            kind: RegionPackKind.region,
            name: 'Otztal Alps',
            geometryAssetPath: 'otztal-alps',
            ancestors: <SelectedPackAncestorRef>[],
          ).toJson(),
        ),
        AppStatePrefsService.downloadedRegionIdsKey: ['otztal-alps'],
        AppStatePrefsService.userPointsKey: jsonEncode(points),
      });
      final preferences = await SharedPreferences.getInstance();
      final repository = DefaultAppStateRepository(
        prefsService: AppStatePrefsService(preferences: preferences),
        regionCatalogRepository: const FakeRegionCatalogRepository(),
      );

      final snapshot = repository.createInitialState();
      final restoredPacks = await repository.restoreSelectedPack();

      expect(snapshot.hasSeenOnboarding, isTrue);
      expect(snapshot.currentRegionId, 'otztal-alps');
      expect(restoredPacks.single.isDownloaded, isTrue);
      expect(snapshot.userPoints.length, 1);
      expect(snapshot.userPoints.first.id, 'p1');
    },
  );
}
