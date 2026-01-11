import 'package:latlong2/latlong.dart';

import 'map_config.dart';
import 'map_tile_source.dart';
import '../../../location/data/models/location_tracking_state.dart';

/// Immutable UI state snapshot for the map screen.
class MapViewState {
  const MapViewState({
    required this.center,
    required this.zoom,
    required this.tileSource,
    required this.locationTracking,
    required this.isLoading,
    required this.isLocationPanelVisible,
    required this.recenterZoom,
    this.error,
  });

  /// Seed state using the map config before async work finishes.
  factory MapViewState.initial(MapConfig config) {
    return MapViewState(
      center: config.initialCenter,
      zoom: config.initialZoom,
      tileSource: config.tileSource,
      locationTracking: LocationTrackingState.initial(),
      isLoading: true,
      isLocationPanelVisible: true,
      recenterZoom: config.recenterZoom,
    );
  }

  final LatLng center;
  final double zoom;
  final MapTileSource tileSource;
  final LocationTrackingState locationTracking;
  final bool isLoading;
  final bool isLocationPanelVisible;
  final double recenterZoom;
  final Object? error;

  /// Create a new state with selective overrides; errors can be cleared.
  MapViewState copyWith({
    LatLng? center,
    double? zoom,
    MapTileSource? tileSource,
    LocationTrackingState? locationTracking,
    bool? isLoading,
    bool? isLocationPanelVisible,
    double? recenterZoom,
    Object? error,
    bool clearError = false,
  }) {
    return MapViewState(
      center: center ?? this.center,
      zoom: zoom ?? this.zoom,
      tileSource: tileSource ?? this.tileSource,
      locationTracking: locationTracking ?? this.locationTracking,
      isLoading: isLoading ?? this.isLoading,
      isLocationPanelVisible:
          isLocationPanelVisible ?? this.isLocationPanelVisible,
      recenterZoom: recenterZoom ?? this.recenterZoom,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
