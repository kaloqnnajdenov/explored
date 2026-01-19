import 'package:latlong2/latlong.dart';

import 'map_config.dart';
import 'map_tile_source.dart';
import '../../../location/data/models/location_tracking_state.dart';
import '../../../location/data/models/lat_lng_sample.dart';
import '../../../visited_grid/data/models/visited_time_filter.dart';
import '../../../visited_grid/data/models/visited_overlay_polygon.dart';

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
    required this.visitedOverlayPolygons,
    required this.isOverlayLoading,
    required this.visitedTimeFilter,
    required this.overlayResolution,
    required this.importedSamples,
    this.error,
    this.overlayError,
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
      visitedOverlayPolygons: const [],
      isOverlayLoading: false,
      visitedTimeFilter: VisitedTimeFilter.allTime,
      overlayResolution: null,
      importedSamples: const [],
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
  final List<VisitedOverlayPolygon> visitedOverlayPolygons;
  final bool isOverlayLoading;
  final VisitedTimeFilter visitedTimeFilter;
  final int? overlayResolution;
  final List<LatLngSample> importedSamples;
  final Object? overlayError;

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
    List<VisitedOverlayPolygon>? visitedOverlayPolygons,
    bool? isOverlayLoading,
    VisitedTimeFilter? visitedTimeFilter,
    int? overlayResolution,
    List<LatLngSample>? importedSamples,
    Object? overlayError,
    bool clearOverlayError = false,
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
      visitedOverlayPolygons:
          visitedOverlayPolygons ?? this.visitedOverlayPolygons,
      isOverlayLoading: isOverlayLoading ?? this.isOverlayLoading,
      visitedTimeFilter: visitedTimeFilter ?? this.visitedTimeFilter,
      overlayResolution: overlayResolution ?? this.overlayResolution,
      importedSamples: importedSamples ?? this.importedSamples,
      overlayError:
          clearOverlayError ? null : (overlayError ?? this.overlayError),
    );
  }
}
