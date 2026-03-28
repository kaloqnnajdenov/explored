class EntityTotals {
  const EntityTotals({
    required this.entityId,
    required this.peaksCount,
    required this.hutsCount,
    required this.monumentsCount,
    required this.roadsDrivableLengthM,
    required this.roadsWalkableLengthM,
    required this.roadsCyclewayLengthM,
  });

  static const EntityTotals empty = EntityTotals(
    entityId: '',
    peaksCount: 0,
    hutsCount: 0,
    monumentsCount: 0,
    roadsDrivableLengthM: 0,
    roadsWalkableLengthM: 0,
    roadsCyclewayLengthM: 0,
  );

  final String entityId;
  final int peaksCount;
  final int hutsCount;
  final int monumentsCount;
  final double roadsDrivableLengthM;
  final double roadsWalkableLengthM;
  final double roadsCyclewayLengthM;
}
