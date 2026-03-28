class ParsedTotalsRow {
  const ParsedTotalsRow({
    required this.entityId,
    required this.peaksCount,
    required this.hutsCount,
    required this.monumentsCount,
    required this.roadsDrivableLengthM,
    required this.roadsWalkableLengthM,
    required this.roadsCyclewayLengthM,
  });

  final String entityId;
  final int peaksCount;
  final int hutsCount;
  final int monumentsCount;
  final double roadsDrivableLengthM;
  final double roadsWalkableLengthM;
  final double roadsCyclewayLengthM;
}
