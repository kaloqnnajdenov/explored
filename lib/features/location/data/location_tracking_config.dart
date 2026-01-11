/// Centralized config for background/foreground location tracking behavior.
class LocationTrackingConfig {
  const LocationTrackingConfig({
    this.updateIntervalSeconds = 5,
    this.distanceFilterMeters = 10.0,
    this.watchdogCheckMinutes = 15,
    int? noUpdateThresholdSeconds,
  }) : noUpdateThresholdSeconds = noUpdateThresholdSeconds ??
            (updateIntervalSeconds * 2 > watchdogCheckMinutes * 60
                ? updateIntervalSeconds * 2
                : watchdogCheckMinutes * 60);

  /// Minimum time between emitted samples.
  final int updateIntervalSeconds;

  /// Minimum distance change before emitting a new sample.
  final double distanceFilterMeters;

  /// Periodic interval for watchdog checks.
  final int watchdogCheckMinutes;

  /// Max time without updates before warning.
  final int noUpdateThresholdSeconds;

  Duration get updateInterval => Duration(seconds: updateIntervalSeconds);

  Duration get watchdogInterval => Duration(minutes: watchdogCheckMinutes);

  Duration get noUpdateThreshold => Duration(seconds: noUpdateThresholdSeconds);

  int get updateIntervalMilliseconds => updateIntervalSeconds * 1000;
}
