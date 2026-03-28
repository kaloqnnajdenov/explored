import 'package:explored/features/map/view/map_view.dart';
import 'package:explored/features/map/view_model/map_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/exploration_test_harness.dart';
import '../../test_utils/localization_test_utils.dart';
import '../../test_utils/map_test_doubles.dart';

void main() {
  testWidgets('renders selected region peaks, huts, and monuments', (
    tester,
  ) async {
    final harness = await buildExplorationTestHarness();
    addTearDown(harness.dispose);
    await harness.importCountryPack();
    await harness.selectionRepository.setSelectedEntityId(testRegionEntityId);

    final locationUpdatesRepository = FakeLocationUpdatesRepository();
    final locationHistoryRepository = FakeLocationHistoryRepository();
    final mapViewModel = MapViewModel(
      mapRepository: buildMapRepository(),
      locationUpdatesRepository: locationUpdatesRepository,
      locationHistoryRepository: locationHistoryRepository,
      permissionsRepository: FakePermissionsRepository(),
      entityRepository: harness.entityRepository,
      objectRepository: harness.objectRepository,
      selectionRepository: harness.selectionRepository,
    );

    addTearDown(() async {
      mapViewModel.dispose();
      await locationUpdatesRepository.dispose();
      await locationHistoryRepository.dispose();
    });

    final app = await buildLocalizedTestApp(MapView(viewModel: mapViewModel));

    await tester.pumpWidget(app);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byIcon(Icons.landscape), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.account_balance), findsNWidgets(2));
  });
}
