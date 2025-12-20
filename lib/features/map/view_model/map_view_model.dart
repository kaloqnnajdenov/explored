import 'package:flutter/material.dart';

import '../data/models/map_config.dart';
import '../data/models/map_view_state.dart';
import '../data/repositories/map_repository.dart';

/// Owns map UI state and loads initial map config once at startup.
class MapViewModel extends ChangeNotifier {
  /// Builds the ViewModel with injected dependencies and seeded config.
  factory MapViewModel({required MapRepository mapRepository}) {
    final config = mapRepository.getMapConfig();
    return MapViewModel._(
      mapRepository: mapRepository,
      config: config,
    );
  }

  MapViewModel._({
    required MapRepository mapRepository,
    required MapConfig config,
  }) : _mapRepository = mapRepository,
       _config = config,
       _state = MapViewState.initial(config);

  final MapRepository _mapRepository;
  final MapConfig _config;

  MapViewState _state;
  bool _hasInitialized = false;

  MapViewState get state => _state;

  /// Finalizes initial map state; no-ops after first run.
  Future<void> initialize() async {
    if (_hasInitialized) {
      return;
    }

    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      _state = _state.copyWith(
        center: _config.initialCenter,
        zoom: _config.initialZoom,
        tileSource: _config.tileSource,
        isLoading: false,
        clearError: true,
      );
      _hasInitialized = true;
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        error: error,
        clearError: false,
      );
    }

    notifyListeners();
  }

  /// Opens the map attribution link; errors are logged without altering state.
  Future<void> openAttribution() async {
    try {
      await _mapRepository.openAttribution();
    } catch (error) {
      debugPrint('Failed to open map attribution: $error');
    }
  }
}
