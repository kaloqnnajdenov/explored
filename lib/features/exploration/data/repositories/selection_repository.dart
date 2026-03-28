import '../../../../domain/entities/entity.dart';
import '../services/local_user_prefs_service.dart';
import 'entity_repository.dart';
import '../services/exploration_database.dart';

abstract class SelectionRepository {
  Future<String?> getSelectedEntityId();

  Future<String?> getSelectedCountrySlug();

  Future<void> setSelectedEntityId(String entityId);

  Future<Entity?> getSelectedEntityResolved();
}

class DefaultSelectionRepository implements SelectionRepository {
  DefaultSelectionRepository({
    required ExplorationDao explorationDao,
    required EntityRepository entityRepository,
    LocalUserPrefsService? localUserPrefsService,
  }) : _explorationDao = explorationDao,
       _entityRepository = entityRepository,
       _localUserPrefsService = localUserPrefsService;

  final ExplorationDao _explorationDao;
  final EntityRepository _entityRepository;
  final LocalUserPrefsService? _localUserPrefsService;

  @override
  Future<String?> getSelectedEntityId() =>
      _explorationDao.fetchSelectedEntityId();

  @override
  Future<String?> getSelectedCountrySlug() async {
    final persisted = _localUserPrefsService?.readSelectedCountrySlug();
    if (persisted != null && persisted.isNotEmpty) {
      return persisted;
    }

    final selected = await getSelectedEntityResolved();
    final countrySlug = selected?.countrySlug;
    if (countrySlug != null) {
      _localUserPrefsService?.writeSelectedCountrySlug(countrySlug);
    }
    return countrySlug;
  }

  @override
  Future<void> setSelectedEntityId(String entityId) async {
    await _explorationDao.upsertSelectedEntityId(
      entityId,
      DateTime.now().toUtc().millisecondsSinceEpoch,
    );
    final selected = await _entityRepository.getEntity(entityId);
    final countrySlug = selected?.countrySlug;
    if (countrySlug != null) {
      _localUserPrefsService?.writeSelectedCountrySlug(countrySlug);
    }
  }

  @override
  Future<Entity?> getSelectedEntityResolved() async {
    final selectedId = await getSelectedEntityId();
    if (selectedId == null) {
      return null;
    }
    return _entityRepository.getEntity(selectedId);
  }
}
