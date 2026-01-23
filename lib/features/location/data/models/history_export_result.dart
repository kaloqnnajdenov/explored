enum HistoryExportOutcome { success, failure }

class HistoryExportResult {
  const HistoryExportResult._({
    required this.outcome,
    this.filePath,
    this.error,
  });

  const HistoryExportResult.success({required String filePath})
      : this._(outcome: HistoryExportOutcome.success, filePath: filePath);

  const HistoryExportResult.failure({Object? error})
      : this._(outcome: HistoryExportOutcome.failure, error: error);

  final HistoryExportOutcome outcome;
  final String? filePath;
  final Object? error;
}
