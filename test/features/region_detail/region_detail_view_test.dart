import 'package:explored/features/app_state/data/models/app_permission.dart';
import 'package:explored/features/app_state/data/models/app_state_snapshot.dart';
import 'package:explored/features/app_state/data/models/gps_quality.dart';
import 'package:explored/features/app_state/data/models/user_point.dart';
import 'package:explored/features/app_state/data/repositories/app_state_repository.dart';
import 'package:explored/features/app_state/view_model/app_state_view_model.dart';
import 'package:explored/features/region_catalog/data/models/region_boundary.dart';
import 'package:explored/features/region_catalog/data/models/region_catalog.dart';
import 'package:explored/features/region_catalog/data/models/region_pack_bounds.dart';
import 'package:explored/features/region_catalog/data/models/region_pack_kind.dart';
import 'package:explored/features/region_catalog/data/models/region_pack_node.dart';
import 'package:explored/features/region_catalog/data/models/selected_pack_ref.dart';
import 'package:explored/features/region_detail/view/region_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../test_utils/localization_test_utils.dart';

class LazyRegionCitiesRepository implements AppStateRepository {
  @override
  AppStateSnapshot createInitialState() {
    const region = RegionPackNode(
      id: 'region-bayern',
      kind: RegionPackKind.region,
      name: 'Bayern',
      hasChildren: true,
      childIds: <String>[],
      center: LatLng(48.9, 11.4),
      bounds: RegionPackBounds(west: 8.9, south: 47.2, east: 13.9, north: 50.6),
      isDownloaded: true,
      geometryAssetPath: 'region-bayern',
      displayPath: 'Testland / Bayern',
    );

    return const AppStateSnapshot(
      hasSeenOnboarding: true,
      permissions: <TrackingPermissionType, PermissionGrantState>{},
      isTracking: true,
      gpsQuality: GpsQuality.good,
      regionCatalog: RegionCatalog(
        rootIds: <String>['region-bayern'],
        nodesById: <String, RegionPackNode>{'region-bayern': region},
      ),
      selectedPackId: 'region-bayern',
      hasLoadedRootPacks: true,
      userPoints: <UserPoint>[],
    );
  }

  @override
  Future<List<RegionPackNode>> loadRootPacks() async {
    return createInitialState().regionCatalog.rootNodes;
  }

  @override
  Future<List<RegionPackNode>> restoreSelectedPack() async {
    return const <RegionPackNode>[];
  }

  @override
  Future<List<RegionPackNode>> loadChildren(String parentId) async {
    if (parentId != 'region-bayern') {
      return const <RegionPackNode>[];
    }

    return const <RegionPackNode>[
      RegionPackNode(
        id: 'city-munich',
        kind: RegionPackKind.city,
        name: 'Munich',
        parentId: 'region-bayern',
        hasChildren: false,
        childIds: <String>[],
        center: LatLng(48.137, 11.575),
        bounds: RegionPackBounds(
          west: 11.3,
          south: 48.0,
          east: 11.8,
          north: 48.25,
        ),
        isDownloaded: true,
        geometryAssetPath: 'city-munich',
        displayPath: 'Testland / Bayern / Munich',
      ),
      RegionPackNode(
        id: 'city-nuremberg',
        kind: RegionPackKind.city,
        name: 'Nuremberg',
        parentId: 'region-bayern',
        hasChildren: false,
        childIds: <String>[],
        center: LatLng(49.452, 11.077),
        bounds: RegionPackBounds(
          west: 10.9,
          south: 49.35,
          east: 11.2,
          north: 49.55,
        ),
        isDownloaded: true,
        geometryAssetPath: 'city-nuremberg',
        displayPath: 'Testland / Bayern / Nuremberg',
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
  testWidgets('region pack page lazy-loads its cities and opens a city page', (
    tester,
  ) async {
    await loadTestTranslations();

    final repository = LazyRegionCitiesRepository();
    final appStateViewModel = AppStateViewModel(
      repository: repository,
      initialState: repository.createInitialState(),
    );
    final router = GoRouter(
      initialLocation: '/pack/region-bayern',
      routes: [
        GoRoute(
          path: '/pack/:id',
          builder: (_, state) => PackDetailView(
            appStateViewModel: appStateViewModel,
            packId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(path: '/map', builder: (_, __) => const SizedBox.shrink()),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Munich'), findsOneWidget);
    expect(find.text('Nuremberg'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('pack-child-city-munich')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Testland / Bayern / Munich'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
