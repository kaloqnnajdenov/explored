import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/gpx_import/data/repositories/gpx_import_repository.dart';
import 'package:explored/features/gpx_import/data/services/gpx_file_picker_service.dart';
import 'package:explored/features/gpx_import/view_model/gpx_import_view_model.dart';
import 'package:explored/features/map/view_model/map_view_model.dart';
import 'package:explored/features/settings/view/settings_view.dart';

import '../../test_utils/exploration_test_harness.dart';
import '../../test_utils/localization_test_utils.dart';
import '../../test_utils/map_test_doubles.dart';

class _FakeGpxImportRepository implements GpxImportRepository {
  @override
  Future<GpxImportPreparation> prepareImport() async {
    return const GpxImportPreparation(outcome: GpxImportOutcome.cancelled);
  }

  @override
  Future<GpxImportResult> processFile(GpxSelectedFile file) async {
    return const GpxImportResult(outcome: GpxImportOutcome.cancelled);
  }
}

void main() {
  testWidgets('settings hides obsolete country pack import controls', (
    tester,
  ) async {
    final harness = await buildExplorationTestHarness();
    addTearDown(harness.dispose);

    final mapViewModel = MapViewModel(
      mapRepository: buildMapRepository(),
      locationUpdatesRepository: FakeLocationUpdatesRepository(),
      locationHistoryRepository: FakeLocationHistoryRepository(),
      permissionsRepository: FakePermissionsRepository(),
    );
    final app = await buildLocalizedTestApp(
      SettingsView(
        mapViewModel: mapViewModel,
        gpxImportViewModel: GpxImportViewModel(
          repository: _FakeGpxImportRepository(),
        ),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Country Packs'), findsNothing);
    expect(find.text('Testland'), findsNothing);
    expect(find.text('Import'), findsNothing);
    expect(find.text('Data & Storage'), findsOneWidget);
    expect(find.text('Import GPX'), findsOneWidget);
  });
}
