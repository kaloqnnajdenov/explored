import '../../../../domain/entities/entity.dart';
import '../../../../domain/entities/entity_type.dart';
import '../../../../domain/shared/geo_bounds.dart';
import '../models/country_pack_descriptor.dart';
import '../services/exploration_database.dart';
import '../services/pack_import_service.dart';

abstract class EntityRepository {
  Future<void> importCountryPack(String countrySlug);

  Future<List<Entity>> getCountries();

  Future<List<Entity>> getRegions(String countryEntityId);

  Future<List<Entity>> getCities({
    required String countryEntityId,
    String? regionEntityId,
  });

  Future<List<Entity>> getCityCenters(String cityEntityId);

  Future<Entity?> getEntity(String entityId);

  Future<List<Entity>> getChildren(String entityId);

  Future<List<Entity>> searchEntities(
    String query, {
    String? countryId,
    String? type,
  });
}

class DefaultEntityRepository implements EntityRepository {
  DefaultEntityRepository({
    required PackImportService packImportService,
    required ExplorationDao explorationDao,
  }) : _packImportService = packImportService,
       _explorationDao = explorationDao;

  static const String _emptyGeometryGeoJson =
      '{"type":"FeatureCollection","features":[]}';

  final PackImportService _packImportService;
  final ExplorationDao _explorationDao;

  @override
  Future<void> importCountryPack(String countrySlug) {
    return _packImportService.importCountryPack(countrySlug);
  }

  @override
  Future<List<Entity>> getCountries() async {
    final importedCountries = await _explorationDao.fetchCountries();
    final importedById = <String, Entity>{
      for (final country in importedCountries) country.entityId: country,
    };
    final seenIds = <String>{};
    final countries = <Entity>[];

    for (final descriptor in await _packImportService.listCountryPacks()) {
      seenIds.add(descriptor.countryEntityId);
      countries.add(
        importedById[descriptor.countryEntityId] ??
            _placeholderCountryEntity(descriptor),
      );
    }

    for (final country in importedCountries) {
      if (seenIds.add(country.entityId)) {
        countries.add(country);
      }
    }

    return countries;
  }

  @override
  Future<List<Entity>> getRegions(String countryEntityId) async {
    await _ensureCountryImported(countryEntityId);
    return _explorationDao.fetchRegions(countryEntityId);
  }

  @override
  Future<List<Entity>> getCities({
    required String countryEntityId,
    String? regionEntityId,
  }) async {
    await _ensureCountryImported(countryEntityId);
    return _explorationDao.fetchCities(
      countryEntityId: countryEntityId,
      regionEntityId: regionEntityId,
    );
  }

  @override
  Future<List<Entity>> getCityCenters(String cityEntityId) {
    return _explorationDao.fetchCityCenters(cityEntityId);
  }

  @override
  Future<Entity?> getEntity(String entityId) async {
    final existing = await _explorationDao.fetchEntity(entityId);
    if (existing != null) {
      return existing;
    }

    final descriptor = await _findDescriptorByCountryEntityId(entityId);
    if (descriptor == null) {
      return null;
    }

    await _packImportService.importCountryPack(descriptor.countrySlug);
    return _explorationDao.fetchEntity(entityId);
  }

  @override
  Future<List<Entity>> getChildren(String entityId) async {
    final entity = await getEntity(entityId);
    if (entity == null) {
      return const <Entity>[];
    }
    return _explorationDao.fetchChildren(entity.entityId);
  }

  @override
  Future<List<Entity>> searchEntities(
    String query, {
    String? countryId,
    String? type,
  }) async {
    if (countryId != null) {
      await _ensureCountryImported(countryId);
    }
    return _explorationDao.searchEntities(
      query,
      countryId: countryId,
      type: type,
    );
  }

  Future<void> _ensureCountryImported(String countryEntityId) async {
    final existing = await _explorationDao.fetchEntity(countryEntityId);
    if (existing != null) {
      return;
    }

    final descriptor = await _findDescriptorByCountryEntityId(countryEntityId);
    if (descriptor == null) {
      return;
    }

    await _packImportService.importCountryPack(descriptor.countrySlug);
  }

  Future<CountryPackDescriptor?> _findDescriptorByCountryEntityId(
    String entityId,
  ) async {
    for (final descriptor in await _packImportService.listCountryPacks()) {
      if (descriptor.countryEntityId == entityId) {
        return descriptor;
      }
    }
    return null;
  }

  Entity _placeholderCountryEntity(CountryPackDescriptor descriptor) {
    final bbox =
        descriptor.bbox ??
        const GeoBounds(west: -180, south: -85, east: 180, north: 85);
    return Entity(
      entityId: descriptor.countryEntityId,
      type: EntityType.country,
      name: descriptor.countryName,
      bbox: bbox,
      centroid: descriptor.centroid ?? bbox.center,
      geometryGeoJson: _emptyGeometryGeoJson,
      countrySlug: descriptor.countrySlug,
      packVersion: descriptor.packVersion,
      updatedAt: 0,
    );
  }
}
