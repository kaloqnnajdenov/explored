import 'package:flutter/foundation.dart';

import '../data/repositories/gpx_import_repository.dart';

class GpxImportFeedback {
  const GpxImportFeedback({
    required this.id,
    required this.messageKey,
    this.namedArgs,
    this.isError = false,
  });

  final int id;
  final String messageKey;
  final Map<String, String>? namedArgs;
  final bool isError;
}

class GpxImportState {
  const GpxImportState({
    required this.isProcessing,
    required this.statusKey,
    this.progress,
    this.feedback,
  });

  factory GpxImportState.initial() {
    return const GpxImportState(
      isProcessing: false,
      statusKey: 'gpx_import_processing',
    );
  }

  final bool isProcessing;
  final double? progress;
  final String statusKey;
  final GpxImportFeedback? feedback;

  GpxImportState copyWith({
    bool? isProcessing,
    double? progress,
    String? statusKey,
    GpxImportFeedback? feedback,
    bool clearFeedback = false,
  }) {
    return GpxImportState(
      isProcessing: isProcessing ?? this.isProcessing,
      progress: progress ?? this.progress,
      statusKey: statusKey ?? this.statusKey,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
    );
  }
}

class GpxImportViewModel extends ChangeNotifier {
  GpxImportViewModel({required GpxImportRepository repository})
      : _repository = repository,
        _state = GpxImportState.initial();

  final GpxImportRepository _repository;

  GpxImportState _state;
  int _feedbackId = 0;

  GpxImportState get state => _state;

  Future<void> importGpx() async {
    if (_state.isProcessing) {
      return;
    }

    final preparation = await _repository.prepareImport();
    if (preparation.outcome == GpxImportOutcome.cancelled) {
      return;
    }
    if (preparation.outcome == GpxImportOutcome.failure) {
      _emitFeedback(
        preparation.messageKey ?? 'gpx_import_invalid_file',
        isError: true,
      );
      return;
    }

    final file = preparation.file;
    if (file == null) {
      _emitFeedback('gpx_import_invalid_file', isError: true);
      return;
    }

    _state = _state.copyWith(
      isProcessing: true,
      progress: null,
      statusKey: 'gpx_import_processing',
      clearFeedback: true,
    );
    notifyListeners();

    final result = await _repository.processFile(file);

    _state = _state.copyWith(isProcessing: false, progress: null);
    if (result.outcome == GpxImportOutcome.success) {
      _emitFeedback(
        result.messageKey ?? 'gpx_import_success',
        namedArgs: result.namedArgs,
      );
    } else if (result.outcome == GpxImportOutcome.failure) {
      _emitFeedback(
        result.messageKey ?? 'gpx_import_invalid_file',
        isError: true,
      );
    }
    notifyListeners();
  }

  void _emitFeedback(
    String messageKey, {
    Map<String, String>? namedArgs,
    bool isError = false,
  }) {
    _feedbackId += 1;
    _state = _state.copyWith(
      feedback: GpxImportFeedback(
        id: _feedbackId,
        messageKey: messageKey,
        namedArgs: namedArgs,
        isError: isError,
      ),
    );
    notifyListeners();
  }
}
