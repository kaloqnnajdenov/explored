import 'package:flutter_test/flutter_test.dart';

import 'package:explored/domain/entities/entity_type.dart';
import 'package:explored/features/exploration/data/services/entity_pack_parser.dart';

import '../../test_utils/exploration_test_harness.dart';

void main() {
  const parser = EntityPackParser();

  test('parses entities ndjson correctly', () {
    final rows = parser.parse(testEntitiesNdjson, countrySlug: testCountrySlug);

    expect(rows, hasLength(5));
    expect(rows.first.entityId, testCountryEntityId);
    expect(rows.first.type, EntityType.country);
    expect(rows[2].entityId, testRegionalCityEntityId);
    expect(rows[2].regionId, testRegionEntityId);
    expect(rows.last.entityId, testRegionlessCityEntityId);
    expect(rows.last.regionId, isNull);
  });

  test('cities without region do not crash', () {
    final rows = parser.parse(testEntitiesNdjson, countrySlug: testCountrySlug);

    final regionlessCity = rows.singleWhere(
      (row) => row.entityId == testRegionlessCityEntityId,
    );
    expect(regionlessCity.type, EntityType.city);
    expect(regionlessCity.regionId, isNull);
  });

  test('supports production entity rows with entity_type and parent ids', () {
    final rows = parser.parse('''
{"entity_id":"country:relation:1","entity_type":"country","name":"Testland","bbox":[10.0,45.0,14.0,48.0],"centroid":[12.0,46.5],"geometry":{"type":"Polygon","coordinates":[[[10.0,45.0],[14.0,45.0],[14.0,48.0],[10.0,48.0],[10.0,45.0]]]}}
{"entity_id":"city:relation:3","entity_type":"city","name":"Regional City","bbox":[11.0,46.0,12.0,47.0],"centroid":[11.5,46.5],"parent_country_id":"country:relation:1","parent_region_id":"region:relation:2","parent_city_id":null,"geometry":{"type":"Polygon","coordinates":[[[11.0,46.0],[12.0,46.0],[12.0,47.0],[11.0,47.0],[11.0,46.0]]]}}
''', countrySlug: testCountrySlug);

    expect(rows, hasLength(2));
    expect(rows.first.type, EntityType.country);
    expect(rows.last.type, EntityType.city);
    expect(rows.last.countryId, testCountryEntityId);
    expect(rows.last.regionId, testRegionEntityId);
    expect(rows.last.cityId, isNull);
  });

  test('rejects invalid entity types', () {
    expect(
      () => parser.parse('''
{"entity_id":"entity:1","type":"mountain_range","name":"Bad Row","bbox":[0,0,1,1],"centroid":[0.5,0.5],"geometry":{"type":"Polygon","coordinates":[[[0,0],[1,0],[1,1],[0,1],[0,0]]]}}
''', countrySlug: testCountrySlug),
      throwsArgumentError,
    );
  });
}
