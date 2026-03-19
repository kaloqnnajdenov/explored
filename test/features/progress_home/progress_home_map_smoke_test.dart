import 'package:explored/features/app_state/data/models/region.dart';
import 'package:explored/features/app_state/view_model/app_state_view_model.dart';
import 'package:explored/features/map/view/widgets/tracked_history_map.dart';
import 'package:explored/features/map/view_model/map_view_model.dart';
import 'package:explored/features/progress_home/view/progress_home_view.dart';
import 'package:explored/features/region_catalog/data/models/region_pack_kind.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

import '../../test_utils/localization_test_utils.dart';
import '../../test_utils/map_test_doubles.dart';

void main() {
  testWidgets('home region map uses shared map stack with region polygon', (
    tester,
  ) async {
    const region = Region(
      id: 'region-1',
      name: 'Region One',
      totalArea: 100,
      exploredArea: 0,
      isDownloaded: false,
      center: LatLng(42.0, 23.0),
      bounds: [
        LatLng(42.2, 22.8),
        LatLng(42.2, 23.2),
        LatLng(41.8, 23.2),
        LatLng(41.8, 22.8),
      ],
      features: RegionFeatures(
        trails: RegionFeatureProgress(total: 10, completed: 0),
        peaks: RegionFeatureProgress(total: 5, completed: 0),
        huts: RegionFeatureProgress(total: 3, completed: 0),
      ),
    );
    final appStateSnapshot = buildAppStateSnapshot(
      regions: const [region],
      currentRegionId: 'region-1',
    );
    final appStateViewModel = AppStateViewModel(
      repository: FakeAppStateRepository(appStateSnapshot),
      initialState: appStateSnapshot,
    );
    final locationUpdatesRepository = FakeLocationUpdatesRepository();
    final locationHistoryRepository = FakeLocationHistoryRepository();
    await locationHistoryRepository.addImportedSamples([
      buildSample(latitude: 42.01, longitude: 23.01),
    ]);
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
      TickerMode(
        enabled: false,
        child: ProgressHomeView(
          appStateViewModel: appStateViewModel,
          mapViewModel: mapViewModel,
        ),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.byType(TrackedHistoryMap), findsOneWidget);
    expect(find.byType(PolygonLayer), findsOneWidget);
    expect(find.byType(CircleLayer), findsOneWidget);

    // Dispose the repeating animation ticker in ProgressHomeView.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'home region picker chevron drills into the next level in the modal',
    (tester) async {
      final packs = [
        buildTestPackNode(
          id: 'country-de',
          name: 'Deutschland',
          kind: RegionPackKind.country,
          childIds: const ['region-bayern'],
          displayPath: 'Deutschland',
        ),
        buildTestPackNode(
          id: 'region-bayern',
          name: 'Bayern',
          kind: RegionPackKind.region,
          parentId: 'country-de',
          displayPath: 'Deutschland / Bayern',
        ),
      ];
      final appStateSnapshot = buildPackAppStateSnapshot(
        packs: packs,
        selectedPackId: 'country-de',
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
        TickerMode(
          enabled: false,
          child: ProgressHomeView(
            appStateViewModel: appStateViewModel,
            mapViewModel: mapViewModel,
          ),
        ),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Browse packs'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey<String>('region-picker-open-country-de')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bayern'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
