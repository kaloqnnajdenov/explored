import 'package:explored/features/app_state/data/models/app_permission.dart';
import 'package:explored/features/app_state/data/models/app_state_snapshot.dart';
import 'package:explored/features/app_state/data/models/region.dart';
import 'package:explored/features/app_state/data/models/user_point.dart';
import 'package:explored/features/app_state/data/repositories/app_state_repository.dart';
import 'package:explored/features/app_state/view_model/app_state_view_model.dart';
import 'package:explored/features/permission_gate/view/permissions_gate_view.dart';
import 'package:explored/features/region_catalog/data/models/region_boundary.dart';
import 'package:explored/features/region_catalog/data/models/region_pack_node.dart';
import 'package:explored/features/region_catalog/data/models/selected_pack_ref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../test_utils/localization_test_utils.dart';
import '../../test_utils/map_test_doubles.dart';

class FakeRepository implements AppStateRepository {
  FakeRepository(this.snapshot);

  AppStateSnapshot snapshot;

  @override
  AppStateSnapshot createInitialState() => snapshot;

  @override
  Future<List<RegionPackNode>> loadRootPacks() async {
    return snapshot.regionCatalog.rootNodes;
  }

  @override
  Future<List<RegionPackNode>> restoreSelectedPack() async {
    final selectedPack = snapshot.regionCatalog.maybeNodeById(
      snapshot.selectedPackId,
    );
    return selectedPack == null ? const <RegionPackNode>[] : [selectedPack];
  }

  @override
  Future<List<RegionPackNode>> loadChildren(String parentId) async {
    return snapshot.regionCatalog.childrenOf(parentId);
  }

  @override
  Future<List<RegionPackNode>> loadDownloadedPacks() async {
    return snapshot.regions.where((region) => region.isDownloaded).toList();
  }

  @override
  Future<void> setSelectedPack(SelectedPackRef ref) async {
    snapshot = snapshot.copyWith(selectedPackId: ref.id, selectedPackRef: ref);
  }

  @override
  Future<void> setDownloadedPacks(List<SelectedPackRef> refs) async {}

  @override
  Future<void> setHasSeenOnboarding(bool value) async {
    snapshot = snapshot.copyWith(hasSeenOnboarding: value);
  }

  @override
  Future<void> setPermissions(
    Map<TrackingPermissionType, PermissionGrantState> permissions,
  ) async {
    snapshot = snapshot.copyWith(permissions: permissions);
  }

  @override
  Future<void> setUserPoints(List<UserPoint> points) async {}

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

void main() {
  testWidgets('grant required permissions completes onboarding', (
    tester,
  ) async {
    await loadTestTranslations();

    final initialSnapshot =
        buildAppStateSnapshot(
          regions: const [
            Region(
              id: 'r1',
              name: 'Region',
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
          currentRegionId: 'r1',
        ).copyWith(
          hasSeenOnboarding: false,
          permissions: {
            for (final permission in TrackingPermissionType.values)
              permission: PermissionGrantState.prompt,
          },
        );

    final repository = FakeRepository(initialSnapshot);
    final viewModel = AppStateViewModel(
      repository: repository,
      initialState: initialSnapshot,
    );

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/permissions',
          builder: (_, __) => PermissionsGateView(appStateViewModel: viewModel),
        ),
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('home')),
        ),
      ],
      initialLocation: '/permissions',
    );

    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump(const Duration(milliseconds: 300));

    final grantButtonFinder = find.text('Grant required permissions');
    await tester.scrollUntilVisible(
      grantButtonFinder,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(grantButtonFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 850));
    await tester.pump(const Duration(milliseconds: 300));

    expect(viewModel.hasSeenOnboarding, isTrue);
    expect(
      viewModel.permissions[TrackingPermissionType.location],
      PermissionGrantState.granted,
    );
    expect(find.text('home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
