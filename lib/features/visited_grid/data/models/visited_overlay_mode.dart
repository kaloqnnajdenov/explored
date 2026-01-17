sealed class OverlayMode {
  const OverlayMode();

  factory OverlayMode.allTime() = OverlayModeAllTime;
  factory OverlayMode.dateRange({
    required int fromDay,
    required int toDay,
  }) = OverlayModeDateRange;

  Map<String, Object?> toMap();

  static OverlayMode fromMap(Map<String, Object?> map) {
    final type = map['type'];
    if (type == 'allTime') {
      return const OverlayModeAllTime();
    }
    if (type == 'dateRange') {
      return OverlayModeDateRange(
        fromDay: map['fromDay'] as int,
        toDay: map['toDay'] as int,
      );
    }
    throw ArgumentError.value(type, 'type', 'Unknown overlay mode');
  }
}

final class OverlayModeAllTime extends OverlayMode {
  const OverlayModeAllTime();

  @override
  Map<String, Object?> toMap() => const {'type': 'allTime'};

  @override
  bool operator ==(Object other) => other is OverlayModeAllTime;

  @override
  int get hashCode => 1;
}

final class OverlayModeDateRange extends OverlayMode {
  const OverlayModeDateRange({
    required this.fromDay,
    required this.toDay,
  });

  final int fromDay;
  final int toDay;

  @override
  Map<String, Object?> toMap() => {
        'type': 'dateRange',
        'fromDay': fromDay,
        'toDay': toDay,
      };

  @override
  bool operator ==(Object other) {
    return other is OverlayModeDateRange &&
        other.fromDay == fromDay &&
        other.toDay == toDay;
  }

  @override
  int get hashCode => Object.hash(fromDay, toDay);
}
