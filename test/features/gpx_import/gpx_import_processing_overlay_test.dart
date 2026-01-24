import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/gpx_import/data/repositories/gpx_import_repository.dart';
import 'package:explored/features/gpx_import/data/services/gpx_file_picker_service.dart';
import 'package:explored/features/gpx_import/view/widgets/gpx_import_processing_overlay.dart';
import 'package:explored/features/gpx_import/view_model/gpx_import_view_model.dart';
import '../../test_utils/localization_test_utils.dart';

class PendingGpxImportRepository implements GpxImportRepository {
  final Completer<GpxImportResult> completer = Completer<GpxImportResult>();

  @override
  Future<GpxImportPreparation> prepareImport() async {
    return GpxImportPreparation(
      outcome: GpxImportOutcome.success,
      file: GpxSelectedFile(
        name: 'track.gpx',
        bytes: Uint8List.fromList([1]),
      ),
    );
  }

  @override
  Future<GpxImportResult> processFile(GpxSelectedFile file) {
    return completer.future;
  }
}

void main() {
  testWidgets('processing overlay text fits without overflow', (tester) async {
    final repository = PendingGpxImportRepository();
    final viewModel = GpxImportViewModel(repository: repository);

    final app = await buildLocalizedTestApp(
      Stack(
        children: [
          const SizedBox.expand(),
          GpxImportProcessingOverlay(viewModel: viewModel),
        ],
      ),
    );
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app);
    unawaited(viewModel.importGpx());
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
