import 'visited_grid_stats.dart';

class VisitedGridCellUpdate {
  const VisitedGridCellUpdate({
    required this.cellId,
    required this.resolution,
    required this.deltaAreaM2,
    required this.stats,
    required this.timestamp,
  });

  final String cellId;
  final int resolution;
  final double deltaAreaM2;
  final VisitedGridStats stats;
  final DateTime timestamp;
}
