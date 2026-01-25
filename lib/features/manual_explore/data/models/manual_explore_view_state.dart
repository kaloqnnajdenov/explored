import 'package:latlong2/latlong.dart';

import '../../../map/data/models/map_config.dart';
import '../../../map/data/models/map_tile_source.dart';
import '../../../map/data/models/overlay_tile_size.dart';
import 'manual_explore_mode.dart';

class ManualExploreViewState {
  const ManualExploreViewState({
    required this.center,
    required this.zoom,
    required this.tileSource,
    required this.overlayTileSize,
    required this.mode,
    required this.isControlPanelCollapsed,
    required this.applyDateTimeLocal,
    required this.isLoading,
    required this.isSaving,
    required this.canUndo,
    required this.canRedo,
    required this.hasChanges,
    required this.stagedAddCount,
    required this.stagedDeleteCount,
    required this.addPolygons,
    required this.deletePolygons,
    this.error,
  });

  factory ManualExploreViewState.initial(MapConfig config) {
    return ManualExploreViewState(
      center: config.initialCenter,
      zoom: config.initialZoom,
      tileSource: config.tileSource,
      overlayTileSize: OverlayTileSize.s256,
      mode: ManualExploreMode.add,
      isControlPanelCollapsed: false,
      applyDateTimeLocal: null,
      isLoading: true,
      isSaving: false,
      canUndo: false,
      canRedo: false,
      hasChanges: false,
      stagedAddCount: 0,
      stagedDeleteCount: 0,
      addPolygons: const [],
      deletePolygons: const [],
      error: null,
    );
  }

  final LatLng center;
  final double zoom;
  final MapTileSource tileSource;
  final OverlayTileSize overlayTileSize;
  final ManualExploreMode mode;
  final bool isControlPanelCollapsed;
  final DateTime? applyDateTimeLocal;
  final bool isLoading;
  final bool isSaving;
  final bool canUndo;
  final bool canRedo;
  final bool hasChanges;
  final int stagedAddCount;
  final int stagedDeleteCount;
  final List<List<LatLng>> addPolygons;
  final List<List<LatLng>> deletePolygons;
  final Object? error;

  ManualExploreViewState copyWith({
    LatLng? center,
    double? zoom,
    MapTileSource? tileSource,
    OverlayTileSize? overlayTileSize,
    ManualExploreMode? mode,
    bool? isControlPanelCollapsed,
    DateTime? applyDateTimeLocal,
    bool setApplyDateTimeLocal = false,
    bool? isLoading,
    bool? isSaving,
    bool? canUndo,
    bool? canRedo,
    bool? hasChanges,
    int? stagedAddCount,
    int? stagedDeleteCount,
    List<List<LatLng>>? addPolygons,
    List<List<LatLng>>? deletePolygons,
    Object? error,
    bool clearError = false,
  }) {
    return ManualExploreViewState(
      center: center ?? this.center,
      zoom: zoom ?? this.zoom,
      tileSource: tileSource ?? this.tileSource,
      overlayTileSize: overlayTileSize ?? this.overlayTileSize,
      mode: mode ?? this.mode,
      isControlPanelCollapsed:
          isControlPanelCollapsed ?? this.isControlPanelCollapsed,
      applyDateTimeLocal: setApplyDateTimeLocal
          ? applyDateTimeLocal
          : this.applyDateTimeLocal,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
      hasChanges: hasChanges ?? this.hasChanges,
      stagedAddCount: stagedAddCount ?? this.stagedAddCount,
      stagedDeleteCount: stagedDeleteCount ?? this.stagedDeleteCount,
      addPolygons: addPolygons ?? this.addPolygons,
      deletePolygons: deletePolygons ?? this.deletePolygons,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
