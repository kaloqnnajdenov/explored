class VisitedGridBounds {
  const VisitedGridBounds({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  });

  final double north;
  final double south;
  final double east;
  final double west;

  double get latitudeSpan => north - south;
  double get longitudeSpan => east - west;

  double get centerLat => (north + south) / 2;
  double get centerLon => (east + west) / 2;
}
