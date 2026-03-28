import '../../../../domain/entities/entity.dart';
import '../../../../domain/objects/explorable_object.dart';
import '../../../../domain/objects/object_category.dart';
import '../../../../domain/objects/road_metric.dart';
import '../../../../domain/objects/road_segment.dart';
import 'entity_repository.dart';
import '../services/exploration_database.dart';

abstract class ObjectRepository {
  Future<List<ExplorableObject>> getObjectsForEntity(
    String entityId, {
    ObjectCategory? category,
  });

  Future<List<RoadSegment>> getRoadsForEntity(
    String entityId, {
    RoadMetric? metric,
  });

  Future<int> countObjectsForEntity(String entityId, ObjectCategory category);

  Future<double> sumRoadLengthForEntity(String entityId, RoadMetric metric);
}

class DefaultObjectRepository implements ObjectRepository {
  DefaultObjectRepository({
    required EntityRepository entityRepository,
    required ExplorationDao explorationDao,
  }) : _entityRepository = entityRepository,
       _explorationDao = explorationDao;

  final EntityRepository _entityRepository;
  final ExplorationDao _explorationDao;

  @override
  Future<List<ExplorableObject>> getObjectsForEntity(
    String entityId, {
    ObjectCategory? category,
  }) async {
    final entity = await _requireEntity(entityId);
    return _explorationDao.fetchObjectsForEntity(entity, category: category);
  }

  @override
  Future<List<RoadSegment>> getRoadsForEntity(
    String entityId, {
    RoadMetric? metric,
  }) async {
    final entity = await _requireEntity(entityId);
    return _explorationDao.fetchRoadsForEntity(entity, metric: metric);
  }

  @override
  Future<int> countObjectsForEntity(String entityId, ObjectCategory category) async {
    final entity = await _requireEntity(entityId);
    return _explorationDao.countObjectsForEntity(entity, category);
  }

  @override
  Future<double> sumRoadLengthForEntity(String entityId, RoadMetric metric) async {
    final entity = await _requireEntity(entityId);
    return _explorationDao.sumRoadLengthForEntity(entity, metric);
  }

  Future<Entity> _requireEntity(String entityId) async {
    final entity = await _entityRepository.getEntity(entityId);
    if (entity == null) {
      throw StateError('Unknown entity: $entityId');
    }
    return entity;
  }
}
