import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:explored/features/visited_grid/view_model/h3_boundary_cache.dart';

void main() {
  test('H3BoundaryCache evicts least recently used entries', () {
    final cache = H3BoundaryCache(maxEntries: 2);
    cache.put('a', [const LatLng(0, 0)]);
    cache.put('b', [const LatLng(1, 1)]);

    expect(cache.contains('a'), isTrue);
    expect(cache.contains('b'), isTrue);

    cache.get('a');
    cache.put('c', [const LatLng(2, 2)]);

    expect(cache.contains('a'), isTrue);
    expect(cache.contains('b'), isFalse);
    expect(cache.contains('c'), isTrue);
    expect(cache.length, 2);
  });
}
