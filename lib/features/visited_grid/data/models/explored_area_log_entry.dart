class ExploredAreaLogEntry {
  const ExploredAreaLogEntry({
    required this.event,
    required this.timestamp,
    required this.totalAreaM2,
    required this.totalAreaKm2,
    required this.cellCount,
    required this.canonicalVersion,
    required this.schemaVersion,
    required this.appVersion,
    this.deltaAreaM2,
    this.cellId,
  });

  final String event;
  final DateTime timestamp;
  final double totalAreaM2;
  final double totalAreaKm2;
  final int cellCount;
  final int canonicalVersion;
  final int schemaVersion;
  final String appVersion;
  final double? deltaAreaM2;
  final String? cellId;

  Map<String, Object?> toFields() {
    return {
      'event': event,
      'timestamp': timestamp.toIso8601String(),
      'total_area_m2': totalAreaM2,
      'total_area_km2': totalAreaKm2,
      'delta_area_m2': deltaAreaM2,
      'cell_count': cellCount,
      'canonical_version': canonicalVersion,
      'schema_version': schemaVersion,
      'app_version': appVersion,
      'cell_id': cellId,
    };
  }
}
