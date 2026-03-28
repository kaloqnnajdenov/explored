import '../models/country_pack_descriptor.dart';
import 'bundled_pack_asset_service.dart';
import 'entity_pack_parser.dart';
import 'exploration_database.dart';
import 'object_pack_parser.dart';
import 'totals_pack_parser.dart';

class PackImportService {
  static const String roadSegmentsPackFileName = 'road_segments.ndjson';

  PackImportService({
    required BundledPackAssetService assetService,
    required ExplorationDao explorationDao,
    EntityPackParser? entityPackParser,
    ObjectPackParser? objectPackParser,
    TotalsPackParser? totalsPackParser,
  }) : _assetService = assetService,
       _explorationDao = explorationDao,
       _entityPackParser = entityPackParser ?? const EntityPackParser(),
       _objectPackParser = objectPackParser ?? const ObjectPackParser(),
       _totalsPackParser = totalsPackParser ?? const TotalsPackParser();

  final BundledPackAssetService _assetService;
  final ExplorationDao _explorationDao;
  final EntityPackParser _entityPackParser;
  final ObjectPackParser _objectPackParser;
  final TotalsPackParser _totalsPackParser;

  Future<List<CountryPackDescriptor>> listCountryPacks() {
    return _assetService.listCountryPacks();
  }

  Future<void> importCountryPack(
    String countrySlug, {
    bool includeRoadSegments = false,
  }) async {
    final descriptors = await _assetService.listCountryPacks();
    final descriptor = descriptors.firstWhere(
      (pack) => pack.countrySlug == countrySlug,
    );
    final updatedAt = DateTime.now().toUtc().millisecondsSinceEpoch;
    final entitiesRaw = await _assetService.loadEntitiesPack(countrySlug);
    final totalsRaw = await _assetService.loadTotalsPack(countrySlug);

    await _explorationDao.beginCountryPackImport();
    await _explorationDao.insertEntitiesChunked(
      _entityPackParser.parseRows(entitiesRaw, countrySlug: countrySlug),
      updatedAt: updatedAt,
    );
    for (final fileName in await _assetService.listObjectPackFiles(
      countrySlug,
    )) {
      if (!includeRoadSegments && fileName == roadSegmentsPackFileName) {
        continue;
      }
      final objectPackRaw = await _assetService.loadObjectPack(
        countrySlug,
        fileName,
      );
      await _explorationDao.insertObjectsChunked(
        _objectPackParser.parseRows(objectPackRaw, countrySlug: countrySlug),
        updatedAt: updatedAt,
      );
    }
    await _explorationDao.insertTotalsChunked(
      _totalsPackParser.parseRows(totalsRaw),
      updatedAt: updatedAt,
    );
    await _explorationDao.completeCountryPackImport(
      descriptor: descriptor,
      updatedAt: updatedAt,
    );
  }
}
