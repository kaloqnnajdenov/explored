import 'package:latlong2/latlong.dart';

import 'map_config.dart';
import 'map_tile_source.dart';

/// Immutable UI state snapshot for the map screen.
class MapViewState {
  const MapViewState({
    required this.center,
    required this.zoom,
    required this.tileSource,
    required this.attribution,
    required this.attributionSource,
    required this.isLoading,
    this.error,
  });

  /// Seed state using the map config before async work finishes.
  factory MapViewState.initial(MapConfig config) {
    return MapViewState(
      center: config.initialCenter,
      zoom: config.initialZoom,
      tileSource: config.tileSource,
      attribution: '',
      attributionSource: '',
      isLoading: true,
    );
  }

  final LatLng center;
  final double zoom;
  final MapTileSource tileSource;
  final String attribution;
  final String attributionSource;
  final bool isLoading;
  final Object? error;

  /// Create a new state with selective overrides; errors can be cleared.
  MapViewState copyWith({
    LatLng? center,
    double? zoom,
    MapTileSource? tileSource,
    String? attribution,
    String? attributionSource,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return MapViewState(
      center: center ?? this.center,
      zoom: zoom ?? this.zoom,
      tileSource: tileSource ?? this.tileSource,
      attribution: attribution ?? this.attribution,
      attributionSource: attributionSource ?? this.attributionSource,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
