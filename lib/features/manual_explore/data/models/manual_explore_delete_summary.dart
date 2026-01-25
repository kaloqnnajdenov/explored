class ManualExploreDeleteSummary {
  const ManualExploreDeleteSummary({
    required this.cellCount,
    required this.sampleCount,
  });

  final int cellCount;
  final int sampleCount;

  bool get hasDeletes => cellCount > 0;
}
