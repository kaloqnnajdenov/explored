import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/visited_grid/view_model/visited_overlay_controller.dart';

void main() {
  test('computeOverlayDiff returns added and removed ids', () {
    final diff = computeOverlayDiff({'a', 'b'}, {'b', 'c'});

    expect(diff.added, {'c'});
    expect(diff.removed, {'a'});
  });
}
