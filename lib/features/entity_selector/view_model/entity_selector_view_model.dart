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

  List<Entity> _countries = const <Entity>[];
  List<Entity> _regions = const <Entity>[];
  List<Entity> _cities = const <Entity>[];
  List<Entity> _cityCenters = const <Entity>[];
  String? _selectedCountryId;
  String? _selectedRegionId;
  String? _selectedCityId;
  String? _selectedCityCenterId;
  bool _isLoading = false;
  Object? _error;

  List<Entity> get countries => _countries;
  List<Entity> get regions => _regions;
  List<Entity> get cities => _cities;
  List<Entity> get cityCenters => _cityCenters;
  String? get selectedCountryId => _selectedCountryId;
  String? get selectedRegionId => _selectedRegionId;
  String? get selectedCityId => _selectedCityId;
  String? get selectedCityCenterId => _selectedCityCenterId;
  bool get isLoading => _isLoading;
  Object? get error => _error;

  Future<void> loadCountries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _countries = await _entityRepository.getCountries();
      final selected = await _selectionRepository.getSelectedEntityResolved();
      if (selected != null) {
        await _hydrateSelection(selected);
      }
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectCountry(String entityId) async {
    _selectedCountryId = entityId;
    _selectedRegionId = null;
    _selectedCityId = null;
    _selectedCityCenterId = null;
    _regions = await _entityRepository.getRegions(entityId);
    _cities = await _entityRepository.getCities(countryEntityId: entityId);
    _cityCenters = const <Entity>[];
    notifyListeners();
  }

  Future<void> selectRegion(String entityId) async {
    _selectedRegionId = entityId;
    _selectedCityId = null;
    _selectedCityCenterId = null;

    final region = await _entityRepository.getEntity(entityId);
    if (region == null) {
      return;
    }
    _selectedCountryId = region.countryId;
    _cities = await _entityRepository.getCities(
      countryEntityId: region.countryId!,
      regionEntityId: entityId,
    );
    _cityCenters = const <Entity>[];
    notifyListeners();
  }

  Future<void> selectCity(String entityId) async {
    _selectedCityId = entityId;
    _selectedCityCenterId = null;

    final city = await _entityRepository.getEntity(entityId);
    if (city == null) {
      return;
    }
    _selectedCountryId = city.countryId;
    _selectedRegionId = city.regionId;
    _cityCenters = await _entityRepository.getCityCenters(entityId);
    notifyListeners();
  }

  void selectCityCenter(String entityId) {
    _selectedCityCenterId = entityId;
    notifyListeners();
  }

  Future<void> confirmSelection() async {
    final entityId =
        _selectedCityCenterId ??
        _selectedCityId ??
        _selectedRegionId ??
        _selectedCountryId;
    if (entityId == null) {
      return;
    }
    await _selectionRepository.setSelectedEntityId(entityId);
  }

  Future<void> _hydrateSelection(Entity selected) async {
    if (selected.type == EntityType.country) {
      await selectCountry(selected.entityId);
      return;
    }

    if (selected.type == EntityType.region) {
      await selectCountry(selected.countryId!);
      await selectRegion(selected.entityId);
      return;
    }

    if (selected.type == EntityType.city) {
      await selectCountry(selected.countryId!);
      if (selected.regionId != null) {
        await selectRegion(selected.regionId!);
      }
      await selectCity(selected.entityId);
      return;
    }

    await selectCountry(selected.countryId!);
    if (selected.regionId != null) {
      await selectRegion(selected.regionId!);
    }
    await selectCity(selected.cityId!);
    selectCityCenter(selected.entityId);
  }
}
