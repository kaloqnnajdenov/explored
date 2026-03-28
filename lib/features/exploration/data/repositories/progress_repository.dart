import '../../../../domain/entities/entity.dart';
import '../../../../domain/entities/entity_progress.dart';
import '../../../../domain/entities/entity_totals.dart';
import '../../../../domain/objects/object_category.dart';
import '../../../../domain/objects/road_metric.dart';
import '../services/exploration_database.dart';
import '../services/local_user_prefs_service.dart';
import 'entity_repository.dart';
import 'totals_repository.dart';

abstract class ProgressRepository {
  Future<EntityProgress> getEntityProgress(String entityId);

  Future<void> recomputeEntityProgress(String entityId);

  Future<void> recomputeAffectedEntitiesForObject(String objectId);

  Future<void> recomputeAffectedEntitiesForRoad(String roadSegmentId);

  Future<void> recordObjectExplored(
    String objectId, {
    double? bestDistanceM,
    double? confidence,
    String? sourceType,
    int? sampleCountUsed,
  });

  Future<void> recordRoadCoverage(
    String roadSegmentId, {
    required double coveredLengthM,
    required double coverageRatio,
    String coveredIntervalsJson,
    String? sourceType,
    int? sampleCountUsed,
  });
}

class DefaultProgressRepository implements ProgressRepository {
  DefaultProgressRepository({
    required EntityRepository entityRepository,
    required TotalsRepository totalsRepository,
    required ExplorationDao explorationDao,
    required LocalUserPrefsService localUserPrefsService,
  }) : _entityRepository = entityRepository,
       _totalsRepository = totalsRepository,
       _explorationDao = explorationDao,
       _localUserPrefsService = localUserPrefsService;

  final EntityRepository _entityRepository;
  final TotalsRepository _totalsRepository;
  final ExplorationDao _explorationDao;
  final LocalUserPrefsService _localUserPrefsService;

  @override
  Future<EntityProgress> getEntityProgress(String entityId) async {
    final entity = await _requireEntity(entityId);
    final totals = await _totalsRepository.getTotals(entityId) ??
        EntityTotals(
          entityId: entityId,
          peaksCount: 0,
          hutsCount: 0,
          monumentsCount: 0,
          roadsDrivableLengthM: 0,
          roadsWalkableLengthM: 0,
          roadsCyclewayLengthM: 0,
        );

    final userId = _localUserPrefsService.readOrCreateUserId();
    var cache = await _explorationDao.fetchEntityProgressCache(
      userId: userId,
      entityId: entityId,
    );
    if (cache == null) {
      await recomputeEntityProgress(entityId);
      cache = await _explorationDao.fetchEntityProgressCache(
        userId: userId,
        entityId: entityId,
      );
    }

    return EntityProgress(
      entity: entity,
      totals: totals,
      peaks: CountProgress(
        explored: cache?.exploredPeaksCount ?? 0,
        total: totals.peaksCount,
      ),
      huts: CountProgress(
        explored: cache?.exploredHutsCount ?? 0,
        total: totals.hutsCount,
      ),
      monuments: CountProgress(
        explored: cache?.exploredMonumentsCount ?? 0,
        total: totals.monumentsCount,
      ),
      roadsDrivable: LengthProgress(
        exploredLengthM: cache?.exploredDrivableLengthM ?? 0,
        totalLengthM: totals.roadsDrivableLengthM,
      ),
      roadsWalkable: LengthProgress(
        exploredLengthM: cache?.exploredWalkableLengthM ?? 0,
        totalLengthM: totals.roadsWalkableLengthM,
      ),
      roadsCycleway: LengthProgress(
        exploredLengthM: cache?.exploredCyclewayLengthM ?? 0,
        totalLengthM: totals.roadsCyclewayLengthM,
      ),
    );
  }

  @override
  Future<void> recomputeEntityProgress(String entityId) async {
    final entity = await _requireEntity(entityId);
    final userId = _localUserPrefsService.readOrCreateUserId();

    final exploredPeaks = await _explorationDao.countExploredObjectsForEntity(
      userId: userId,
      entity: entity,
      category: ObjectCategory.peak,
    );
    final exploredHuts = await _explorationDao.countExploredObjectsForEntity(
      userId: userId,
      entity: entity,
      category: ObjectCategory.hut,
    );
    final exploredMonuments =
        await _explorationDao.countExploredObjectsForEntity(
          userId: userId,
          entity: entity,
          category: ObjectCategory.monument,
        );
    final exploredDrivable = await _explorationDao.sumExploredRoadLengthForEntity(
      userId: userId,
      entity: entity,
      metric: RoadMetric.drivable,
    );
    final exploredWalkable = await _explorationDao.sumExploredRoadLengthForEntity(
      userId: userId,
      entity: entity,
      metric: RoadMetric.walkable,
    );
    final exploredCycleway = await _explorationDao.sumExploredRoadLengthForEntity(
      userId: userId,
      entity: entity,
      metric: RoadMetric.cycleway,
    );

    await _explorationDao.upsertEntityProgressCache(
      userId: userId,
      entityId: entityId,
      exploredPeaksCount: exploredPeaks,
      exploredHutsCount: exploredHuts,
      exploredMonumentsCount: exploredMonuments,
      exploredDrivableLengthM: exploredDrivable,
      exploredWalkableLengthM: exploredWalkable,
      exploredCyclewayLengthM: exploredCycleway,
      updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
    );
  }

  @override
  Future<void> recomputeAffectedEntitiesForObject(String objectId) async {
    final entityIds = await _explorationDao.fetchParentEntityIdsForObject(objectId);
    for (final entityId in entityIds) {
      await recomputeEntityProgress(entityId);
    }
  }

  @override
  Future<void> recomputeAffectedEntitiesForRoad(String roadSegmentId) {
    return recomputeAffectedEntitiesForObject(roadSegmentId);
  }

  @override
  Future<void> recordObjectExplored(
    String objectId, {
    double? bestDistanceM,
    double? confidence,
    String? sourceType,
    int? sampleCountUsed,
  }) async {
    final object = await _explorationDao.fetchStaticObject(objectId);
    if (object == null) {
      throw StateError('Unknown object: $objectId');
    }
    final userId = _localUserPrefsService.readOrCreateUserId();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _explorationDao.upsertUserObjectProgress(
      userId: userId,
      objectId: objectId,
      category: ObjectCategory.fromRaw(object.category),
      explored: true,
      firstExploredAt: now,
      bestDistanceM: bestDistanceM,
      confidence: confidence,
      sourceType: sourceType,
      sampleCountUsed: sampleCountUsed,
      lastSeenAt: now,
    );
    await recomputeAffectedEntitiesForObject(objectId);
  }

  @override
  Future<void> recordRoadCoverage(
    String roadSegmentId, {
    required double coveredLengthM,
    required double coverageRatio,
    String coveredIntervalsJson = '[]',
    String? sourceType,
    int? sampleCountUsed,
  }) async {
    final road = await _explorationDao.fetchStaticObject(roadSegmentId);
    if (road == null) {
      throw StateError('Unknown road segment: $roadSegmentId');
    }
    final userId = _localUserPrefsService.readOrCreateUserId();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _explorationDao.upsertUserRoadSegmentProgress(
      userId: userId,
      roadSegmentId: roadSegmentId,
      coveredLengthM: coveredLengthM,
      coverageRatio: coverageRatio,
      coveredIntervalsJson: coveredIntervalsJson,
      firstCoveredAt: now,
      lastCoveredAt: now,
      sourceType: sourceType,
      sampleCountUsed: sampleCountUsed,
    );
    await recomputeAffectedEntitiesForRoad(roadSegmentId);
  }

  Future<Entity> _requireEntity(String entityId) async {
    final entity = await _entityRepository.getEntity(entityId);
    if (entity == null) {
      throw StateError('Unknown entity: $entityId');
    }
    return entity;
  }
}
