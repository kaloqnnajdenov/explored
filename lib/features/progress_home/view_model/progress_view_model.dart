import 'package:flutter/foundation.dart';

import '../../../domain/entities/entity.dart';
import '../../../domain/entities/entity_progress.dart';
import '../../exploration/data/repositories/entity_repository.dart';
import '../../exploration/data/repositories/progress_repository.dart';
import '../../exploration/data/repositories/selection_repository.dart';

class ProgressViewModel extends ChangeNotifier {
  ProgressViewModel({
    required EntityRepository entityRepository,
    required ProgressRepository progressRepository,
    required SelectionRepository selectionRepository,
  }) : _entityRepository = entityRepository,
       _progressRepository = progressRepository,
       _selectionRepository = selectionRepository;

  final EntityRepository _entityRepository;
  final ProgressRepository _progressRepository;
  final SelectionRepository _selectionRepository;

  EntityProgress? _selectedProgress;
  List<Entity> _children = const <Entity>[];
  bool _isLoading = false;
  Object? _error;
  bool _hasLoaded = false;

  EntityProgress? get selectedProgress => _selectedProgress;
  Entity? get selectedEntity => _selectedProgress?.entity;
  List<Entity> get children => _children;
  bool get isLoading => _isLoading;
  Object? get error => _error;
  bool get hasLoaded => _hasLoaded;

  Future<void> initialize() async {
    if (_hasLoaded) {
      return;
    }
    await refresh();
  }

  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var selected = await _selectionRepository.getSelectedEntityResolved();
      if (selected == null) {
        final countries = await _entityRepository.getCountries();
        if (countries.isNotEmpty) {
          final preferredCountrySlug = await _selectionRepository
              .getSelectedCountrySlug();
          final fallbackCountry = preferredCountrySlug == null
              ? countries.first
              : countries.firstWhere(
                  (country) => country.countrySlug == preferredCountrySlug,
                  orElse: () => countries.first,
                );
          await _selectionRepository.setSelectedEntityId(
            fallbackCountry.entityId,
          );
          selected =
              await _selectionRepository.getSelectedEntityResolved() ??
              await _entityRepository.getEntity(fallbackCountry.entityId);
        }
      }

      if (selected == null) {
        _selectedProgress = null;
        _children = const <Entity>[];
      } else {
        _selectedProgress = await _progressRepository.getEntityProgress(
          selected.entityId,
        );
        _children = await _entityRepository.getChildren(selected.entityId);
      }
    } catch (error) {
      _error = error;
    } finally {
      _hasLoaded = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectEntity(String entityId) async {
    await _selectionRepository.setSelectedEntityId(entityId);
    await refresh();
  }
}
