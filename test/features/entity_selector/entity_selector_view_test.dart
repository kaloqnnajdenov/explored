import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/entity_selector/view/entity_selector_view.dart';
import 'package:explored/features/entity_selector/view_model/entity_selector_view_model.dart';

import '../../test_utils/exploration_test_harness.dart';
import '../../test_utils/localization_test_utils.dart';

void main() {
  testWidgets('selector shows hierarchy and stores the chosen entity', (
    tester,
  ) async {
    final harness = await buildExplorationTestHarness();
    addTearDown(harness.dispose);
    await harness.importCountryPack();
    final viewModel = EntitySelectorViewModel(
      entityRepository: harness.entityRepository,
      selectionRepository: harness.selectionRepository,
    );
    await viewModel.loadCountries();

    final app = await buildLocalizedTestApp(
      Scaffold(body: EntitySelectorView(viewModel: viewModel)),
    );

    await tester.pumpWidget(app);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Testland', skipOffstage: false), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey<String>('entity-selector-expand-country:relation:1'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Alpine Region'), findsOneWidget);
    expect(find.text('Coastal City'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey<String>('entity-selector-expand-region:relation:2'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Regional City'), findsOneWidget);

    await tester.tap(find.text('Regional City'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Use selection'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final selectedId = await harness.selectionRepository.getSelectedEntityId();
    expect(selectedId, testRegionalCityEntityId);
  });
}
