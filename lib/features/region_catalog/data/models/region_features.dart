class RegionFeatureProgress {
  const RegionFeatureProgress({required this.total, required this.completed});

  static const empty = RegionFeatureProgress(total: 0, completed: 0);

  final int total;
  final int completed;

  RegionFeatureProgress copyWith({int? total, int? completed}) {
    return RegionFeatureProgress(
      total: total ?? this.total,
      completed: completed ?? this.completed,
    );
  }
}

class RegionFeatures {
  const RegionFeatures({
    required this.trails,
    required this.peaks,
    required this.huts,
  });

  static const empty = RegionFeatures(
    trails: RegionFeatureProgress.empty,
    peaks: RegionFeatureProgress.empty,
    huts: RegionFeatureProgress.empty,
  );

  final RegionFeatureProgress trails;
  final RegionFeatureProgress peaks;
  final RegionFeatureProgress huts;

  RegionFeatures copyWith({
    RegionFeatureProgress? trails,
    RegionFeatureProgress? peaks,
    RegionFeatureProgress? huts,
  }) {
    return RegionFeatures(
      trails: trails ?? this.trails,
      peaks: peaks ?? this.peaks,
      huts: huts ?? this.huts,
    );
  }
}
