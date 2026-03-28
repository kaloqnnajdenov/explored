import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/exploration/data/services/totals_pack_parser.dart';

import '../../test_utils/exploration_test_harness.dart';

void main() {
  const parser = TotalsPackParser();

  test('parses totals ndjson correctly', () {
    final rows = parser.parse(testTotalsNdjson);

    expect(rows, hasLength(5));
    expect(rows.first.entityId, testCountryEntityId);
    expect(rows.first.monumentsCount, 2);
    expect(rows.first.roadsWalkableLengthM, 600.0);
    expect(rows.last.entityId, testRegionlessCityEntityId);
    expect(rows.last.peaksCount, 0);
  });

  test('rejects totals rows without entity_id', () {
    expect(() => parser.parse('{"peaks_count":1}\n'), throwsFormatException);
  });
}
