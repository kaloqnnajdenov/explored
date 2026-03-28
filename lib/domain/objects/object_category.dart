enum ObjectCategory {
  peak,
  hut,
  monument,
  roadSegment;

  static ObjectCategory fromRaw(String raw) {
    switch (raw) {
      case 'peak':
        return ObjectCategory.peak;
      case 'hut':
        return ObjectCategory.hut;
      case 'monument':
        return ObjectCategory.monument;
      case 'road':
      case 'road_segment':
        return ObjectCategory.roadSegment;
    }
    throw ArgumentError.value(raw, 'raw', 'Unsupported object category');
  }

  String get rawValue {
    switch (this) {
      case ObjectCategory.peak:
        return 'peak';
      case ObjectCategory.hut:
        return 'hut';
      case ObjectCategory.monument:
        return 'monument';
      case ObjectCategory.roadSegment:
        return 'road_segment';
    }
  }
}
