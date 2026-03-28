import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:latlong2/latlong.dart';

import '../../../../domain/entities/entity.dart';
import '../../../../domain/entities/entity_type.dart';
import '../../../../domain/entities/entity_totals.dart';
import '../../../../domain/objects/explorable_object.dart';
import '../../../../domain/objects/object_category.dart';
import '../../../../domain/objects/road_metric.dart';
import '../../../../domain/objects/road_segment.dart';
import '../../../../domain/shared/geo_bounds.dart';
import '../models/country_pack_descriptor.dart';
import '../models/parsed_entity_row.dart';
import '../models/parsed_object_row.dart';
import '../models/parsed_totals_row.dart';

part 'exploration_database.g.dart';

@TableIndex(name: 'idx_static_entities_type', columns: {#type})
@TableIndex(name: 'idx_static_entities_country_id', columns: {#countryId})
@TableIndex(name: 'idx_static_entities_region_id', columns: {#regionId})
@TableIndex(name: 'idx_static_entities_city_id', columns: {#cityId})
@TableIndex(name: 'idx_static_entities_name', columns: {#name})
class StaticEntities extends Table {
  TextColumn get entityId => text()();
  TextColumn get type => text()();
  TextColumn get osmType => text().nullable()();
  IntColumn get osmId => integer().nullable()();
  TextColumn get areaId => text().nullable()();
  TextColumn get name => text()();
  IntColumn get adminLevel => integer().nullable()();
  TextColumn get bboxJson => text()();
  TextColumn get centroidJson => text()();
  TextColumn get countryId => text().nullable()();
  TextColumn get regionId => text().nullable()();
  TextColumn get cityId => text().nullable()();
  TextColumn get geometryGeojson => text()();
  TextColumn get countrySlug => text()();
  TextColumn get packVersion => text().nullable()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {entityId};
}

@TableIndex(name: 'idx_static_objects_category', columns: {#category})
@TableIndex(name: 'idx_static_objects_country_id', columns: {#countryId})
@TableIndex(name: 'idx_static_objects_region_id', columns: {#regionId})
@TableIndex(name: 'idx_static_objects_city_id', columns: {#cityId})
@TableIndex(name: 'idx_static_objects_city_center_id', columns: {#cityCenterId})
class StaticObjects extends Table {
  TextColumn get objectId => text()();
  TextColumn get category => text()();
  TextColumn get subtype => text().nullable()();
  TextColumn get name => text().nullable()();
  TextColumn get geometryGeojson => text()();
  TextColumn get countryId => text().nullable()();
  TextColumn get regionId => text().nullable()();
  TextColumn get cityId => text().nullable()();
  TextColumn get cityCenterId => text().nullable()();
  BoolColumn get drivable => boolean().nullable()();
  BoolColumn get walkable => boolean().nullable()();
  BoolColumn get cycleway => boolean().nullable()();
  RealColumn get lengthM => real().nullable()();
  TextColumn get countrySlug => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {objectId};
}

class StaticEntityTotals extends Table {
  TextColumn get entityId => text()();
  IntColumn get peaksCount => integer().withDefault(const Constant(0))();
  IntColumn get hutsCount => integer().withDefault(const Constant(0))();
  IntColumn get monumentsCount => integer().withDefault(const Constant(0))();
  RealColumn get roadsDrivableLengthM =>
      real().withDefault(const Constant(0))();
  RealColumn get roadsWalkableLengthM =>
      real().withDefault(const Constant(0))();
  RealColumn get roadsCyclewayLengthM =>
      real().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {entityId};
}

class SelectedEntityState extends Table {
  TextColumn get scopeKey => text()();
  TextColumn get entityId => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {scopeKey};
}

class UserObjectProgress extends Table {
  TextColumn get userId => text()();
  TextColumn get objectId => text()();
  TextColumn get category => text()();
  BoolColumn get explored => boolean().withDefault(const Constant(false))();
  IntColumn get firstExploredAt => integer().nullable()();
  RealColumn get bestDistanceM => real().nullable()();
  RealColumn get confidence => real().nullable()();
  TextColumn get sourceType => text().nullable()();
  IntColumn get sampleCountUsed => integer().nullable()();
  IntColumn get lastSeenAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {userId, objectId};
}

class UserRoadSegmentProgress extends Table {
  TextColumn get userId => text()();
  TextColumn get roadSegmentId => text()();
  RealColumn get coveredLengthM => real().withDefault(const Constant(0))();
  RealColumn get coverageRatio => real().withDefault(const Constant(0))();
  TextColumn get coveredIntervalsJson =>
      text().withDefault(const Constant('[]'))();
  IntColumn get firstCoveredAt => integer().nullable()();
  IntColumn get lastCoveredAt => integer().nullable()();
  IntColumn get sampleCountUsed => integer().nullable()();
  TextColumn get sourceType => text().nullable()();

  @override
  Set<Column> get primaryKey => {userId, roadSegmentId};
}

class UserEntityProgressCache extends Table {
  TextColumn get userId => text()();
  TextColumn get entityId => text()();
  IntColumn get exploredPeaksCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get exploredHutsCount => integer().withDefault(const Constant(0))();
  IntColumn get exploredMonumentsCount =>
      integer().withDefault(const Constant(0))();
  RealColumn get exploredDrivableLengthM =>
      real().withDefault(const Constant(0))();
  RealColumn get exploredWalkableLengthM =>
      real().withDefault(const Constant(0))();
  RealColumn get exploredCyclewayLengthM =>
      real().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {userId, entityId};
}

class CountryPackStatus extends Table {
  TextColumn get countrySlug => text()();
  BoolColumn get downloaded => boolean().withDefault(const Constant(true))();
  BoolColumn get imported => boolean().withDefault(const Constant(false))();
  TextColumn get manifestJson => text().nullable()();
  IntColumn get importedAt => integer().nullable()();
  TextColumn get version => text().nullable()();

  @override
  Set<Column> get primaryKey => {countrySlug};
}

@DriftDatabase(
  tables: [
    StaticEntities,
    StaticObjects,
    StaticEntityTotals,
    SelectedEntityState,
    UserObjectProgress,
    UserRoadSegmentProgress,
    UserEntityProgressCache,
    CountryPackStatus,
  ],
  daos: [ExplorationDao],
)
class ExplorationDatabase extends _$ExplorationDatabase {
  ExplorationDatabase({
    QueryExecutor? executor,
    String databaseName = 'exploration',
    bool shareAcrossIsolates = false,
  }) : super(
         executor ??
             driftDatabase(
               name: databaseName,
               native: DriftNativeOptions(
                 shareAcrossIsolates: shareAcrossIsolates,
               ),
             ),
       );

  @override
  int get schemaVersion => 1;
}

@DriftAccessor(
  tables: [
    StaticEntities,
    StaticObjects,
    StaticEntityTotals,
    SelectedEntityState,
    UserObjectProgress,
    UserRoadSegmentProgress,
    UserEntityProgressCache,
    CountryPackStatus,
  ],
)
class ExplorationDao extends DatabaseAccessor<ExplorationDatabase>
    with _$ExplorationDaoMixin {
  ExplorationDao(super.db);

  static const String activeSelectionScopeKey = 'active_selection';
  static const int _importBatchSize = 1000;

  Future<void> beginCountryPackImport() async {
    await transaction(() async {
      await delete(staticEntityTotals).go();
      await delete(staticObjects).go();
      await delete(staticEntities).go();
      await update(countryPackStatus).write(
        const CountryPackStatusCompanion(
          imported: Value(false),
          importedAt: Value(null),
        ),
      );
    });
  }

  Future<void> insertEntitiesChunked(
    Iterable<ParsedEntityRow> entities, {
    required int updatedAt,
  }) {
    return _insertChunked<ParsedEntityRow, StaticEntitiesCompanion>(
      source: entities,
      mapItem: (entity) => _entityCompanion(entity, updatedAt),
      writeChunk: (batch, chunk) {
        batch.insertAllOnConflictUpdate(staticEntities, chunk);
      },
    );
  }

  Future<void> insertObjectsChunked(
    Iterable<ParsedObjectRow> objects, {
    required int updatedAt,
  }) {
    return _insertChunked<ParsedObjectRow, StaticObjectsCompanion>(
      source: objects,
      mapItem: (object) => _objectCompanion(object, updatedAt),
      writeChunk: (batch, chunk) {
        batch.insertAllOnConflictUpdate(staticObjects, chunk);
      },
    );
  }

  Future<void> insertTotalsChunked(
    Iterable<ParsedTotalsRow> totals, {
    required int updatedAt,
  }) {
    return _insertChunked<ParsedTotalsRow, StaticEntityTotalsCompanion>(
      source: totals,
      mapItem: (total) => _totalsCompanion(total, updatedAt),
      writeChunk: (batch, chunk) {
        batch.insertAllOnConflictUpdate(staticEntityTotals, chunk);
      },
    );
  }

  Future<void> completeCountryPackImport({
    required CountryPackDescriptor descriptor,
    required int updatedAt,
  }) {
    return into(countryPackStatus).insertOnConflictUpdate(
      CountryPackStatusCompanion.insert(
        countrySlug: descriptor.countrySlug,
        downloaded: const Value(true),
        imported: const Value(true),
        manifestJson: Value(
          jsonEncode({
            'country_slug': descriptor.countrySlug,
            'country_entity_id': descriptor.countryEntityId,
            'country_name': descriptor.countryName,
          }),
        ),
        importedAt: Value(updatedAt),
        version: Value(descriptor.packVersion),
      ),
    );
  }

  Future<List<Entity>> fetchCountries() async {
    final rows =
        await (select(staticEntities)
              ..where((tbl) => tbl.type.equals(EntityType.country.rawValue))
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
            .get();
    return rows.map(_mapEntity).toList(growable: false);
  }

  Future<List<Entity>> fetchRegions(String countryEntityId) async {
    final rows =
        await (select(staticEntities)
              ..where(
                (tbl) =>
                    tbl.type.equals(EntityType.region.rawValue) &
                    tbl.countryId.equals(countryEntityId),
              )
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
            .get();
    return rows.map(_mapEntity).toList(growable: false);
  }

  Future<List<Entity>> fetchCities({
    required String countryEntityId,
    String? regionEntityId,
  }) async {
    final rows =
        await (select(staticEntities)
              ..where(
                (tbl) =>
                    tbl.type.equals(EntityType.city.rawValue) &
                    tbl.countryId.equals(countryEntityId) &
                    (regionEntityId == null
                        ? const Constant(true)
                        : tbl.regionId.equals(regionEntityId)),
              )
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
            .get();
    return rows.map(_mapEntity).toList(growable: false);
  }

  Future<List<Entity>> fetchCityCenters(String cityEntityId) async {
    final rows =
        await (select(staticEntities)
              ..where(
                (tbl) =>
                    tbl.type.equals(EntityType.cityCenter.rawValue) &
                    tbl.cityId.equals(cityEntityId),
              )
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
            .get();
    return rows.map(_mapEntity).toList(growable: false);
  }

  Future<Entity?> fetchEntity(String entityId) async {
    final row = await (select(
      staticEntities,
    )..where((tbl) => tbl.entityId.equals(entityId))).getSingleOrNull();
    return row == null ? null : _mapEntity(row);
  }

  Future<List<Entity>> fetchChildren(String entityId) async {
    final entity = await fetchEntity(entityId);
    if (entity == null) {
      return const <Entity>[];
    }

    switch (entity.type) {
      case EntityType.country:
        final rows =
            await (select(staticEntities)
                  ..where(
                    (tbl) =>
                        tbl.countryId.equals(entityId) &
                        (tbl.type.equals(EntityType.region.rawValue) |
                            (tbl.type.equals(EntityType.city.rawValue) &
                                tbl.regionId.isNull())),
                  )
                  ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
                .get();
        final children = rows.map(_mapEntity).toList(growable: false);
        children.sort((left, right) {
          final leftRank = left.type == EntityType.region ? 0 : 1;
          final rightRank = right.type == EntityType.region ? 0 : 1;
          if (leftRank != rightRank) {
            return leftRank.compareTo(rightRank);
          }
          return left.name.toLowerCase().compareTo(right.name.toLowerCase());
        });
        return children;
      case EntityType.region:
        return fetchCities(
          countryEntityId: entity.countryId!,
          regionEntityId: entity.entityId,
        );
      case EntityType.city:
        return fetchCityCenters(entity.entityId);
      case EntityType.cityCenter:
        return const <Entity>[];
    }
  }

  Future<List<Entity>> searchEntities(
    String query, {
    String? countryId,
    String? type,
  }) async {
    final normalized = '%${query.trim().toLowerCase()}%';
    if (normalized == '%%') {
      return const <Entity>[];
    }
    final rows = await customSelect(
      'SELECT * FROM static_entities '
      'WHERE LOWER(name) LIKE ? '
      '${countryId == null ? '' : 'AND country_id = ? '}'
      '${type == null ? '' : 'AND type = ? '}'
      'ORDER BY LOWER(name) ASC',
      variables: [
        Variable.withString(normalized),
        if (countryId != null) Variable.withString(countryId),
        if (type != null) Variable.withString(type),
      ],
      readsFrom: {staticEntities},
    ).get();
    return rows.map(_mapEntityFromRow).toList(growable: false);
  }

  Future<EntityTotals?> fetchEntityTotals(String entityId) async {
    final row = await (select(
      staticEntityTotals,
    )..where((tbl) => tbl.entityId.equals(entityId))).getSingleOrNull();
    return row == null ? null : _mapTotals(row);
  }

  Future<List<ExplorableObject>> fetchObjectsForEntity(
    Entity entity, {
    ObjectCategory? category,
  }) async {
    final rows =
        await (select(staticObjects)
              ..where(
                (tbl) => _entityObjectFilter(tbl, entity, category: category),
              )
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
            .get();
    return rows
        .where((row) => row.category != ObjectCategory.roadSegment.rawValue)
        .map(_mapObject)
        .toList(growable: false);
  }

  Future<List<RoadSegment>> fetchRoadsForEntity(
    Entity entity, {
    RoadMetric? metric,
  }) async {
    final rows =
        await (select(staticObjects)
              ..where(
                (tbl) => _entityObjectFilter(
                  tbl,
                  entity,
                  category: ObjectCategory.roadSegment,
                  metric: metric,
                ),
              )
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
            .get();
    return rows.map(_mapRoadSegment).toList(growable: false);
  }

  Future<int> countObjectsForEntity(
    Entity entity,
    ObjectCategory category,
  ) async {
    final query = selectOnly(staticObjects)
      ..addColumns([staticObjects.objectId.count()])
      ..where(_entityObjectFilter(staticObjects, entity, category: category));
    final row = await query.getSingle();
    return row.read(staticObjects.objectId.count()) ?? 0;
  }

  Future<double> sumRoadLengthForEntity(
    Entity entity,
    RoadMetric metric,
  ) async {
    final rows = await fetchRoadsForEntity(entity, metric: metric);
    return rows.fold<double>(0, (sum, road) => sum + road.lengthM);
  }

  Future<String?> fetchSelectedEntityId() async {
    final row =
        await (select(selectedEntityState)
              ..where((tbl) => tbl.scopeKey.equals(activeSelectionScopeKey)))
            .getSingleOrNull();
    return row?.entityId;
  }

  Future<void> upsertSelectedEntityId(String entityId, int updatedAt) {
    return into(selectedEntityState).insertOnConflictUpdate(
      SelectedEntityStateCompanion.insert(
        scopeKey: activeSelectionScopeKey,
        entityId: entityId,
        updatedAt: updatedAt,
      ),
    );
  }

  Future<List<CountryPackStatusData>> fetchCountryPackStatuses() {
    return (select(
      countryPackStatus,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.countrySlug)])).get();
  }

  Future<StaticObject?> fetchStaticObject(String objectId) {
    return (select(
      staticObjects,
    )..where((tbl) => tbl.objectId.equals(objectId))).getSingleOrNull();
  }

  Future<List<String>> fetchParentEntityIdsForObject(String objectId) async {
    final row = await fetchStaticObject(objectId);
    if (row == null) {
      return const <String>[];
    }
    return _parentEntityIdsFromObjectRow(row);
  }

  Future<int> countExploredObjectsForEntity({
    required String userId,
    required Entity entity,
    required ObjectCategory category,
  }) async {
    final columnName = _objectParentColumnName(entity.type);
    final row = await customSelect(
      'SELECT COUNT(*) AS count '
      'FROM user_object_progress uop '
      'JOIN static_objects so ON so.object_id = uop.object_id '
      'WHERE uop.user_id = ? '
      'AND uop.explored = 1 '
      'AND so.category = ? '
      'AND so.$columnName = ?',
      variables: [
        Variable.withString(userId),
        Variable.withString(category.rawValue),
        Variable.withString(entity.entityId),
      ],
      readsFrom: {userObjectProgress, staticObjects},
    ).getSingle();
    return row.read<int>('count');
  }

  Future<double> sumExploredRoadLengthForEntity({
    required String userId,
    required Entity entity,
    required RoadMetric metric,
  }) async {
    final columnName = _objectParentColumnName(entity.type);
    final metricColumn = switch (metric) {
      RoadMetric.drivable => 'drivable',
      RoadMetric.walkable => 'walkable',
      RoadMetric.cycleway => 'cycleway',
    };
    final row = await customSelect(
      'SELECT COALESCE(SUM(MIN(urp.covered_length_m, so.length_m)), 0) AS total '
      'FROM user_road_segment_progress urp '
      'JOIN static_objects so ON so.object_id = urp.road_segment_id '
      'WHERE urp.user_id = ? '
      'AND so.category = ? '
      'AND so.$metricColumn = 1 '
      'AND so.$columnName = ?',
      variables: [
        Variable.withString(userId),
        Variable.withString(ObjectCategory.roadSegment.rawValue),
        Variable.withString(entity.entityId),
      ],
      readsFrom: {userRoadSegmentProgress, staticObjects},
    ).getSingle();
    return row.read<double>('total');
  }

  Future<UserEntityProgressCacheData?> fetchEntityProgressCache({
    required String userId,
    required String entityId,
  }) {
    return (select(userEntityProgressCache)..where(
          (tbl) => tbl.userId.equals(userId) & tbl.entityId.equals(entityId),
        ))
        .getSingleOrNull();
  }

  Future<void> upsertEntityProgressCache({
    required String userId,
    required String entityId,
    required int exploredPeaksCount,
    required int exploredHutsCount,
    required int exploredMonumentsCount,
    required double exploredDrivableLengthM,
    required double exploredWalkableLengthM,
    required double exploredCyclewayLengthM,
    required int updatedAt,
  }) {
    return into(userEntityProgressCache).insertOnConflictUpdate(
      UserEntityProgressCacheCompanion.insert(
        userId: userId,
        entityId: entityId,
        exploredPeaksCount: Value(exploredPeaksCount),
        exploredHutsCount: Value(exploredHutsCount),
        exploredMonumentsCount: Value(exploredMonumentsCount),
        exploredDrivableLengthM: Value(exploredDrivableLengthM),
        exploredWalkableLengthM: Value(exploredWalkableLengthM),
        exploredCyclewayLengthM: Value(exploredCyclewayLengthM),
        updatedAt: updatedAt,
      ),
    );
  }

  Future<void> upsertUserObjectProgress({
    required String userId,
    required String objectId,
    required ObjectCategory category,
    required bool explored,
    int? firstExploredAt,
    double? bestDistanceM,
    double? confidence,
    String? sourceType,
    int? sampleCountUsed,
    int? lastSeenAt,
  }) {
    return into(userObjectProgress).insertOnConflictUpdate(
      UserObjectProgressCompanion.insert(
        userId: userId,
        objectId: objectId,
        category: category.rawValue,
        explored: Value(explored),
        firstExploredAt: Value(firstExploredAt),
        bestDistanceM: Value(bestDistanceM),
        confidence: Value(confidence),
        sourceType: Value(sourceType),
        sampleCountUsed: Value(sampleCountUsed),
        lastSeenAt: Value(lastSeenAt),
      ),
    );
  }

  Future<void> upsertUserRoadSegmentProgress({
    required String userId,
    required String roadSegmentId,
    required double coveredLengthM,
    required double coverageRatio,
    required String coveredIntervalsJson,
    int? firstCoveredAt,
    int? lastCoveredAt,
    int? sampleCountUsed,
    String? sourceType,
  }) {
    return into(userRoadSegmentProgress).insertOnConflictUpdate(
      UserRoadSegmentProgressCompanion.insert(
        userId: userId,
        roadSegmentId: roadSegmentId,
        coveredLengthM: Value(coveredLengthM),
        coverageRatio: Value(coverageRatio),
        coveredIntervalsJson: Value(coveredIntervalsJson),
        firstCoveredAt: Value(firstCoveredAt),
        lastCoveredAt: Value(lastCoveredAt),
        sampleCountUsed: Value(sampleCountUsed),
        sourceType: Value(sourceType),
      ),
    );
  }

  Future<void> _insertChunked<TItem, TCompanion extends Insertable<Object>>({
    required Iterable<TItem> source,
    required TCompanion Function(TItem item) mapItem,
    required void Function(Batch batch, List<TCompanion> chunk) writeChunk,
  }) async {
    final chunk = <TCompanion>[];
    for (final item in source) {
      chunk.add(mapItem(item));
      if (chunk.length >= _importBatchSize) {
        await batch((batch) => writeChunk(batch, List<TCompanion>.of(chunk)));
        chunk.clear();
      }
    }
    if (chunk.isEmpty) {
      return;
    }
    await batch((batch) => writeChunk(batch, chunk));
  }

  StaticEntitiesCompanion _entityCompanion(
    ParsedEntityRow entity,
    int updatedAt,
  ) {
    return StaticEntitiesCompanion.insert(
      entityId: entity.entityId,
      type: entity.type.rawValue,
      osmType: Value(entity.osmType),
      osmId: Value(entity.osmId),
      areaId: Value(entity.areaId),
      name: entity.name,
      adminLevel: Value(entity.adminLevel),
      bboxJson: entity.bbox.toJsonString(),
      centroidJson: jsonEncode([
        entity.centroid.longitude,
        entity.centroid.latitude,
      ]),
      countryId: Value(entity.countryId),
      regionId: Value(entity.regionId),
      cityId: Value(entity.cityId),
      geometryGeojson: entity.geometryGeoJson,
      countrySlug: entity.countrySlug,
      packVersion: Value(entity.packVersion),
      updatedAt: updatedAt,
    );
  }

  StaticObjectsCompanion _objectCompanion(
    ParsedObjectRow object,
    int updatedAt,
  ) {
    return StaticObjectsCompanion.insert(
      objectId: object.objectId,
      category: object.category.rawValue,
      subtype: Value(object.subtype),
      name: Value(object.name),
      geometryGeojson: object.geometryGeoJson,
      countryId: Value(object.countryId),
      regionId: Value(object.regionId),
      cityId: Value(object.cityId),
      cityCenterId: Value(object.cityCenterId),
      drivable: Value(object.drivable),
      walkable: Value(object.walkable),
      cycleway: Value(object.cycleway),
      lengthM: Value(object.lengthM),
      countrySlug: object.countrySlug,
      updatedAt: updatedAt,
    );
  }

  StaticEntityTotalsCompanion _totalsCompanion(
    ParsedTotalsRow totals,
    int updatedAt,
  ) {
    return StaticEntityTotalsCompanion.insert(
      entityId: totals.entityId,
      peaksCount: Value(totals.peaksCount),
      hutsCount: Value(totals.hutsCount),
      monumentsCount: Value(totals.monumentsCount),
      roadsDrivableLengthM: Value(totals.roadsDrivableLengthM),
      roadsWalkableLengthM: Value(totals.roadsWalkableLengthM),
      roadsCyclewayLengthM: Value(totals.roadsCyclewayLengthM),
      updatedAt: updatedAt,
    );
  }

  Entity _mapEntity(StaticEntity row) {
    final centroid = jsonDecode(row.centroidJson) as List<dynamic>;
    return Entity(
      entityId: row.entityId,
      type: EntityType.fromRaw(row.type),
      name: row.name,
      osmType: row.osmType,
      osmId: row.osmId,
      areaId: row.areaId,
      adminLevel: row.adminLevel,
      bbox: GeoBounds.fromJsonString(row.bboxJson),
      centroid: LatLng(
        (centroid[1] as num).toDouble(),
        (centroid[0] as num).toDouble(),
      ),
      countryId: row.countryId,
      regionId: row.regionId,
      cityId: row.cityId,
      geometryGeoJson: row.geometryGeojson,
      countrySlug: row.countrySlug,
      packVersion: row.packVersion,
      updatedAt: row.updatedAt,
    );
  }

  Entity _mapEntityFromRow(QueryRow row) {
    return Entity(
      entityId: row.read<String>('entity_id'),
      type: EntityType.fromRaw(row.read<String>('type')),
      name: row.read<String>('name'),
      osmType: row.readNullable<String>('osm_type'),
      osmId: row.readNullable<int>('osm_id'),
      areaId: row.readNullable<String>('area_id'),
      adminLevel: row.readNullable<int>('admin_level'),
      bbox: GeoBounds.fromJsonString(row.read<String>('bbox_json')),
      centroid: _centroidFromJson(row.read<String>('centroid_json')),
      countryId: row.readNullable<String>('country_id'),
      regionId: row.readNullable<String>('region_id'),
      cityId: row.readNullable<String>('city_id'),
      geometryGeoJson: row.read<String>('geometry_geojson'),
      countrySlug: row.read<String>('country_slug'),
      packVersion: row.readNullable<String>('pack_version'),
      updatedAt: row.read<int>('updated_at'),
    );
  }

  EntityTotals _mapTotals(StaticEntityTotal row) {
    return EntityTotals(
      entityId: row.entityId,
      peaksCount: row.peaksCount,
      hutsCount: row.hutsCount,
      monumentsCount: row.monumentsCount,
      roadsDrivableLengthM: row.roadsDrivableLengthM,
      roadsWalkableLengthM: row.roadsWalkableLengthM,
      roadsCyclewayLengthM: row.roadsCyclewayLengthM,
    );
  }

  ExplorableObject _mapObject(StaticObject row) {
    return ExplorableObject(
      objectId: row.objectId,
      category: ObjectCategory.fromRaw(row.category),
      subtype: row.subtype,
      name: row.name,
      geometryGeoJson: row.geometryGeojson,
      countryId: row.countryId,
      regionId: row.regionId,
      cityId: row.cityId,
      cityCenterId: row.cityCenterId,
      countrySlug: row.countrySlug,
      updatedAt: row.updatedAt,
    );
  }

  RoadSegment _mapRoadSegment(StaticObject row) {
    return RoadSegment(
      objectId: row.objectId,
      drivable: row.drivable,
      walkable: row.walkable,
      cycleway: row.cycleway,
      lengthM: row.lengthM ?? 0,
      geometryGeoJson: row.geometryGeojson,
      name: row.name,
      countryId: row.countryId,
      regionId: row.regionId,
      cityId: row.cityId,
      cityCenterId: row.cityCenterId,
      countrySlug: row.countrySlug,
      updatedAt: row.updatedAt,
    );
  }

  Expression<bool> _entityObjectFilter(
    StaticObjects tbl,
    Entity entity, {
    ObjectCategory? category,
    RoadMetric? metric,
  }) {
    var expression = category == null
        ? const Constant(true)
        : tbl.category.equals(category.rawValue);

    if (metric != null) {
      final metricExpression = switch (metric) {
        RoadMetric.drivable => tbl.drivable.equals(true),
        RoadMetric.walkable => tbl.walkable.equals(true),
        RoadMetric.cycleway => tbl.cycleway.equals(true),
      };
      expression = expression & metricExpression;
    }

    switch (entity.type) {
      case EntityType.country:
        return expression & tbl.countryId.equals(entity.entityId);
      case EntityType.region:
        return expression & tbl.regionId.equals(entity.entityId);
      case EntityType.city:
        return expression & tbl.cityId.equals(entity.entityId);
      case EntityType.cityCenter:
        return expression & tbl.cityCenterId.equals(entity.entityId);
    }
  }

  List<String> _parentEntityIdsFromObjectRow(StaticObject row) {
    return <String>[
      if (row.countryId != null) row.countryId!,
      if (row.regionId != null) row.regionId!,
      if (row.cityId != null) row.cityId!,
      if (row.cityCenterId != null) row.cityCenterId!,
    ];
  }

  String _objectParentColumnName(EntityType type) {
    switch (type) {
      case EntityType.country:
        return 'country_id';
      case EntityType.region:
        return 'region_id';
      case EntityType.city:
        return 'city_id';
      case EntityType.cityCenter:
        return 'city_center_id';
    }
  }

  LatLng _centroidFromJson(String raw) {
    final centroid = jsonDecode(raw) as List<dynamic>;
    return LatLng(
      (centroid[1] as num).toDouble(),
      (centroid[0] as num).toDouble(),
    );
  }
}
