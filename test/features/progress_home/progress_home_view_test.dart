import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/map/view_model/map_view_model.dart';
import 'package:explored/features/progress_home/view/progress_home_view.dart';
import 'package:explored/features/progress_home/view_model/progress_view_model.dart';

import '../../test_utils/exploration_test_harness.dart';
import '../../test_utils/localization_test_utils.dart';
import '../../test_utils/map_test_doubles.dart';

void main() {
  testWidgets(
    'progress home reads matching totals for the selected city center',
    (tester) async {
      final harness = await buildExplorationTestHarness();
      addTearDown(harness.dispose);
      await harness.importCountryPack();
      await harness.selectionRepository.setSelectedEntityId(
        testCityCenterEntityId,
      );

      final locationUpdatesRepository = FakeLocationUpdatesRepository();
      final mapViewModel = MapViewModel(
        mapRepository: buildMapRepository(),
        locationUpdatesRepository: locationUpdatesRepository,
        locationHistoryRepository: FakeLocationHistoryRepository(),
        permissionsRepository: FakePermissionsRepository(),
        entityRepository: harness.entityRepository,
        selectionRepository: harness.selectionRepository,
      );
      addTearDown(locationUpdatesRepository.dispose);
      addTearDown(mapViewModel.dispose);

      final app = await buildLocalizedTestApp(
        ProgressHomeView(
          progressViewModel: ProgressViewModel(
            entityRepository: harness.entityRepository,
            progressRepository: harness.progressRepository,
            selectionRepository: harness.selectionRepository,
          ),
          mapViewModel: mapViewModel,
          entityRepository: harness.entityRepository,
          selectionRepository: harness.selectionRepository,
        ),
      );

      await tester.pumpWidget(app);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Downtown'), findsOneWidget);
      expect(find.text('0 peaks • 0 huts • 2 monuments'), findsOneWidget);
      expect(find.text('0/2'), findsOneWidget);
      expect(find.text('0m/100m'), findsOneWidget);
    },
  );
}
