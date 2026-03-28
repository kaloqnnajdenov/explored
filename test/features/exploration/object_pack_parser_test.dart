import 'package:flutter_test/flutter_test.dart';

import 'package:explored/domain/objects/object_category.dart';
import 'package:explored/features/exploration/data/services/object_pack_parser.dart';

import '../../test_utils/exploration_test_harness.dart';

void main() {
  const parser = ObjectPackParser();

  test('parses objects ndjson correctly', () {
    final monuments = parser.parse(
      testObjectPacks['monuments.ndjson']!,
      countrySlug: testCountrySlug,
    );

    expect(monuments, hasLength(2));
    expect(monuments.first.objectId, testMonumentObjectId);
    expect(monuments.first.category, ObjectCategory.monument);
    expect(monuments.last.objectId, testMemorialObjectId);
    expect(monuments.last.subtype, 'memorial');
  });

  test('missing city_center does not crash', () {
    final peaks = parser.parse(
      testObjectPacks['peaks.ndjson']!,
      countrySlug: testCountrySlug,
    );

    expect(peaks.single.objectId, testPeakObjectId);
    expect(peaks.single.cityCenterId, isNull);
  });

  test('roads require length_m and remain length based', () {
    final roads = parser.parse(
      testObjectPacks['road_segments.ndjson']!,
      countrySlug: testCountrySlug,
    );

    expect(roads, hasLength(2));
    expect(roads.first.category, ObjectCategory.roadSegment);
    expect(roads.first.lengthM, 100.0);
    expect(roads.last.lengthM, 500.0);

    expect(
      () => parser.parse('''
{"object_id":"road_segment:bad","category":"road_segment","geometry":{"type":"LineString","coordinates":[[0,0],[1,1]]},"country_id":"country:1","length_m":null}
''', countrySlug: testCountrySlug),
      throwsFormatException,
    );
  });

  test('supports production road rows with category road and metric_value', () {
    final roads = parser.parse('''
{"object_id":"road:way:14:seg:1","category":"road","metric_type":"length_m","metric_value":100.0,"geometry":{"type":"LineString","coordinates":[[11.49,46.49],[11.51,46.51]]},"country_id":"country:relation:1","region_id":"region:relation:2","city_id":"city:relation:3","city_center_id":"city_center:way:4","drivable":false,"walkable":true,"cycleway":false}
''', countrySlug: testCountrySlug);

    expect(roads, hasLength(1));
    expect(roads.single.category, ObjectCategory.roadSegment);
    expect(roads.single.lengthM, 100.0);
    expect(roads.single.cityCenterId, testCityCenterEntityId);
  });
}
