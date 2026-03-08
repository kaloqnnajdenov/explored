import 'package:explored/features/app_state/data/models/region.dart';
import 'package:explored/features/app_state/view_model/app_state_view_model.dart';
import 'package:explored/features/map/view/widgets/tracked_history_map.dart';
import 'package:explored/features/map/view_model/map_view_model.dart';
import 'package:explored/features/progress_home/view/widgets/region_finder_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import '../../test_utils/localization_test_utils.dart';
import '../../test_utils/map_test_doubles.dart';

void main() {
  testWidgets('region finder map preserves map-tap region selection', (
    tester,
  ) async {
    const regionOne = Region(
      id: 'region-1',
      name: 'Region One',
      totalArea: 100,
      exploredArea: 0,
      isDownloaded: false,
      center: LatLng(0.0, 0.0),
      bounds: [
        LatLng(0.2, -0.2),
        LatLng(0.2, 0.2),
        LatLng(-0.2, 0.2),
        LatLng(-0.2, -0.2),
      ],
      features: RegionFeatures(
        trails: RegionFeatureProgress(total: 10, completed: 0),
        peaks: RegionFeatureProgress(total: 5, completed: 0),
        huts: RegionFeatureProgress(total: 3, completed: 0),
      ),
    );
    const regionTwo = Region(
      id: 'region-2',
      name: 'Region Two',
      totalArea: 100,
      exploredArea: 0,
      isDownloaded: false,
      center: LatLng(10.0, 10.0),
      bounds: [
        LatLng(10.2, 9.8),
        LatLng(10.2, 10.2),
        LatLng(9.8, 10.2),
        LatLng(9.8, 9.8),
      ],
      features: RegionFeatures(
        trails: RegionFeatureProgress(total: 10, completed: 0),
        peaks: RegionFeatureProgress(total: 5, completed: 0),
        huts: RegionFeatureProgress(total: 3, completed: 0),
      ),
    );
    final appStateSnapshot = buildAppStateSnapshot(
      regions: const [regionOne, regionTwo],
      currentRegionId: 'region-1',
    );
    final appStateViewModel = AppStateViewModel(
      repository: FakeAppStateRepository(appStateSnapshot),
      initialState: appStateSnapshot,
    );
    final locationUpdatesRepository = FakeLocationUpdatesRepository();
    final locationHistoryRepository = FakeLocationHistoryRepository();
    final mapViewModel = MapViewModel(
      mapRepository: buildMapRepository(),
      locationUpdatesRepository: locationUpdatesRepository,
      locationHistoryRepository: locationHistoryRepository,
      permissionsRepository: FakePermissionsRepository(),
    );
    await mapViewModel.initialize();

    addTearDown(() async {
      mapViewModel.dispose();
      await locationUpdatesRepository.dispose();
      await locationHistoryRepository.dispose();
    });

    final app = await buildLocalizedTestApp(
      Scaffold(
        body: RegionFinderSheet(
          appStateViewModel: appStateViewModel,
          mapViewModel: mapViewModel,
        ),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.byType(TrackedHistoryMap), findsOneWidget);
    expect(find.byType(PolygonLayer), findsOneWidget);

    final flutterMap = tester.widget<FlutterMap>(
      find.descendant(
        of: find.byType(TrackedHistoryMap),
        matching: find.byType(FlutterMap),
      ),
    );
    expect(flutterMap.options.onTap, isNotNull);

    flutterMap.options.onTap!(
      TapPosition(Offset.zero, Offset.zero),
      const LatLng(10.0, 10.0),
    );
    await tester.pumpAndSettle();

    expect(appStateViewModel.currentRegionId, 'region-2');
  });
}
