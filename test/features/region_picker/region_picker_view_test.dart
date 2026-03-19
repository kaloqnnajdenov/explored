import 'package:explored/features/app_state/view_model/app_state_view_model.dart';
import 'package:explored/features/region_catalog/data/models/region_pack_kind.dart';
import 'package:explored/features/region_picker/view/region_picker_view.dart';
import 'package:explored/features/region_picker/view_model/region_picker_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/localization_test_utils.dart';
import '../../test_utils/map_test_doubles.dart';

void main() {
  testWidgets('picker shows countries first and drills down into children', (
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
        childIds: const ['city-innsbruck'],
        displayPath: 'Austria / Tirol',
      ),
      buildTestPackNode(
        id: 'city-innsbruck',
        name: 'Innsbruck',
        kind: RegionPackKind.city,
        parentId: 'region-tirol',
        displayPath: 'Austria / Tirol / Innsbruck',
      ),
      buildTestPackNode(
        id: 'country-de',
        name: 'Germany',
        kind: RegionPackKind.country,
        childIds: const ['region-bayern'],
        displayPath: 'Germany',
      ),
      buildTestPackNode(
        id: 'region-bayern',
        name: 'Bayern',
        kind: RegionPackKind.region,
        parentId: 'country-de',
        displayPath: 'Germany / Bayern',
      ),
    ];
    final repository = FakeAppStateRepository(
      buildPackAppStateSnapshot(packs: packs, selectedPackId: 'country-at'),
    );
    final appStateViewModel = AppStateViewModel(
      repository: repository,
      initialState: repository.snapshot,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegionPickerView(
            viewModel: RegionPickerViewModel(
              appStateViewModel: appStateViewModel,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Austria'), findsOneWidget);
    expect(find.text('Germany'), findsOneWidget);
    expect(find.text('Tirol'), findsNothing);

    await tester.tap(find.byIcon(Icons.chevron_right).last);
    await tester.pumpAndSettle();

    expect(find.text('Bayern'), findsOneWidget);
    expect(appStateViewModel.selectedPackId, 'country-at');

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.chevron_right).first);
    await tester.pumpAndSettle();

    expect(find.text('Tirol'), findsOneWidget);
    expect(find.text('Innsbruck'), findsNothing);

    await tester.tap(find.byIcon(Icons.chevron_right).first);
    await tester.pumpAndSettle();

    expect(find.text('Innsbruck'), findsOneWidget);

    await tester.tap(find.text('Innsbruck'));
    await tester.pumpAndSettle();

    expect(appStateViewModel.selectedPackId, 'city-innsbruck');
  });
}
