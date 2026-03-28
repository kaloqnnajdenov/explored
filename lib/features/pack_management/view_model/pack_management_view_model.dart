import 'package:flutter/foundation.dart';

import '../../exploration/data/models/country_pack_state.dart';
import '../../exploration/data/repositories/entity_repository.dart';
import '../../exploration/data/repositories/pack_management_repository.dart';
import '../../exploration/data/repositories/selection_repository.dart';
import '../../exploration/data/services/legacy_selection_service.dart';

class PackManagementFeedback {
  const PackManagementFeedback({
    required this.id,
    required this.messageKey,
    this.namedArgs,
    this.isError = false,
  });

  final int id;
  final String messageKey;
  final Map<String, String>? namedArgs;
  final bool isError;
}

class PackManagementViewModel extends ChangeNotifier {
  PackManagementViewModel({
    required PackManagementRepository repository,
    required EntityRepository entityRepository,
    required SelectionRepository selectionRepository,
    required LegacySelectionService legacySelectionService,
  }) : _repository = repository,
       _entityRepository = entityRepository,
       _selectionRepository = selectionRepository,
       _legacySelectionService = legacySelectionService;

  final PackManagementRepository _repository;
  final EntityRepository _entityRepository;
  final SelectionRepository _selectionRepository;
  final LegacySelectionService _legacySelectionService;

  List<CountryPackState> _packs = const <CountryPackState>[];
  bool _isLoading = false;
  String? _importingCountrySlug;
  Object? _error;
  PackManagementFeedback? _feedback;
  int _feedbackId = 0;

  List<CountryPackState> get packs => _packs;
  bool get isLoading => _isLoading;
  String? get importingCountrySlug => _importingCountrySlug;
  Object? get error => _error;
  PackManagementFeedback? get feedback => _feedback;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _packs = await _repository.getCountryPacks();
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> importCountryPack(String countrySlug) async {
    if (_importingCountrySlug != null) {
      return;
    }

    _importingCountrySlug = countrySlug;
    _error = null;
    notifyListeners();

    try {
      await _repository.importCountryPack(countrySlug);
      await _restoreOrSeedSelection(countrySlug);
      _packs = await _repository.getCountryPacks();
      _emitFeedback(
        messageKey: 'pack_management_import_success',
        namedArgs: {'country': _countryNameForSlug(countrySlug)},
      );
    } catch (error) {
      _error = error;
      _emitFeedback(
        messageKey: 'pack_management_import_failed',
        namedArgs: {'country': _countryNameForSlug(countrySlug)},
        isError: true,
      );
    } finally {
      _importingCountrySlug = null;
      notifyListeners();
    }
  }

  Future<void> _restoreOrSeedSelection(String countrySlug) async {
    final selectedId = await _selectionRepository.getSelectedEntityId();
    if (selectedId != null) {
      final selected = await _entityRepository.getEntity(selectedId);
      if (selected != null) {
        return;
      }
    }

    final legacyId = _legacySelectionService.readLegacySelectedEntityId();
    if (legacyId != null) {
      final migrated = await _entityRepository.getEntity(legacyId);
      if (migrated != null) {
        await _selectionRepository.setSelectedEntityId(migrated.entityId);
        return;
      }
    }

    final countries = await _entityRepository.getCountries();
    final fallbackCountry = countries.firstWhere(
      (country) => country.countrySlug == countrySlug,
      orElse: () => countries.first,
    );
    await _selectionRepository.setSelectedEntityId(fallbackCountry.entityId);
  }

  String _countryNameForSlug(String countrySlug) {
    final pack = _packs.where((item) => item.descriptor.countrySlug == countrySlug);
    if (pack.isEmpty) {
      return countrySlug;
    }
    return pack.first.descriptor.countryName;
  }

  void _emitFeedback({
    required String messageKey,
    Map<String, String>? namedArgs,
    bool isError = false,
  }) {
    _feedbackId += 1;
    _feedback = PackManagementFeedback(
      id: _feedbackId,
      messageKey: messageKey,
      namedArgs: namedArgs,
      isError: isError,
    );
  }
}
