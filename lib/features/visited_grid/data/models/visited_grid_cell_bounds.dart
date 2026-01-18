class VisitedGridCellBounds {
  const VisitedGridCellBounds({
    required this.resolution,
    required this.cellId,
    required this.segment,
    required this.minLatE5,
    required this.maxLatE5,
    required this.minLonE5,
    required this.maxLonE5,
  });

  final int resolution;
  final String cellId;
  final int segment;
  final int minLatE5;
  final int maxLatE5;
  final int minLonE5;
  final int maxLonE5;
}
