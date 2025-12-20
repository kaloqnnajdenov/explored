import 'package:flutter/material.dart';

import '../../../core/text/data/repositories/text_repository.dart';
import '../data/models/map_config.dart';
import '../data/models/map_view_state.dart';
import '../data/repositories/map_repository.dart';

/// Owns map UI state and loads attribution/config once at startup.
class MapViewModel extends ChangeNotifier {
  /// Builds the ViewModel with injected dependencies and seeded config.
  factory MapViewModel({
    required MapRepository mapRepository,
    required TextRepository textRepository,
    required Locale locale,
  }) {
    final config = mapRepository.getMapConfig();
    return MapViewModel._(
      mapRepository: mapRepository,
      config: config,
      textRepository: textRepository,
      locale: locale,
    );
  }

  MapViewModel._({
    required MapRepository mapRepository,
    required MapConfig config,
    required TextRepository textRepository,
    required Locale locale,
  }) : _mapRepository = mapRepository,
       _textRepository = textRepository,
       _locale = locale,
       _config = config,
       _state = MapViewState.initial(config);

  final MapRepository _mapRepository;
  final TextRepository _textRepository;
  final Locale _locale;
  final MapConfig _config;

  MapViewState _state;
  bool _hasInitialized = false;

  MapViewState get state => _state;

  /// Loads attribution and finalizes initial map state; no-ops after first run.
  Future<void> initialize() async {
    if (_hasInitialized) {
      return;
    }

    // Attribution and initial map state come from assets/config; only load once.
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final texts = await Future.wait([
        _textRepository.getText(
          key: 'map_attribution',
          locale: _locale.languageCode,
        ),
        _textRepository.getText(
          key: 'map_attribution_source',
          locale: _locale.languageCode,
        ),
      ]);

      _state = _state.copyWith(
        center: _config.initialCenter,
        zoom: _config.initialZoom,
        tileSource: _config.tileSource,
        attribution: texts[0],
        attributionSource: texts[1],
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
