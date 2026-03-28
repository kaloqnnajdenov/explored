import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:explored/domain/entities/entity_type.dart';
import 'package:explored/features/exploration/data/models/country_pack_descriptor.dart';
import 'package:explored/features/exploration/data/repositories/entity_repository.dart';
import 'package:explored/features/exploration/data/repositories/object_repository.dart';
import 'package:explored/features/exploration/data/repositories/pack_management_repository.dart';
import 'package:explored/features/exploration/data/repositories/progress_repository.dart';
import 'package:explored/features/exploration/data/repositories/selection_repository.dart';
import 'package:explored/features/exploration/data/repositories/totals_repository.dart';
import 'package:explored/features/exploration/data/services/bundled_pack_asset_service.dart';
import 'package:explored/features/exploration/data/services/entity_pack_parser.dart';
import 'package:explored/features/exploration/data/services/exploration_database.dart';
import 'package:explored/features/exploration/data/services/legacy_selection_service.dart';
import 'package:explored/features/exploration/data/services/local_user_prefs_service.dart';
import 'package:explored/features/exploration/data/services/pack_import_service.dart';
import 'package:explored/features/pack_management/view_model/pack_management_view_model.dart';

const String testCountrySlug = 'testland';
const String testCountryEntityId = 'country:relation:1';
const String testRegionEntityId = 'region:relation:2';
const String testRegionalCityEntityId = 'city:relation:3';
const String testCityCenterEntityId = 'city_center:way:4';
const String testRegionlessCityEntityId = 'city:relation:5';
const String testPeakObjectId = 'peak:node:10';
const String testHutObjectId = 'hut:way:11';
const String testMonumentObjectId = 'monument:way:12';
const String testMemorialObjectId = 'memorial:way:13';
const String testCenterRoadObjectId = 'road_segment:way:14';
const String testRegionalRoadObjectId = 'road_segment:way:15';

const String testEntitiesNdjson = '''
{"entity_id":"country:relation:1","type":"country","osm_type":"relation","osm_id":1,"area_id":"1001","name":"Testland","admin_level":2,"bbox":[10.0,45.0,14.0,48.0],"centroid":[12.0,46.5],"country_id":null,"region_id":null,"city_id":null,"geometry":{"type":"Polygon","coordinates":[[[10.0,45.0],[14.0,45.0],[14.0,48.0],[10.0,48.0],[10.0,45.0]]]},"country_slug":"testland","pack_version":"2026.03.21"}
{"entity_id":"region:relation:2","type":"region","osm_type":"relation","osm_id":2,"area_id":"1002","name":"Alpine Region","admin_level":4,"bbox":[10.5,45.5,13.5,47.5],"centroid":[12.0,46.5],"country_id":"country:relation:1","region_id":null,"city_id":null,"geometry":{"type":"Polygon","coordinates":[[[10.5,45.5],[13.5,45.5],[13.5,47.5],[10.5,47.5],[10.5,45.5]]]},"country_slug":"testland","pack_version":"2026.03.21"}
{"entity_id":"city:relation:3","type":"city","osm_type":"relation","osm_id":3,"area_id":"1003","name":"Regional City","admin_level":6,"bbox":[11.0,46.0,12.0,47.0],"centroid":[11.5,46.5],"country_id":"country:relation:1","region_id":"region:relation:2","city_id":null,"geometry":{"type":"Polygon","coordinates":[[[11.0,46.0],[12.0,46.0],[12.0,47.0],[11.0,47.0],[11.0,46.0]]]},"country_slug":"testland","pack_version":"2026.03.21"}
{"entity_id":"city_center:way:4","type":"city_center","osm_type":"way","osm_id":4,"area_id":null,"name":"Downtown","admin_level":null,"bbox":[11.3,46.3,11.7,46.7],"centroid":[11.5,46.5],"country_id":"country:relation:1","region_id":"region:relation:2","city_id":"city:relation:3","geometry":{"type":"Polygon","coordinates":[[[11.3,46.3],[11.7,46.3],[11.7,46.7],[11.3,46.7],[11.3,46.3]]]},"country_slug":"testland","pack_version":"2026.03.21"}
{"entity_id":"city:relation:5","type":"city","osm_type":"relation","osm_id":5,"area_id":"1005","name":"Coastal City","admin_level":6,"bbox":[12.5,45.4,13.2,46.1],"centroid":[12.85,45.75],"country_id":"country:relation:1","region_id":null,"city_id":null,"geometry":{"type":"Polygon","coordinates":[[[12.5,45.4],[13.2,45.4],[13.2,46.1],[12.5,46.1],[12.5,45.4]]]},"country_slug":"testland","pack_version":"2026.03.21"}
''';

const Map<String, String> testObjectPacks = {
  'peaks.ndjson':
      '{"object_id":"peak:node:10","category":"peak","name":"Summit Peak","geometry":{"type":"Point","coordinates":[11.55,46.8]},"country_id":"country:relation:1","region_id":"region:relation:2","city_id":"city:relation:3","city_center_id":null,"country_slug":"testland"}\n',
  'huts.ndjson':
      '{"object_id":"hut:way:11","category":"hut","name":"Ridge Hut","geometry":{"type":"Point","coordinates":[11.56,46.79]},"country_id":"country:relation:1","region_id":"region:relation:2","city_id":"city:relation:3","city_center_id":null,"country_slug":"testland"}\n',
  'monuments.ndjson':
      '{"object_id":"monument:way:12","category":"monument","subtype":"monument","name":"Clock Tower","geometry":{"type":"Point","coordinates":[11.52,46.52]},"country_id":"country:relation:1","region_id":"region:relation:2","city_id":"city:relation:3","city_center_id":"city_center:way:4","country_slug":"testland"}\n'
      '{"object_id":"memorial:way:13","category":"monument","subtype":"memorial","name":"River Memorial","geometry":{"type":"Point","coordinates":[11.53,46.53]},"country_id":"country:relation:1","region_id":"region:relation:2","city_id":"city:relation:3","city_center_id":"city_center:way:4","country_slug":"testland"}\n',
  'road_segments.ndjson':
      '{"object_id":"road_segment:way:14","category":"road_segment","name":"Old Town Lane","geometry":{"type":"LineString","coordinates":[[11.49,46.49],[11.51,46.51]]},"country_id":"country:relation:1","region_id":"region:relation:2","city_id":"city:relation:3","city_center_id":"city_center:way:4","drivable":false,"walkable":true,"cycleway":false,"length_m":100.0,"country_slug":"testland"}\n'
      '{"object_id":"road_segment:way:15","category":"road_segment","name":"Ring Road","geometry":{"type":"LineString","coordinates":[[11.2,46.2],[11.8,46.8]]},"country_id":"country:relation:1","region_id":"region:relation:2","city_id":"city:relation:3","city_center_id":null,"drivable":true,"walkable":true,"cycleway":true,"length_m":500.0,"country_slug":"testland"}\n',
};

const String testTotalsNdjson = '''
{"entity_id":"country:relation:1","peaks_count":1,"huts_count":1,"monuments_count":2,"roads_drivable_length_m":500.0,"roads_walkable_length_m":600.0,"roads_cycleway_length_m":500.0}
{"entity_id":"region:relation:2","peaks_count":1,"huts_count":1,"monuments_count":2,"roads_drivable_length_m":500.0,"roads_walkable_length_m":600.0,"roads_cycleway_length_m":500.0}
{"entity_id":"city:relation:3","peaks_count":1,"huts_count":1,"monuments_count":2,"roads_drivable_length_m":500.0,"roads_walkable_length_m":600.0,"roads_cycleway_length_m":500.0}
{"entity_id":"city_center:way:4","peaks_count":0,"huts_count":0,"monuments_count":2,"roads_drivable_length_m":0.0,"roads_walkable_length_m":100.0,"roads_cycleway_length_m":0.0}
{"entity_id":"city:relation:5","peaks_count":0,"huts_count":0,"monuments_count":0,"roads_drivable_length_m":0.0,"roads_walkable_length_m":0.0,"roads_cycleway_length_m":0.0}
''';

class TestPackFixture {
  const TestPackFixture({
    required this.countrySlug,
    required this.entitiesNdjson,
    required this.objectPacks,
    required this.totalsNdjson,
  });

  final String countrySlug;
  final String entitiesNdjson;
  final Map<String, String> objectPacks;
  final String totalsNdjson;
}

class FakeBundledPackAssetService implements BundledPackAssetService {
  FakeBundledPackAssetService({
    required Map<String, TestPackFixture> packs,
    EntityPackParser? entityPackParser,
  }) : _packs = packs,
       _entityPackParser = entityPackParser ?? const EntityPackParser();

  final Map<String, TestPackFixture> _packs;
  final EntityPackParser _entityPackParser;

  @override
  Future<List<CountryPackDescriptor>> listCountryPacks() async {
    final descriptors = <CountryPackDescriptor>[];
    for (final fixture in _packs.values) {
      final entities = _entityPackParser.parse(
        fixture.entitiesNdjson,
        countrySlug: fixture.countrySlug,
      );
      final country = entities.firstWhere(
        (entity) => entity.type == EntityType.country,
      );
      descriptors.add(
        CountryPackDescriptor(
          countrySlug: fixture.countrySlug,
          countryEntityId: country.entityId,
          countryName: country.name,
          packVersion: country.packVersion,
          bbox: country.bbox,
          centroid: country.centroid,
        ),
      );
    }
    descriptors.sort(
      (left, right) => left.countryName.toLowerCase().compareTo(
        right.countryName.toLowerCase(),
      ),
    );
    return descriptors;
  }

  @override
  Future<String> loadEntitiesPack(String countrySlug) async {
    return _fixture(countrySlug).entitiesNdjson;
  }

  @override
  Future<Map<String, String>> loadObjectPacks(String countrySlug) async {
    return _fixture(countrySlug).objectPacks;
  }

  @override
  Future<List<String>> listObjectPackFiles(String countrySlug) async {
    final fileNames = _fixture(countrySlug).objectPacks.keys.toList();
    fileNames.sort();
    return fileNames;
  }

  @override
  Future<String> loadObjectPack(String countrySlug, String fileName) async {
    final objectPack = _fixture(countrySlug).objectPacks[fileName];
    if (objectPack == null) {
      throw StateError('Unknown object pack $fileName for $countrySlug');
    }
    return objectPack;
  }

  @override
  Future<String> loadTotalsPack(String countrySlug) async {
    return _fixture(countrySlug).totalsNdjson;
  }

  TestPackFixture _fixture(String countrySlug) {
    final fixture = _packs[countrySlug];
    if (fixture == null) {
      throw StateError('Unknown country pack: $countrySlug');
    }
    return fixture;
  }
}

class ExplorationTestHarness {
  ExplorationTestHarness({
    required this.database,
    required this.packImportService,
    required this.entityRepository,
    required this.objectRepository,
    required this.totalsRepository,
    required this.selectionRepository,
    required this.progressRepository,
    required this.packManagementRepository,
    required this.localUserPrefsService,
    required this.legacySelectionService,
  });

  final ExplorationDatabase database;
  final PackImportService packImportService;
  final EntityRepository entityRepository;
  final ObjectRepository objectRepository;
  final TotalsRepository totalsRepository;
  final SelectionRepository selectionRepository;
  final ProgressRepository progressRepository;
  final PackManagementRepository packManagementRepository;
  final LocalUserPrefsService localUserPrefsService;
  final LegacySelectionService legacySelectionService;

  Future<void> importCountryPack({
    String countrySlug = testCountrySlug,
    bool includeRoadSegments = true,
  }) {
    return packImportService.importCountryPack(
      countrySlug,
      includeRoadSegments: includeRoadSegments,
    );
  }

  PackManagementViewModel createPackManagementViewModel() {
    return PackManagementViewModel(
      repository: packManagementRepository,
      entityRepository: entityRepository,
      selectionRepository: selectionRepository,
      legacySelectionService: legacySelectionService,
    );
  }

  Future<void> dispose() {
    return database.close();
  }
}

Future<ExplorationTestHarness> buildExplorationTestHarness({
  Map<String, Object> initialPreferences = const <String, Object>{},
  Map<String, TestPackFixture> packs = const <String, TestPackFixture>{
    testCountrySlug: TestPackFixture(
      countrySlug: testCountrySlug,
      entitiesNdjson: testEntitiesNdjson,
      objectPacks: testObjectPacks,
      totalsNdjson: testTotalsNdjson,
    ),
  },
}) async {
  SharedPreferences.setMockInitialValues(initialPreferences);
  final preferences = await SharedPreferences.getInstance();
  final database = ExplorationDatabase(executor: NativeDatabase.memory());
  final packImportService = PackImportService(
    assetService: FakeBundledPackAssetService(packs: packs),
    explorationDao: database.explorationDao,
  );
  final entityRepository = DefaultEntityRepository(
    packImportService: packImportService,
    explorationDao: database.explorationDao,
  );
  final localUserPrefsService = LocalUserPrefsService(preferences: preferences);
  final objectRepository = DefaultObjectRepository(
    entityRepository: entityRepository,
    explorationDao: database.explorationDao,
  );
  final totalsRepository = DefaultTotalsRepository(
    explorationDao: database.explorationDao,
  );
  final selectionRepository = DefaultSelectionRepository(
    explorationDao: database.explorationDao,
    entityRepository: entityRepository,
    localUserPrefsService: localUserPrefsService,
  );
  final progressRepository = DefaultProgressRepository(
    entityRepository: entityRepository,
    totalsRepository: totalsRepository,
    explorationDao: database.explorationDao,
    localUserPrefsService: localUserPrefsService,
  );
  final legacySelectionService = LegacySelectionService(
    preferences: preferences,
  );
  final packManagementRepository = DefaultPackManagementRepository(
    packImportService: packImportService,
    explorationDao: database.explorationDao,
    legacySelectionService: legacySelectionService,
    localUserPrefsService: localUserPrefsService,
  );

  return ExplorationTestHarness(
    database: database,
    packImportService: packImportService,
    entityRepository: entityRepository,
    objectRepository: objectRepository,
    totalsRepository: totalsRepository,
    selectionRepository: selectionRepository,
    progressRepository: progressRepository,
    packManagementRepository: packManagementRepository,
    localUserPrefsService: localUserPrefsService,
    legacySelectionService: legacySelectionService,
  );
}
