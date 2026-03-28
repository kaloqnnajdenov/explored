import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/entity_selector/view_model/entity_selector_view_model.dart';

import '../../test_utils/exploration_test_harness.dart';

void main() {
  test('toggleExpanded loads children inline and can collapse again', () async {
    final harness = await buildExplorationTestHarness();
    addTearDown(harness.dispose);

    final viewModel = EntitySelectorViewModel(
      entityRepository: harness.entityRepository,
      selectionRepository: harness.selectionRepository,
    );

    await viewModel.loadCountries();

    expect(viewModel.isExpanded(testCountryEntityId), isFalse);

    await viewModel.toggleExpanded(testCountryEntityId);

    expect(viewModel.isExpanded(testCountryEntityId), isTrue);
    expect(
      viewModel
          .childrenFor(testCountryEntityId)
          .map((entity) => entity.entityId)
          .toList(),
      <String>[testRegionEntityId, testRegionlessCityEntityId],
    );

    await viewModel.toggleExpanded(testCountryEntityId);

    expect(viewModel.isExpanded(testCountryEntityId), isFalse);
  });

  test('loadCountries restores the saved selection path as expanded', () async {
    final harness = await buildExplorationTestHarness();
    addTearDown(harness.dispose);

    await harness.importCountryPack();
    await harness.selectionRepository.setSelectedEntityId(
      testRegionalCityEntityId,
    );

    final viewModel = EntitySelectorViewModel(
      entityRepository: harness.entityRepository,
      selectionRepository: harness.selectionRepository,
    );

    await viewModel.loadCountries();

    expect(viewModel.selectedEntityId, testRegionalCityEntityId);
    expect(viewModel.isExpanded(testCountryEntityId), isTrue);
    expect(viewModel.isExpanded(testRegionEntityId), isTrue);
    expect(
      viewModel
          .childrenFor(testRegionEntityId)
          .map((entity) => entity.entityId)
          .toList(),
      <String>[testRegionalCityEntityId],
    );
  });
}
