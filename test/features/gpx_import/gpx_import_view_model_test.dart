import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/gpx_import/data/repositories/gpx_import_repository.dart';
import 'package:explored/features/gpx_import/data/services/gpx_file_picker_service.dart';
import 'package:explored/features/gpx_import/view_model/gpx_import_view_model.dart';

class FakeGpxImportRepository implements GpxImportRepository {
  FakeGpxImportRepository({
    required this.preparation,
    required this.result,
  });

  GpxImportPreparation preparation;
  GpxImportResult result;
  int prepareCalls = 0;
  int processCalls = 0;

  @override
  Future<GpxImportPreparation> prepareImport() async {
    prepareCalls += 1;
    return preparation;
  }

  @override
  Future<GpxImportResult> processFile(GpxSelectedFile file) async {
    processCalls += 1;
    return result;
  }
}

void main() {
  test('emits error feedback when preparation fails', () async {
    final repository = FakeGpxImportRepository(
      preparation: const GpxImportPreparation(
        outcome: GpxImportOutcome.failure,
        messageKey: 'gpx_import_permission_denied',
      ),
      result: const GpxImportResult(outcome: GpxImportOutcome.failure),
    );
    final viewModel = GpxImportViewModel(repository: repository);

    await viewModel.importGpx();

    final feedback = viewModel.state.feedback;
    expect(feedback, isNotNull);
    expect(feedback!.messageKey, 'gpx_import_permission_denied');
    expect(feedback.isError, isTrue);
  });

  test('processFile runs when preparation succeeds', () async {
    final repository = FakeGpxImportRepository(
      preparation: GpxImportPreparation(
        outcome: GpxImportOutcome.success,
        file: GpxSelectedFile(
          name: 'track.gpx',
          bytes: Uint8List.fromList([1]),
        ),
      ),
      result: const GpxImportResult(
        outcome: GpxImportOutcome.success,
        messageKey: 'gpx_import_success',
        addedSamples: 2,
        namedArgs: {'count': '2'},
      ),
    );
    final viewModel = GpxImportViewModel(repository: repository);

    await viewModel.importGpx();

    expect(repository.prepareCalls, 1);
    expect(repository.processCalls, 1);
    expect(viewModel.state.isProcessing, isFalse);
    expect(viewModel.state.feedback?.messageKey, 'gpx_import_success');
  });
}
