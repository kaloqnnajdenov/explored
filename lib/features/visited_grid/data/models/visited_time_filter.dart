enum VisitedTimeFilter {
  allTime,
  today,
  last7Days,
}

extension VisitedTimeFilterX on VisitedTimeFilter {
  int? get dayWindow {
    switch (this) {
      case VisitedTimeFilter.allTime:
        return null;
      case VisitedTimeFilter.today:
        return 0;
      case VisitedTimeFilter.last7Days:
        return 6;
    }
  }
}
