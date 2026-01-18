class VisitedGridConfig {
  const VisitedGridConfig({
    this.baseResolution = 12,
    this.coarserResolutions = const [11, 10, 9, 8, 7, 6],
    this.maxDailyRetentionDays = 180,
    this.cleanupIntervalSeconds = 6 * 60 * 60,
    this.maxCandidateCells = 2500,
    this.minRenderResolution = 6,
    this.maxAcceptedAccuracyMeters = 50,
  });

  /// Base resolution used for per-sample aggregation.
  final int baseResolution;

  /// Coarser resolutions used for clustering; ordered high -> low.
  final List<int> coarserResolutions;

  /// Number of daily rows to retain before cleanup.
  final int maxDailyRetentionDays;

  /// Minimum seconds between cleanup runs.
  final int cleanupIntervalSeconds;

  /// Cell count threshold to switch from per-cell to merged overlay rendering.
  final int maxCandidateCells;

  /// Lowest resolution allowed when degrading for large viewports.
  final int minRenderResolution;

  /// Accuracy gate for samples that provide accuracy (meters).
  final double maxAcceptedAccuracyMeters;

  /// Maps a map zoom level to a target H3 resolution.
  int resolutionForZoom(double zoom) {
    var resolution = baseResolution;
    if (zoom >= 16) {
      resolution = baseResolution;
    } else if (zoom >= 15) {
      resolution = baseResolution - 1;
    } else if (zoom >= 14) {
      resolution = baseResolution - 2;
    } else if (zoom >= 13) {
      resolution = baseResolution - 3;
    } else if (zoom >= 12) {
      resolution = baseResolution - 4;
    } else if (zoom >= 10.5) {
      resolution = baseResolution - 5;
    } else {
      resolution = baseResolution - 6;
    }

    if (resolution < minRenderResolution) {
      return minRenderResolution;
    }
    if (resolution > baseResolution) {
      return baseResolution;
    }
    return resolution;
  }
}
