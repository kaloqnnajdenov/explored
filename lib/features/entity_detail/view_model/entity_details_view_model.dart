import 'package:flutter/foundation.dart';

import '../../../domain/entities/entity.dart';
import '../../../domain/entities/entity_progress.dart';
import '../../exploration/data/repositories/entity_repository.dart';
import '../../exploration/data/repositories/progress_repository.dart';

class EntityDetailsViewModel extends ChangeNotifier {
  EntityDetailsViewModel({
    required EntityRepository entityRepository,
    required ProgressRepository progressRepository,
  }) : _entityRepository = entityRepository,
       _progressRepository = progressRepository;

  final EntityRepository _entityRepository;
  final ProgressRepository _progressRepository;

  String? _entityId;
  EntityProgress? _progress;
  List<Entity> _children = const <Entity>[];
  List<Entity> _parentChain = const <Entity>[];
  bool _isLoading = false;
  Object? _error;

  EntityProgress? get progress => _progress;
  Entity? get entity => _progress?.entity;
  List<Entity> get children => _children;
  List<Entity> get parentChain => _parentChain;
  bool get isLoading => _isLoading;
  Object? get error => _error;

  Future<void> loadEntity(String entityId) async {
    _entityId = entityId;
    await refresh();
  }

  Future<void> refresh() async {
    final entityId = _entityId;
    if (entityId == null) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final progress = await _progressRepository.getEntityProgress(entityId);
      _progress = progress;
      _children = await _entityRepository.getChildren(entityId);
      _parentChain = await _loadParentChain(progress.entity);
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Entity>> _loadParentChain(Entity entity) async {
    final ids = <String>[
      if (entity.countryId != null && entity.countryId != entity.entityId)
        entity.countryId!,
      if (entity.regionId != null && entity.regionId != entity.entityId)
        entity.regionId!,
      if (entity.cityId != null && entity.cityId != entity.entityId)
        entity.cityId!,
    ];

    final chain = <Entity>[];
    for (final id in ids) {
      final parent = await _entityRepository.getEntity(id);
      if (parent != null) {
        chain.add(parent);
      }
    }
    return chain;
  }
}
