class VisitedGridStats {
  const VisitedGridStats({
    required this.totalAreaM2,
    required this.cellCount,
    required this.canonicalVersion,
    this.lastUpdatedEpochSeconds,
    this.lastReconciledEpochSeconds,
  });

  factory VisitedGridStats.empty() {
    return const VisitedGridStats(
      totalAreaM2: 0,
      cellCount: 0,
      canonicalVersion: 0,
      lastUpdatedEpochSeconds: null,
      lastReconciledEpochSeconds: null,
    );
  }

  final double totalAreaM2;
  final int cellCount;
  final int canonicalVersion;
  final int? lastUpdatedEpochSeconds;
  final int? lastReconciledEpochSeconds;

  double get totalAreaKm2 => totalAreaM2 / 1000000.0;

  VisitedGridStats copyWith({
    double? totalAreaM2,
    int? cellCount,
    int? canonicalVersion,
    int? lastUpdatedEpochSeconds,
    int? lastReconciledEpochSeconds,
  }) {
    return VisitedGridStats(
      totalAreaM2: totalAreaM2 ?? this.totalAreaM2,
      cellCount: cellCount ?? this.cellCount,
      canonicalVersion: canonicalVersion ?? this.canonicalVersion,
      lastUpdatedEpochSeconds:
          lastUpdatedEpochSeconds ?? this.lastUpdatedEpochSeconds,
      lastReconciledEpochSeconds:
          lastReconciledEpochSeconds ?? this.lastReconciledEpochSeconds,
    );
  }
}
