import 'package:explored/features/app_state/view_model/app_state_view_model.dart';
import 'package:explored/features/gpx_import/view_model/gpx_import_view_model.dart';
import 'package:explored/features/map/view_model/map_view_model.dart';
import 'package:explored/features/region_catalog/data/models/region_pack_bounds.dart';
import 'package:explored/features/region_catalog/data/models/region_pack_kind.dart';
import 'package:explored/features/settings/view/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../test_utils/localization_test_utils.dart';
import '../../test_utils/map_test_doubles.dart';

void main() {
  testWidgets('region packs show delete-only controls without download chip', (
    tester,
  ) async {
    await loadTestTranslations();

    final packs = [
      buildTestPackNode(
        id: 'country-at',
        name: 'Austria',
        kind: RegionPackKind.country,
        childIds: const ['region-tirol', 'region-vienna'],
        displayPath: 'Austria',
      ),
      buildTestPackNode(
        id: 'region-tirol',
        name: 'Tirol',
        kind: RegionPackKind.region,
        parentId: 'country-at',
        isDownloaded: true,
        bounds: const RegionPackBounds(
          west: 10,
          south: 46,
          east: 12,
          north: 48,
        ),
        displayPath: 'Austria / Tirol',
      ),
      buildTestPackNode(
        id: 'region-vienna',
        name: 'Vienna',
        kind: RegionPackKind.region,
        parentId: 'country-at',
        isDownloaded: false,
        displayPath: 'Austria / Vienna',
      ),
    ];
    final appStateRepository = FakeAppStateRepository(
      buildPackAppStateSnapshot(packs: packs, selectedPackId: 'region-tirol'),
    );
    final appStateViewModel = AppStateViewModel(
      repository: appStateRepository,
      initialState: appStateRepository.snapshot,
    );
    final locationUpdatesRepository = FakeLocationUpdatesRepository();
    final mapViewModel = MapViewModel(
      mapRepository: buildMapRepository(),
      locationUpdatesRepository: locationUpdatesRepository,
      locationHistoryRepository: FakeLocationHistoryRepository(),
      permissionsRepository: FakePermissionsRepository(),
    );
    final gpxImportViewModel = GpxImportViewModel(
      repository: FakeGpxImportRepository(),
    );

    addTearDown(() async {
      mapViewModel.dispose();
      await locationUpdatesRepository.dispose();
    });

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsView(
          appStateViewModel: appStateViewModel,
          mapViewModel: mapViewModel,
          gpxImportViewModel: gpxImportViewModel,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ActionChip), findsNothing);
    expect(find.text('Austria'), findsOneWidget);
    expect(find.text('Tirol'), findsOneWidget);
    expect(find.text('Vienna'), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('Coming soon — this feature is not yet implemented.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('permissions action navigates to permissions settings page', (
    tester,
  ) async {
    await loadTestTranslations();

    final packs = [
      buildTestPackNode(
        id: 'country-at',
        name: 'Austria',
        kind: RegionPackKind.country,
        childIds: const ['region-tirol'],
        displayPath: 'Austria',
      ),
      buildTestPackNode(
        id: 'region-tirol',
        name: 'Tirol',
        kind: RegionPackKind.region,
        parentId: 'country-at',
        displayPath: 'Austria / Tirol',
      ),
    ];
    final appStateRepository = FakeAppStateRepository(
      buildPackAppStateSnapshot(packs: packs, selectedPackId: 'region-tirol'),
    );
    final appStateViewModel = AppStateViewModel(
      repository: appStateRepository,
      initialState: appStateRepository.snapshot,
    );
    final locationUpdatesRepository = FakeLocationUpdatesRepository();
    final mapViewModel = MapViewModel(
      mapRepository: buildMapRepository(),
      locationUpdatesRepository: locationUpdatesRepository,
      locationHistoryRepository: FakeLocationHistoryRepository(),
      permissionsRepository: FakePermissionsRepository(),
    );
    final gpxImportViewModel = GpxImportViewModel(
      repository: FakeGpxImportRepository(),
    );

    addTearDown(() async {
      mapViewModel.dispose();
      await locationUpdatesRepository.dispose();
    });

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/settings',
          builder: (_, __) => SettingsView(
            appStateViewModel: appStateViewModel,
            mapViewModel: mapViewModel,
            gpxImportViewModel: gpxImportViewModel,
          ),
        ),
        GoRoute(
          path: '/settings/permissions',
          builder: (_, __) => const Scaffold(body: Text('permissions_page')),
        ),
      ],
      initialLocation: '/settings',
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Permissions'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      router.routeInformationProvider.value.uri.path,
      '/settings/permissions',
    );
  });
}
