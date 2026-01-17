/// Centralized config for background/foreground location tracking behavior.
class LocationTrackingConfig {
  const LocationTrackingConfig({
    this.assumeBackground = false,
    this.updateIntervalSeconds = 1,
    this.distanceFilterMeters = 5.0,
    this.watchdogCheckMinutes = 15,
    this.speedEmaAlpha = 0.3,
    this.speedMaxMetersPerSecond = 60.0,
    double? minSpeedForIntervalMps,
    double? baseDistanceOffsetMeters,
    this.baseDistanceSpeedFactor = 1.0,
    double? baseDistanceMinMeters,
    this.baseDistanceMaxMeters = 35.0,
    this.baseIntervalMinSeconds = 1.0,
    this.baseIntervalMaxSeconds = 120.0,
    this.backgroundIntervalMultiplier = 1.25,
    this.backgroundIntervalFloorSeconds = 2.0,
    this.backgroundIntervalClampMinSeconds = 1.0,
    this.backgroundIntervalMaxSeconds = 300.0,
    this.backgroundDistanceMultiplier = 1.2,
    this.backgroundDistanceFloorMeters = 8.0,
    this.backgroundDistanceClampMinMeters = 8.0,
    this.backgroundDistanceMaxMeters = 200.0,
    this.minMovementMeters = 3.0,
    this.accuracyMovementFactor = 0.5,
    this.minMovementConfidence = 0.25,
    this.stillSpeedMaxMps = 0.6,
    this.driveSpeedMinMps = 4.0,
    this.stateConsecutiveUpdates = 3,
    this.downshiftConsecutiveUpdates = 4,
    this.downshiftCooldownSeconds = 20,
    this.unreliableAccuracyDurationSeconds = 30,
    this.poorAccuracyMeters = 50.0,
    this.unreliableMaxRawGapSeconds = 20.0,
    this.unreliableSporadicCount = 2,
    this.unreliableRecoveryConsecutiveUpdates = 3,
    this.unreliableIntervalSeconds = 8,
    this.unreliableIntervalMinSeconds = 5,
    this.unreliableIntervalMaxSeconds = 10,
    this.unreliableAccuracyFactor = 0.8,
    this.reliabilityLogCooldownSeconds = 60,
    this.turnHeadingDeltaDegrees = 20.0,
    this.turnDetectionWindowSeconds = 10,
    this.turnBoostSeconds = 15,
    this.turnBoostIntervalSeconds = 1.0,
    this.turnBoostDistanceMeters = 10.0,
    this.policyChangeDistanceEpsilonMeters = 1.0,
    this.policyChangeIntervalEpsilonSeconds = 1.0,
    this.minRawDeltaSeconds = 0.5,
    this.minBearingDistanceMeters = 5.0,
    this.invalidCoordinateLogCooldownSeconds = 60,
    this.gapFillIntervalSeconds = 15,
    double? gapFillMaxDistanceMeters,
    int? noUpdateThresholdSeconds,
  })  : baseDistanceOffsetMeters =
            baseDistanceOffsetMeters ?? distanceFilterMeters,
        baseDistanceMinMeters = baseDistanceMinMeters ?? distanceFilterMeters,
        minSpeedForIntervalMps = minSpeedForIntervalMps ?? 0.5,
        gapFillMaxDistanceMeters =
            gapFillMaxDistanceMeters ?? distanceFilterMeters * 3,
        noUpdateThresholdSeconds = noUpdateThresholdSeconds ??
            (updateIntervalSeconds * 2 > watchdogCheckMinutes * 60
                ? updateIntervalSeconds * 2
                : watchdogCheckMinutes * 60);

  /// When true, apply background bias to the adaptive policy.
  final bool assumeBackground;

  /// Android plugin update interval in seconds.
  final int updateIntervalSeconds;

  /// Raw distance filter passed to the plugin.
  final double distanceFilterMeters;

  /// Periodic interval for watchdog checks.
  final int watchdogCheckMinutes;

  /// Max time without updates before warning.
  final int noUpdateThresholdSeconds;

  /// EMA smoothing factor for speed.
  final double speedEmaAlpha;

  /// Clamp for maximum speed in m/s.
  final double speedMaxMetersPerSecond;

  /// Minimum speed used for interval calculation.
  final double minSpeedForIntervalMps;

  /// Base distance formula: offset + speed * factor.
  final double baseDistanceOffsetMeters;
  final double baseDistanceSpeedFactor;
  final double baseDistanceMinMeters;
  final double baseDistanceMaxMeters;

  /// Base interval clamp for the continuous policy.
  final double baseIntervalMinSeconds;
  final double baseIntervalMaxSeconds;

  /// Background bias multipliers and clamps.
  final double backgroundIntervalMultiplier;
  final double backgroundIntervalFloorSeconds;
  final double backgroundIntervalClampMinSeconds;
  final double backgroundIntervalMaxSeconds;
  final double backgroundDistanceMultiplier;
  final double backgroundDistanceFloorMeters;
  final double backgroundDistanceClampMinMeters;
  final double backgroundDistanceMaxMeters;

  /// Movement confidence and jitter filtering.
  final double minMovementMeters;
  final double accuracyMovementFactor;
  final double minMovementConfidence;

  /// State machine thresholds.
  final double stillSpeedMaxMps;
  final double driveSpeedMinMps;
  final int stateConsecutiveUpdates;
  final int downshiftConsecutiveUpdates;
  final int downshiftCooldownSeconds;

  /// Reliability thresholds.
  final int unreliableAccuracyDurationSeconds;
  final double poorAccuracyMeters;
  final double unreliableMaxRawGapSeconds;
  final int unreliableSporadicCount;
  final int unreliableRecoveryConsecutiveUpdates;
  final int unreliableIntervalSeconds;
  final int unreliableIntervalMinSeconds;
  final int unreliableIntervalMaxSeconds;
  final double unreliableAccuracyFactor;
  final int reliabilityLogCooldownSeconds;

  /// Turn detection and boost tuning.
  final double turnHeadingDeltaDegrees;
  final int turnDetectionWindowSeconds;
  final int turnBoostSeconds;
  final double turnBoostIntervalSeconds;
  final double turnBoostDistanceMeters;

  /// Policy logging thresholds.
  final double policyChangeDistanceEpsilonMeters;
  final double policyChangeIntervalEpsilonSeconds;

  /// Minimum raw delta used to guard derived speed.
  final double minRawDeltaSeconds;

  /// Minimum distance needed to derive a bearing.
  final double minBearingDistanceMeters;

  /// Cooldown for logging invalid coordinate messages.
  final int invalidCoordinateLogCooldownSeconds;

  /// Expected interval used for gap filling between emitted samples.
  /// Default is 15s to avoid overestimating missing points when the
  /// adaptive policy emits slower (e.g., walking/background).
  final int gapFillIntervalSeconds;

  /// Max distance (meters) between consecutive points before gap filling
  /// inserts samples, derived from the configured distance filter by default.
  final double gapFillMaxDistanceMeters;

  Duration get updateInterval => Duration(seconds: updateIntervalSeconds);

  Duration get watchdogInterval => Duration(minutes: watchdogCheckMinutes);

  Duration get noUpdateThreshold => Duration(seconds: noUpdateThresholdSeconds);

  int get updateIntervalMilliseconds => updateIntervalSeconds * 1000;

  Duration get gapFillInterval => Duration(seconds: gapFillIntervalSeconds);
}
