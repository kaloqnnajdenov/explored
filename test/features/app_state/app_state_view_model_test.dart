import 'package:explored/features/app_state/data/models/app_permission.dart';
import 'package:explored/features/app_state/data/models/app_state_snapshot.dart';
import 'package:explored/features/app_state/data/models/gps_quality.dart';
import 'package:explored/features/app_state/data/models/region.dart';
import 'package:explored/features/app_state/data/models/user_point.dart';
import 'package:explored/features/app_state/data/repositories/app_state_repository.dart';
import 'package:explored/features/app_state/view_model/app_state_view_model.dart';
import 'package:explored/features/region_catalog/data/models/region_boundary.dart';
import 'package:explored/features/region_catalog/data/models/region_catalog.dart';
import 'package:explored/features/region_catalog/data/models/region_pack_bounds.dart';
import 'package:explored/features/region_catalog/data/models/region_pack_kind.dart';
import 'package:explored/features/region_catalog/data/models/region_pack_node.dart';
import 'package:explored/features/region_catalog/data/models/selected_pack_ref.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import '../../test_utils/map_test_doubles.dart';

class FakeAppStateRepository implements AppStateRepository {
  bool hasSeenOnboarding = false;
  Map<TrackingPermissionType, PermissionGrantState> permissions = {
    for (final permission in TrackingPermissionType.values)
      permission: PermissionGrantState.prompt,
  };
  String currentRegionId = 'r1';
  List<SelectedPackRef> downloadedRefs = const <SelectedPackRef>[];
  List<UserPoint> userPoints = const <UserPoint>[];

  @override
  AppStateSnapshot createInitialState() {
    return _seedSnapshot();
  }

  @override
  Future<List<RegionPackNode>> loadRootPacks() async {
    return _seedSnapshot().regionCatalog.rootNodes;
  }

  @override
  Future<List<RegionPackNode>> restoreSelectedPack() async {
    return _seedSnapshot().regionCatalog.rootNodes;
  }

  @override
  Future<List<RegionPackNode>> loadChildren(String parentId) async {
    return const <RegionPackNode>[];
  }

  @override
  Future<List<RegionPackNode>> loadDownloadedPacks() async {
    return _seedSnapshot().regions
        .where((region) => region.isDownloaded)
        .toList();
  }

  @override
  Future<void> setSelectedPack(SelectedPackRef ref) async {
    currentRegionId = ref.id;
  }

  @override
  Future<void> setDownloadedPacks(List<SelectedPackRef> refs) async {
    downloadedRefs = refs;
  }

  @override
  Future<void> setHasSeenOnboarding(bool value) async {
    hasSeenOnboarding = value;
  }

  @override
  Future<void> setPermissions(
    Map<TrackingPermissionType, PermissionGrantState> permissions,
  ) async {
    this.permissions = permissions;
  }

  @override
  Future<void> setUserPoints(List<UserPoint> points) async {
    userPoints = points;
  }

  AppStateSnapshot _seedSnapshot() {
    return buildAppStateSnapshot(
      regions: const [
        Region(
          id: 'r1',
          name: 'Region 1',
          totalArea: 10,
          exploredArea: 0,
          isDownloaded: false,
          center: LatLng(0, 0),
          bounds: [LatLng(0, 0), LatLng(0, 1), LatLng(1, 1), LatLng(1, 0)],
          features: RegionFeatures(
            trails: RegionFeatureProgress(total: 1, completed: 0),
            peaks: RegionFeatureProgress(total: 1, completed: 0),
            huts: RegionFeatureProgress(total: 1, completed: 0),
          ),
        ),
      ],
      currentRegionId: currentRegionId,
    ).copyWith(
      hasSeenOnboarding: hasSeenOnboarding,
      permissions: permissions,
      userPoints: userPoints,
      downloadedPackRefs: downloadedRefs,
    );
  }

  @override
  Future<RegionBoundary> loadBoundary(String packId) async {
    return RegionBoundary(
      polygons: [
        const RegionBoundaryPolygon(
          outerRing: [LatLng(0, 0), LatLng(0, 1), LatLng(1, 1), LatLng(1, 0)],
        ),
      ],
    );
  }
}

class LazyHierarchyRepository implements AppStateRepository {
  @override
  AppStateSnapshot createInitialState() {
    return const AppStateSnapshot(
      hasSeenOnboarding: true,
      permissions: <TrackingPermissionType, PermissionGrantState>{},
      isTracking: true,
      gpsQuality: GpsQuality.good,
      regionCatalog: RegionCatalog.empty,
      selectedPackId: '',
      hasLoadedRootPacks: false,
      userPoints: <UserPoint>[],
    );
  }

  @override
  Future<List<RegionPackNode>> loadRootPacks() async {
    return const <RegionPackNode>[
      RegionPackNode(
        id: 'country-de',
        kind: RegionPackKind.country,
        name: 'Deutschland',
        hasChildren: true,
        childIds: <String>[],
        center: LatLng(51, 10),
        bounds: RegionPackBounds(west: 5, south: 47, east: 15, north: 55),
        isDownloaded: false,
        geometryAssetPath: 'country-de',
        displayPath: 'Deutschland',
      ),
    ];
  }

  @override
  Future<List<RegionPackNode>> restoreSelectedPack() async {
    return const <RegionPackNode>[];
  }

  @override
  Future<List<RegionPackNode>> loadChildren(String parentId) async {
    if (parentId != 'country-de') {
      return const <RegionPackNode>[];
    }
    return const <RegionPackNode>[
      RegionPackNode(
        id: 'region-bayern',
        kind: RegionPackKind.region,
        name: 'Bayern',
        parentId: 'country-de',
        hasChildren: true,
        childIds: <String>[],
        center: LatLng(48.9, 11.4),
        bounds: RegionPackBounds(
          west: 8.9,
          south: 47.2,
          east: 13.9,
          north: 50.6,
        ),
        isDownloaded: false,
        geometryAssetPath: 'region-bayern',
        displayPath: 'Deutschland / Bayern',
      ),
    ];
  }

  @override
  Future<List<RegionPackNode>> loadDownloadedPacks() async {
    return const <RegionPackNode>[];
  }

  @override
  Future<void> setHasSeenOnboarding(bool value) async {}

  @override
  Future<void> setPermissions(
    Map<TrackingPermissionType, PermissionGrantState> permissions,
  ) async {}

  @override
  Future<void> setSelectedPack(SelectedPackRef ref) async {}

  @override
  Future<void> setDownloadedPacks(List<SelectedPackRef> refs) async {}

  @override
  Future<void> setUserPoints(List<UserPoint> points) async {}

  @override
  Future<RegionBoundary> loadBoundary(String packId) async {
    return RegionBoundary.empty;
  }
}

void main() {
  test('setHasSeenOnboarding updates state and persists', () async {
    final repository = FakeAppStateRepository();
    final viewModel = AppStateViewModel(
      repository: repository,
      initialState: repository.createInitialState(),
    );

    await viewModel.setHasSeenOnboarding(true);

    expect(viewModel.hasSeenOnboarding, isTrue);
    expect(repository.hasSeenOnboarding, isTrue);
  });

  test('downloadRegion marks region and persists ids', () async {
    final repository = FakeAppStateRepository();
    final viewModel = AppStateViewModel(
      repository: repository,
      initialState: repository.createInitialState(),
    );

    await viewModel.downloadRegion('r1');

    expect(viewModel.regions.first.isDownloaded, isTrue);
    expect(repository.downloadedRefs.map((ref) => ref.id), contains('r1'));
  });

  test('add and remove user points persist', () async {
    final repository = FakeAppStateRepository();
    final viewModel = AppStateViewModel(
      repository: repository,
      initialState: repository.createInitialState(),
    );

    await viewModel.addUserPoint(1.1, 2.2);
    expect(viewModel.userPoints.length, 1);
    expect(repository.userPoints.length, 1);

    final id = viewModel.userPoints.first.id;
    await viewModel.removeUserPoint(id);

    expect(viewModel.userPoints, isEmpty);
    expect(repository.userPoints, isEmpty);
  });

  test(
    'ensureChildrenLoaded wires lazy parent child ids into catalog',
    () async {
      final repository = LazyHierarchyRepository();
      final viewModel = AppStateViewModel(
        repository: repository,
        initialState: repository.createInitialState(),
      );

      await viewModel.bootstrap();
      expect(viewModel.rootPacks.single.id, 'country-de');
      expect(viewModel.childrenOf('country-de'), isEmpty);

      await viewModel.ensureChildrenLoaded('country-de');

      expect(
        viewModel.childrenOf('country-de').map((node) => node.id).toList(),
        ['region-bayern'],
      );
    },
  );
}
