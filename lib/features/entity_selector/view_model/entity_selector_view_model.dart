import 'package:flutter/foundation.dart';

import '../../../domain/entities/entity.dart';
import '../../../domain/entities/entity_type.dart';
import '../../exploration/data/repositories/entity_repository.dart';
import '../../exploration/data/repositories/selection_repository.dart';

class EntitySelectorViewModel extends ChangeNotifier {
  EntitySelectorViewModel({
    required EntityRepository entityRepository,
    required SelectionRepository selectionRepository,
  }) : _entityRepository = entityRepository,
       _selectionRepository = selectionRepository;

  final EntityRepository _entityRepository;
  final SelectionRepository _selectionRepository;

  final Map<String, List<Entity>> _childrenByParentId =
      <String, List<Entity>>{};
  final Set<String> _expandedEntityIds = <String>{};
  final Set<String> _loadingChildEntityIds = <String>{};

  List<Entity> _countries = const <Entity>[];
  String? _selectedEntityId;
  bool _isLoading = false;
  Object? _error;

  List<Entity> get countries => _countries;
  String? get selectedEntityId => _selectedEntityId;
  bool get isLoading => _isLoading;
  Object? get error => _error;

  List<Entity> childrenFor(String entityId) =>
      _childrenByParentId[entityId] ?? const <Entity>[];

  bool isExpanded(String entityId) => _expandedEntityIds.contains(entityId);

  bool isLoadingChildren(String entityId) =>
      _loadingChildEntityIds.contains(entityId);

  bool canExpand(Entity entity) {
    if (entity.type == EntityType.cityCenter) {
      return false;
    }
    final loadedChildren = _childrenByParentId[entity.entityId];
    return loadedChildren == null || loadedChildren.isNotEmpty;
  }

  Future<void> loadCountries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _countries = await _entityRepository.getCountries();

      final selected = await _selectionRepository.getSelectedEntityResolved();
      if (selected != null) {
        _selectedEntityId = selected.entityId;
        await _expandSelectionPath(selected);
      }
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectEntity(String entityId) {
    if (_selectedEntityId == entityId) {
      return;
    }
    _selectedEntityId = entityId;
    notifyListeners();
  }

  Future<void> toggleExpanded(String entityId) async {
    if (_expandedEntityIds.remove(entityId)) {
      notifyListeners();
      return;
    }

    final children = await _ensureChildrenLoaded(entityId);
    if (children.isEmpty) {
      return;
    }

    _expandedEntityIds.add(entityId);
    notifyListeners();
  }

  Future<void> confirmSelection() async {
    final entityId = _selectedEntityId;
    if (entityId == null) {
      return;
    }
    await _selectionRepository.setSelectedEntityId(entityId);
  }

  Future<void> _expandSelectionPath(Entity selected) async {
    final seenIds = <String>{};
    for (final entityId in _selectionExpansionPath(selected)) {
      if (!seenIds.add(entityId)) {
        continue;
      }
      final children = await _ensureChildrenLoaded(
        entityId,
        emitChanges: false,
      );
      if (children.isNotEmpty) {
        _expandedEntityIds.add(entityId);
      }
    }
  }

  Iterable<String> _selectionExpansionPath(Entity selected) sync* {
    if (selected.countryId != null) {
      yield selected.countryId!;
    }
    if (selected.regionId != null) {
      yield selected.regionId!;
    }
    if (selected.cityId != null) {
      yield selected.cityId!;
    }
    if (selected.type != EntityType.cityCenter) {
      yield selected.entityId;
    }
  }

  Future<List<Entity>> _ensureChildrenLoaded(
    String entityId, {
    bool emitChanges = true,
  }) async {
    final cachedChildren = _childrenByParentId[entityId];
    if (cachedChildren != null) {
      return cachedChildren;
    }
    if (_loadingChildEntityIds.contains(entityId)) {
      return const <Entity>[];
    }

    _loadingChildEntityIds.add(entityId);
    if (emitChanges) {
      notifyListeners();
    }

    try {
      final children = await _entityRepository.getChildren(entityId);
      _childrenByParentId[entityId] = children;
      return children;
    } catch (error) {
      _error = error;
      return const <Entity>[];
    } finally {
      _loadingChildEntityIds.remove(entityId);
      if (emitChanges) {
        notifyListeners();
      }
    }
  }
}
