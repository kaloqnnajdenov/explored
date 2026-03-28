import 'package:flutter_test/flutter_test.dart';

import 'package:explored/domain/objects/object_category.dart';
import 'package:explored/domain/objects/road_metric.dart';
import 'package:explored/features/exploration/data/services/legacy_selection_service.dart';

import '../../test_utils/exploration_test_harness.dart';

const String _productionFormatEntitiesNdjson = '''
{"entity_id":"country:relation:1","entity_type":"country","osm_type":"relation","osm_id":1,"area_id":"1001","name":"Testland","admin_level":2,"bbox":[10.0,45.0,14.0,48.0],"centroid":[12.0,46.5],"parent_country_id":null,"parent_region_id":null,"parent_city_id":null,"geometry":{"type":"Polygon","coordinates":[[[10.0,45.0],[14.0,45.0],[14.0,48.0],[10.0,48.0],[10.0,45.0]]]},"country_slug":"testland"}
{"entity_id":"region:relation:2","entity_type":"region","osm_type":"relation","osm_id":2,"area_id":"1002","name":"Alpine Region","admin_level":4,"bbox":[10.5,45.5,13.5,47.5],"centroid":[12.0,46.5],"parent_country_id":"country:relation:1","parent_region_id":null,"parent_city_id":null,"geometry":{"type":"Polygon","coordinates":[[[10.5,45.5],[13.5,45.5],[13.5,47.5],[10.5,47.5],[10.5,45.5]]]},"country_slug":"testland"}
''';

const Map<String, String> _productionFormatObjectPacks = {
  'road_segments.ndjson':
      '{"object_id":"road:way:14:seg:1","category":"road","metric_type":"length_m","metric_value":100.0,"geometry":{"type":"LineString","coordinates":[[11.49,46.49],[11.51,46.51]]},"country_id":"country:relation:1","region_id":"region:relation:2","city_id":null,"city_center_id":null,"drivable":false,"walkable":true,"cycleway":false,"country_slug":"testland"}\n',
};

void main() {
  group('exploration repositories', () {
    test(
      'bootstrap imports bundled country packs and seeds selection',
      () async {
        final harness = await buildExplorationTestHarness();
        addTearDown(harness.dispose);

        await harness.packManagementRepository.bootstrapBundledCountryPacks();

        final countries = await harness.entityRepository.getCountries();
        final selectedId = await harness.selectionRepository
            .getSelectedEntityId();

        expect(countries, hasLength(1));
        expect(countries.single.entityId, testCountryEntityId);
        expect(selectedId, testCountryEntityId);
      },
    );

    test(
      'bootstrap skips road segments while still loading point objects',
      () async {
        final harness = await buildExplorationTestHarness();
        addTearDown(harness.dispose);

        await harness.packManagementRepository.bootstrapBundledCountryPacks();

        final peaks = await harness.objectRepository.getObjectsForEntity(
          testRegionalCityEntityId,
          category: ObjectCategory.peak,
        );
        final roads = await harness.objectRepository.getRoadsForEntity(
          testRegionalCityEntityId,
        );

        expect(peaks, isNotEmpty);
        expect(roads, isEmpty);
      },
    );

    test('import country pack is idempotent and updates pack state', () async {
      final harness = await buildExplorationTestHarness();
      addTearDown(harness.dispose);

      await harness.importCountryPack();
      await harness.importCountryPack();

      final countries = await harness.entityRepository.getCountries();
      final packs = await harness.packManagementRepository.getCountryPacks();

      expect(countries, hasLength(1));
      expect(countries.single.entityId, testCountryEntityId);
      expect(packs, hasLength(1));
      expect(packs.single.imported, isTrue);
    });

    test(
      'country metadata is discoverable before importing the pack',
      () async {
        final harness = await buildExplorationTestHarness();
        addTearDown(harness.dispose);

        final countries = await harness.entityRepository.getCountries();
        final countryBeforeImport = await harness.database.explorationDao
            .fetchEntity(testCountryEntityId);
        final regions = await harness.entityRepository.getRegions(
          testCountryEntityId,
        );

        expect(countries, hasLength(1));
        expect(countries.single.name, 'Testland');
        expect(countryBeforeImport, isNull);
        expect(regions.map((entity) => entity.entityId).toList(), <String>[
          testRegionEntityId,
        ]);
      },
    );

    test(
      'child loading supports country, region, city, and empty city center cases',
      () async {
        final harness = await buildExplorationTestHarness();
        addTearDown(harness.dispose);

        await harness.importCountryPack();

        final countryChildren = await harness.entityRepository.getChildren(
          testCountryEntityId,
        );
        final allCities = await harness.entityRepository.getCities(
          countryEntityId: testCountryEntityId,
        );
        final regionChildren = await harness.entityRepository.getChildren(
          testRegionEntityId,
        );
        final cityChildren = await harness.entityRepository.getChildren(
          testRegionalCityEntityId,
        );
        final regionlessCityChildren = await harness.entityRepository
            .getChildren(testRegionlessCityEntityId);

        expect(
          countryChildren.map((entity) => entity.entityId).toList(),
          <String>[testRegionEntityId, testRegionlessCityEntityId],
        );
        expect(allCities.map((entity) => entity.entityId).toSet(), <String>{
          testRegionalCityEntityId,
          testRegionlessCityEntityId,
        });
        expect(
          regionChildren.map((entity) => entity.entityId).toList(),
          <String>[testRegionalCityEntityId],
        );
        expect(cityChildren.map((entity) => entity.entityId).toList(), <String>[
          testCityCenterEntityId,
        ]);
        expect(regionlessCityChildren, isEmpty);
      },
    );

    test(
      'imports production-format bundled packs without falling into empty data',
      () async {
        final harness = await buildExplorationTestHarness(
          packs: const <String, TestPackFixture>{
            testCountrySlug: TestPackFixture(
              countrySlug: testCountrySlug,
              entitiesNdjson: _productionFormatEntitiesNdjson,
              objectPacks: _productionFormatObjectPacks,
              totalsNdjson: testTotalsNdjson,
            ),
          },
        );
        addTearDown(harness.dispose);

        final countries = await harness.entityRepository.getCountries();
        expect(countries.single.entityId, testCountryEntityId);

        await harness.selectionRepository.setSelectedEntityId(
          testCountryEntityId,
        );
        final selected = await harness.selectionRepository
            .getSelectedEntityResolved();
        final progress = await harness.progressRepository.getEntityProgress(
          testCountryEntityId,
        );

        expect(selected?.entityId, testCountryEntityId);
        expect(progress.entity.entityId, testCountryEntityId);
      },
    );

    test('stores and restores selected entity by entity_id', () async {
      final harness = await buildExplorationTestHarness();
      addTearDown(harness.dispose);

      await harness.importCountryPack();
      await harness.selectionRepository.setSelectedEntityId(
        testRegionlessCityEntityId,
      );

      final selectedId = await harness.selectionRepository
          .getSelectedEntityId();
      final selected = await harness.selectionRepository
          .getSelectedEntityResolved();

      expect(selectedId, testRegionlessCityEntityId);
      expect(selected?.name, 'Coastal City');
    });

    test('monuments and memorials both count as monuments', () async {
      final harness = await buildExplorationTestHarness();
      addTearDown(harness.dispose);

      await harness.importCountryPack();

      final monumentCount = await harness.objectRepository
          .countObjectsForEntity(
            testCityCenterEntityId,
            ObjectCategory.monument,
          );
      final totals = await harness.totalsRepository.getTotals(
        testCityCenterEntityId,
      );

      expect(monumentCount, 2);
      expect(totals?.monumentsCount, 2);
    });

    test('road totals are length based', () async {
      final harness = await buildExplorationTestHarness();
      addTearDown(harness.dispose);

      await harness.importCountryPack();

      final drivable = await harness.objectRepository.sumRoadLengthForEntity(
        testRegionalCityEntityId,
        RoadMetric.drivable,
      );
      final walkable = await harness.objectRepository.sumRoadLengthForEntity(
        testRegionalCityEntityId,
        RoadMetric.walkable,
      );
      final cycleway = await harness.objectRepository.sumRoadLengthForEntity(
        testRegionalCityEntityId,
        RoadMetric.cycleway,
      );

      expect(drivable, 500.0);
      expect(walkable, 600.0);
      expect(cycleway, 500.0);
    });

    test('progress cache recomputes for affected parent entities', () async {
      final harness = await buildExplorationTestHarness();
      addTearDown(harness.dispose);

      await harness.importCountryPack();
      await harness.progressRepository.recordObjectExplored(
        testMemorialObjectId,
        sourceType: 'gps',
      );
      await harness.progressRepository.recordRoadCoverage(
        testRegionalRoadObjectId,
        coveredLengthM: 300,
        coverageRatio: 0.6,
        sourceType: 'gps',
      );
      await harness.progressRepository.recordRoadCoverage(
        testCenterRoadObjectId,
        coveredLengthM: 80,
        coverageRatio: 0.8,
        sourceType: 'gps',
      );

      final countryProgress = await harness.progressRepository
          .getEntityProgress(testCountryEntityId);
      final cityCenterProgress = await harness.progressRepository
          .getEntityProgress(testCityCenterEntityId);

      expect(countryProgress.monuments.explored, 1);
      expect(countryProgress.roadsDrivable.exploredLengthM, 300.0);
      expect(countryProgress.roadsWalkable.exploredLengthM, 380.0);
      expect(countryProgress.roadsCycleway.exploredLengthM, 300.0);
      expect(cityCenterProgress.monuments.explored, 1);
      expect(cityCenterProgress.roadsWalkable.exploredLengthM, 80.0);
      expect(cityCenterProgress.roadsDrivable.exploredLengthM, 0.0);
    });
  });

  group('legacy selection migration', () {
    test('migrates deterministic legacy selected entity ids', () async {
      final harness = await buildExplorationTestHarness(
        initialPreferences: <String, Object>{
          LegacySelectionService.selectedPackIdKey: testRegionalCityEntityId,
        },
      );
      addTearDown(harness.dispose);

      await harness.packManagementRepository.bootstrapBundledCountryPacks();

      final selectedId = await harness.selectionRepository
          .getSelectedEntityId();
      expect(selectedId, testRegionalCityEntityId);
    });

    test(
      'falls back to the imported country when legacy mapping is impossible',
      () async {
        final harness = await buildExplorationTestHarness(
          initialPreferences: <String, Object>{
            LegacySelectionService.selectedPackRefKey:
                '{"id":"missing:entity"}',
          },
        );
        addTearDown(harness.dispose);

        await harness.packManagementRepository.bootstrapBundledCountryPacks();

        final selectedId = await harness.selectionRepository
            .getSelectedEntityId();
        expect(selectedId, testCountryEntityId);
      },
    );
  });
}
