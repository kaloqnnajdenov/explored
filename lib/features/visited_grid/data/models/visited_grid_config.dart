import '../../../../constants.dart';

class VisitedGridConfig {
  const VisitedGridConfig({
    this.baseResolution = kBaseH3Resolution,
    this.coarserResolutions = const [9, 8, 7, 6],
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
    const minZoom = 7.0;
    const maxZoom = 16.0;
    if (baseResolution <= minRenderResolution) {
      return baseResolution;
    }

    final clampedZoom = zoom.clamp(minZoom, maxZoom).toDouble();
    final zoomSpan = maxZoom - minZoom;
    if (zoomSpan <= 0) {
      return baseResolution;
    }

    final resSpan = baseResolution - minRenderResolution;
    final t = (clampedZoom - minZoom) / zoomSpan;
    final continuous =
        minRenderResolution + resSpan * t;
    final resolution = continuous.round();

    if (resolution < minRenderResolution) {
      return minRenderResolution;
    }
    if (resolution > baseResolution) {
      return baseResolution;
    }
    return resolution;
  }
}
