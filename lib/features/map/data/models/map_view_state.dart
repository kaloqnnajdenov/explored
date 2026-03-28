import 'package:latlong2/latlong.dart';

import '../../../../domain/entities/entity.dart';
import '../../../../domain/shared/entity_boundary.dart';
import 'map_config.dart';
import 'map_point_of_interest.dart';
import 'map_tile_source.dart';
import '../../../location/data/models/location_tracking_state.dart';
import '../../../location/data/models/lat_lng_sample.dart';

class MapViewState {
  const MapViewState({
    required this.center,
    required this.zoom,
    required this.tileSource,
    required this.locationTracking,
    required this.isLoading,
    required this.isLocationPanelVisible,
    required this.recenterZoom,
    required this.persistedSamples,
    required this.pointsOfInterest,
    this.selectedEntity,
    this.selectedBoundary,
    this.selectedParentBoundary,
    this.exportFeedback,
    this.error,
  });

  factory MapViewState.initial(MapConfig config) {
    return MapViewState(
      center: config.initialCenter,
      zoom: config.initialZoom,
      tileSource: config.tileSource,
      locationTracking: LocationTrackingState.initial(),
      isLoading: true,
      isLocationPanelVisible: true,
      recenterZoom: config.recenterZoom,
      persistedSamples: const [],
      pointsOfInterest: const [],
      exportFeedback: null,
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
  final List<LatLngSample> persistedSamples;
  final List<MapPointOfInterest> pointsOfInterest;
  final Entity? selectedEntity;
  final EntityBoundary? selectedBoundary;
  final EntityBoundary? selectedParentBoundary;
  final MapViewFeedback? exportFeedback;

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
    List<LatLngSample>? persistedSamples,
    List<MapPointOfInterest>? pointsOfInterest,
    Entity? selectedEntity,
    bool clearSelectedEntity = false,
    EntityBoundary? selectedBoundary,
    EntityBoundary? selectedParentBoundary,
    MapViewFeedback? exportFeedback,
    bool clearExportFeedback = false,
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
      persistedSamples: persistedSamples ?? this.persistedSamples,
      pointsOfInterest: pointsOfInterest ?? this.pointsOfInterest,
      selectedEntity: clearSelectedEntity
          ? null
          : (selectedEntity ?? this.selectedEntity),
      selectedBoundary: selectedBoundary ?? this.selectedBoundary,
      selectedParentBoundary:
          selectedParentBoundary ?? this.selectedParentBoundary,
      exportFeedback: clearExportFeedback
          ? null
          : (exportFeedback ?? this.exportFeedback),
    );
  }
}

class MapViewFeedback {
  const MapViewFeedback({
    required this.id,
    required this.messageKey,
    this.isError = false,
  });

  final int id;
  final String messageKey;
  final bool isError;
}
