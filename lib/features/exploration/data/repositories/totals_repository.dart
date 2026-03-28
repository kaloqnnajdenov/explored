import '../../../../domain/entities/entity_totals.dart';
import '../services/exploration_database.dart';

abstract class TotalsRepository {
  Future<EntityTotals?> getTotals(String entityId);
}

class DefaultTotalsRepository implements TotalsRepository {
  DefaultTotalsRepository({required ExplorationDao explorationDao})
    : _explorationDao = explorationDao;

  final ExplorationDao _explorationDao;

  @override
  Future<EntityTotals?> getTotals(String entityId) {
    return _explorationDao.fetchEntityTotals(entityId);
  }
}
