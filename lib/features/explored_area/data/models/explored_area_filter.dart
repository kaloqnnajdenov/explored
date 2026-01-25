enum ExploredAreaFilterPreset {
  allTime,
  last7Days,
  last30Days,
  thisMonth,
  custom,
}

class ExploredAreaFilter {
  const ExploredAreaFilter({
    required this.preset,
    this.customStart,
    this.customEnd,
  });

  factory ExploredAreaFilter.allTime() {
    return const ExploredAreaFilter(preset: ExploredAreaFilterPreset.allTime);
  }

  final ExploredAreaFilterPreset preset;
  final DateTime? customStart;
  final DateTime? customEnd;

  bool get hasCustomRange => customStart != null && customEnd != null;

  ExploredAreaFilter copyWith({
    ExploredAreaFilterPreset? preset,
    DateTime? customStart,
    DateTime? customEnd,
    bool clearCustom = false,
  }) {
    return ExploredAreaFilter(
      preset: preset ?? this.preset,
      customStart: clearCustom ? null : (customStart ?? this.customStart),
      customEnd: clearCustom ? null : (customEnd ?? this.customEnd),
    );
  }
}
