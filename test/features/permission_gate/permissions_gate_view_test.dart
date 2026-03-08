import 'package:explored/features/app_state/data/models/app_permission.dart';
import 'package:explored/features/app_state/data/models/app_state_snapshot.dart';
import 'package:explored/features/app_state/data/models/gps_quality.dart';
import 'package:explored/features/app_state/data/models/region.dart';
import 'package:explored/features/app_state/data/models/user_point.dart';
import 'package:explored/features/app_state/data/repositories/app_state_repository.dart';
import 'package:explored/features/app_state/view_model/app_state_view_model.dart';
import 'package:explored/features/permission_gate/view/permissions_gate_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../test_utils/localization_test_utils.dart';

class FakeRepository implements AppStateRepository {
  FakeRepository(this.snapshot);

  AppStateSnapshot snapshot;

  @override
  Future<AppStateSnapshot> load() async => snapshot;

  @override
  Future<void> setCurrentRegionId(String regionId) async {
    snapshot = snapshot.copyWith(currentRegionId: regionId);
  }

  @override
  Future<void> setDownloadedRegionIds(Set<String> ids) async {}

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
}

void main() {
  testWidgets('grant required permissions completes onboarding', (
    tester,
  ) async {
    await loadTestTranslations();

    final initialSnapshot = AppStateSnapshot(
      hasSeenOnboarding: false,
      permissions: {
        for (final permission in TrackingPermissionType.values)
          permission: PermissionGrantState.prompt,
      },
      isTracking: true,
      gpsQuality: GpsQuality.good,
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
      userPoints: const [],
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
