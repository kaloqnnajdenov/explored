import 'package:explored/features/app_state/data/models/region.dart';
import 'package:explored/features/app_state/view_model/app_state_view_model.dart';
import 'package:explored/features/gpx_import/view_model/gpx_import_view_model.dart';
import 'package:explored/features/map/view_model/map_view_model.dart';
import 'package:explored/features/settings/view/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import '../../test_utils/localization_test_utils.dart';
import '../../test_utils/map_test_doubles.dart';

void main() {
  testWidgets('region packs show delete-only controls without download chip', (
    tester,
  ) async {
    await loadTestTranslations();

    final regions = const [
      Region(
        id: 'r1',
        name: 'Northern Alps',
        totalArea: 100,
        exploredArea: 10,
        isDownloaded: false,
        center: LatLng(0, 0),
        bounds: [LatLng(0, 0), LatLng(0, 1), LatLng(1, 1), LatLng(1, 0)],
        features: RegionFeatures(
          trails: RegionFeatureProgress(total: 1, completed: 0),
          peaks: RegionFeatureProgress(total: 1, completed: 0),
          huts: RegionFeatureProgress(total: 1, completed: 0),
        ),
      ),
      Region(
        id: 'r2',
        name: 'Otztal Alps',
        totalArea: 200,
        exploredArea: 20,
        isDownloaded: true,
        center: LatLng(1, 1),
        bounds: [LatLng(1, 1), LatLng(1, 2), LatLng(2, 2), LatLng(2, 1)],
        features: RegionFeatures(
          trails: RegionFeatureProgress(total: 2, completed: 1),
          peaks: RegionFeatureProgress(total: 2, completed: 1),
          huts: RegionFeatureProgress(total: 2, completed: 1),
        ),
      ),
    ];
    final appStateRepository = FakeAppStateRepository(
      buildAppStateSnapshot(regions: regions, currentRegionId: 'r1'),
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
    expect(find.byIcon(Icons.delete_outline), findsNWidgets(regions.length));

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('Coming soon — this feature is not yet implemented.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
