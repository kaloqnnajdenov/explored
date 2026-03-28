import '../models/country_pack_descriptor.dart';
import '../models/country_pack_state.dart';
import '../services/exploration_database.dart';
import '../services/legacy_selection_service.dart';
import '../services/local_user_prefs_service.dart';
import '../services/pack_import_service.dart';

abstract class PackManagementRepository {
  Future<void> bootstrapBundledCountryPacks();

  Future<List<CountryPackState>> getCountryPacks();

  Future<void> importCountryPack(String countrySlug);
}

class DefaultPackManagementRepository implements PackManagementRepository {
  DefaultPackManagementRepository({
    required PackImportService packImportService,
    required ExplorationDao explorationDao,
    required LegacySelectionService legacySelectionService,
    LocalUserPrefsService? localUserPrefsService,
  }) : _packImportService = packImportService,
       _explorationDao = explorationDao,
       _legacySelectionService = legacySelectionService,
       _localUserPrefsService = localUserPrefsService;

  final PackImportService _packImportService;
  final ExplorationDao _explorationDao;
  final LegacySelectionService _legacySelectionService;
  final LocalUserPrefsService? _localUserPrefsService;

  @override
  Future<void> bootstrapBundledCountryPacks() async {
    final descriptors = await _packImportService.listCountryPacks();
    if (descriptors.isEmpty) {
      return;
    }

    final activeDescriptor = await _resolveActiveDescriptor(descriptors);
    await _packImportService.importCountryPack(activeDescriptor.countrySlug);
    _localUserPrefsService?.writeSelectedCountrySlug(
      activeDescriptor.countrySlug,
    );
    await _restoreOrSeedSelection(activeDescriptor);
  }

  @override
  Future<List<CountryPackState>> getCountryPacks() async {
    final descriptors = await _packImportService.listCountryPacks();
    final statuses = await _explorationDao.fetchCountryPackStatuses();
    final statusBySlug = {
      for (final status in statuses) status.countrySlug: status,
    };
    return descriptors
        .map(
          (descriptor) => CountryPackState(
            descriptor: descriptor,
            imported: statusBySlug[descriptor.countrySlug]?.imported ?? false,
            importedAt: statusBySlug[descriptor.countrySlug]?.importedAt,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> importCountryPack(String countrySlug) {
    return _packImportService.importCountryPack(countrySlug);
  }

  Future<CountryPackDescriptor> _resolveActiveDescriptor(
    List<CountryPackDescriptor> descriptors,
  ) async {
    final selectedId = await _explorationDao.fetchSelectedEntityId();
    if (selectedId != null) {
      final selected = await _explorationDao.fetchEntity(selectedId);
      if (selected != null) {
        final selectedDescriptor = _descriptorForCountrySlug(
          descriptors,
          selected.countrySlug,
        );
        if (selectedDescriptor != null) {
          return selectedDescriptor;
        }
      }
    }

    final preferredCountrySlug = _localUserPrefsService
        ?.readSelectedCountrySlug();
    if (preferredCountrySlug != null) {
      final preferredDescriptor = _descriptorForCountrySlug(
        descriptors,
        preferredCountrySlug,
      );
      if (preferredDescriptor != null) {
        return preferredDescriptor;
      }
    }

    final legacyId = _legacySelectionService.readLegacySelectedEntityId();
    if (legacyId != null) {
      for (final descriptor in descriptors) {
        if (descriptor.countryEntityId == legacyId) {
          return descriptor;
        }
      }
    }

    return descriptors.first;
  }

  Future<void> _restoreOrSeedSelection(
    CountryPackDescriptor activeDescriptor,
  ) async {
    final selectedId = await _explorationDao.fetchSelectedEntityId();
    if (selectedId != null) {
      final selected = await _explorationDao.fetchEntity(selectedId);
      if (selected != null) {
        _localUserPrefsService?.writeSelectedCountrySlug(selected.countrySlug);
        return;
      }
    }

    final legacyId = _legacySelectionService.readLegacySelectedEntityId();
    if (legacyId != null) {
      final migrated = await _explorationDao.fetchEntity(legacyId);
      if (migrated != null) {
        _localUserPrefsService?.writeSelectedCountrySlug(migrated.countrySlug);
        await _explorationDao.upsertSelectedEntityId(
          migrated.entityId,
          DateTime.now().toUtc().millisecondsSinceEpoch,
        );
        return;
      }
    }

    await _explorationDao.upsertSelectedEntityId(
      activeDescriptor.countryEntityId,
      DateTime.now().toUtc().millisecondsSinceEpoch,
    );
  }

  CountryPackDescriptor? _descriptorForCountrySlug(
    List<CountryPackDescriptor> descriptors,
    String countrySlug,
  ) {
    for (final descriptor in descriptors) {
      if (descriptor.countrySlug == countrySlug) {
        return descriptor;
      }
    }
    return null;
  }
}
