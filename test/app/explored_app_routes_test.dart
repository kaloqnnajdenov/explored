import 'package:flutter_test/flutter_test.dart';

import 'package:explored/app/explored_app.dart';
import 'package:explored/features/app_state/data/models/app_permission.dart';
import 'package:explored/features/app_state/data/models/app_state_snapshot.dart';
import 'package:explored/features/app_state/data/models/user_point.dart';
import 'package:explored/features/app_state/data/repositories/app_state_repository.dart';
import 'package:explored/features/app_state/view_model/app_state_view_model.dart';
import 'package:explored/features/gpx_import/data/repositories/gpx_import_repository.dart';
import 'package:explored/features/gpx_import/data/services/gpx_file_picker_service.dart';
import 'package:explored/features/gpx_import/view_model/gpx_import_view_model.dart';
import 'package:explored/features/map/view_model/map_view_model.dart';
import 'package:explored/features/permissions/view_model/permissions_view_model.dart';
import 'package:explored/features/progress_home/view_model/progress_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../test_utils/exploration_test_harness.dart';
import '../test_utils/localization_test_utils.dart';
import '../test_utils/map_test_doubles.dart';

class _FakeAppStateRepository implements AppStateRepository {
  @override
  AppStateSnapshot createInitialState() {
    return const AppStateSnapshot(
      hasSeenOnboarding: true,
      permissions: <TrackingPermissionType, PermissionGrantState>{},
      isTracking: true,
      userPoints: <UserPoint>[],
    );
  }

  @override
  Future<void> setHasSeenOnboarding(bool value) async {}

  @override
  Future<void> setPermissions(
    Map<TrackingPermissionType, PermissionGrantState> permissions,
  ) async {}

  @override
  Future<void> setUserPoints(List<UserPoint> points) async {}
}

class _FakeGpxImportRepository implements GpxImportRepository {
  @override
  Future<GpxImportPreparation> prepareImport() async {
    return const GpxImportPreparation(outcome: GpxImportOutcome.cancelled);
  }

  @override
  Future<GpxImportResult> processFile(GpxSelectedFile file) async {
    return const GpxImportResult(outcome: GpxImportOutcome.cancelled);
  }
}

void main() {
  testWidgets('legacy /pack/:id route redirects to the entity detail screen', (
    tester,
  ) async {
    final harness = await buildExplorationTestHarness();
    addTearDown(harness.dispose);
    await harness.importCountryPack();

    final app = await buildLocalizedTestRoot(
      ExploredApp(
        appStateViewModel: AppStateViewModel(
          repository: _FakeAppStateRepository(),
          initialState: _FakeAppStateRepository().createInitialState(),
        ),
        mapViewModel: MapViewModel(
          mapRepository: buildMapRepository(),
          locationUpdatesRepository: FakeLocationUpdatesRepository(),
          locationHistoryRepository: FakeLocationHistoryRepository(),
          permissionsRepository: FakePermissionsRepository(),
          entityRepository: harness.entityRepository,
          selectionRepository: harness.selectionRepository,
        ),
        permissionsViewModel: PermissionsViewModel(
          repository: FakePermissionsRepository(),
        ),
        gpxImportViewModel: GpxImportViewModel(
          repository: _FakeGpxImportRepository(),
        ),
        progressViewModel: ProgressViewModel(
          entityRepository: harness.entityRepository,
          progressRepository: harness.progressRepository,
          selectionRepository: harness.selectionRepository,
        ),
        entityRepository: harness.entityRepository,
        selectionRepository: harness.selectionRepository,
        progressRepository: harness.progressRepository,
        initialLocation: '/pack/$testRegionalCityEntityId',
      ),
    );

    await tester.pumpWidget(app);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Regional City'), findsOneWidget);
    expect(find.textContaining('Alpine Region'), findsOneWidget);
  });

  testWidgets(
    'legacy /region/:id route redirects to the entity detail screen',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/region/$testRegionEntityId',
        routes: [
          GoRoute(
            path: '/entity/:id',
            builder: (_, state) =>
                Scaffold(body: Text('entity:${state.pathParameters['id']!}')),
          ),
          GoRoute(
            path: '/region/:id',
            redirect: (_, state) => '/entity/${state.pathParameters['id']!}',
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('entity:$testRegionEntityId'), findsOneWidget);
    },
  );
}
