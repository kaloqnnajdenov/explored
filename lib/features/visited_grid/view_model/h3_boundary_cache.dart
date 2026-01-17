import 'dart:collection';

import 'package:latlong2/latlong.dart';

class H3BoundaryCache {
  H3BoundaryCache({this.maxEntries = 10000});

  final int maxEntries;
  final LinkedHashMap<String, List<LatLng>> _cache = LinkedHashMap();

  List<LatLng>? get(String cellId) {
    final value = _cache.remove(cellId);
    if (value == null) {
      return null;
    }
    _cache[cellId] = value;
    return value;
  }

  void put(String cellId, List<LatLng> boundary) {
    if (maxEntries <= 0) {
      return;
    }
    _cache.remove(cellId);
    _cache[cellId] = boundary;
    _evictIfNeeded();
  }

  bool contains(String cellId) => _cache.containsKey(cellId);

  int get length => _cache.length;

  void clear() => _cache.clear();

  void _evictIfNeeded() {
    while (_cache.length > maxEntries) {
      _cache.remove(_cache.keys.first);
    }
  }
}
