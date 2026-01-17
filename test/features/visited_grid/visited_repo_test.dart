import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/visited_grid/data/repositories/visited_repo.dart';

void main() {
  test('chunkBySize splits input into fixed-size chunks', () {
    final input = List.generate(10, (index) => index);
    final chunks = chunkBySize(input, 3).toList();

    expect(chunks, hasLength(4));
    expect(chunks[0], [0, 1, 2]);
    expect(chunks[1], [3, 4, 5]);
    expect(chunks[2], [6, 7, 8]);
    expect(chunks[3], [9]);
  });

  test('chunkBySize throws when size is not positive', () {
    expect(() => chunkBySize([1], 0).toList(), throwsArgumentError);
  });
}
