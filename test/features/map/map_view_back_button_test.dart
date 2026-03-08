import 'package:explored/features/map/view/map_view.dart';
import 'package:explored/features/map/view_model/map_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/localization_test_utils.dart';
import '../../test_utils/map_test_doubles.dart';

void main() {
  testWidgets('back button calls callback when enabled', (tester) async {
    final locationUpdatesRepository = FakeLocationUpdatesRepository();
    final locationHistoryRepository = FakeLocationHistoryRepository();
    final mapViewModel = MapViewModel(
      mapRepository: buildMapRepository(),
      locationUpdatesRepository: locationUpdatesRepository,
      locationHistoryRepository: locationHistoryRepository,
      permissionsRepository: FakePermissionsRepository(),
    );

    addTearDown(() async {
      mapViewModel.dispose();
      await locationUpdatesRepository.dispose();
      await locationHistoryRepository.dispose();
    });

    var backPressed = false;
    final app = await buildLocalizedTestApp(
      MapView(
        viewModel: mapViewModel,
        showBackButton: true,
        onBack: () {
          backPressed = true;
        },
      ),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    expect(backPressed, isTrue);
  });
}
