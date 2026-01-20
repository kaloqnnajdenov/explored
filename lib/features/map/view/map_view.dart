import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:explored/features/map/data/models/map_view_state.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../gpx_import/view/widgets/gpx_import_processing_overlay.dart';
import '../../gpx_import/view_model/gpx_import_view_model.dart';
import '../../permissions/view/permissions_management_view.dart';
import '../../permissions/view_model/permissions_view_model.dart';
import '../../../translations/locale_keys.g.dart';
import '../../visited_grid/data/models/visited_grid_bounds.dart';
import '../../visited_grid/data/models/visited_overlay_polygon.dart';
import '../view_model/map_view_model.dart';
import 'widgets/attribution_banner.dart';
import 'widgets/location_tracking_panel.dart';
import 'widgets/location_tracking_panel_toggle.dart';
import 'widgets/map_menu_button.dart';
import 'widgets/map_scale_indicator.dart';

/// Map screen view; renders state from [MapViewModel] without holding logic.
class MapView extends StatefulWidget {
  const MapView({
    required this.viewModel,
    required this.permissionsViewModel,
    required this.gpxImportViewModel,
    super.key,
  });

  final MapViewModel viewModel;
  final PermissionsViewModel permissionsViewModel;
  final GpxImportViewModel gpxImportViewModel;

  @override
  State<MapView> createState() => _MapViewState();
}

/// Bridges MapView to the ViewModel via AnimatedBuilder.
class _MapViewState extends State<MapView> {
  late final MapController _mapController;
  late final TapGestureRecognizer _attributionTapRecognizer;
  int? _lastGpxFeedbackId;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _attributionTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        unawaited(widget.viewModel.openAttribution());
      };
    widget.viewModel.initialize();
  }

  @override
  void dispose() {
    _attributionTapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        final state = widget.viewModel.state;

        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final lastLocation = state.locationTracking.lastLocation;
        return Scaffold(
          body: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final height = constraints.maxHeight.isFinite &&
                          constraints.maxHeight > 0
                      ? constraints.maxHeight
                      : MediaQuery.sizeOf(context).height;
                  final minZoom = _minZoomForHeight(height);
                  return FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: state.center,
                      initialZoom: state.zoom,
                      minZoom: minZoom,
                      onMapReady: () {
                        _handleCameraIdle(_mapController.camera);
                      },
                      onPositionChanged: (camera, hasGesture) {
                        _handleCameraChanged(camera);
                        if (!hasGesture) {
                          _handleCameraIdle(camera);
                        }
                      },
                      onMapEvent: (event) {
                        if (event is MapEventMoveEnd ||
                            event is MapEventFlingAnimationEnd ||
                            event is MapEventDoubleTapZoomEnd ||
                            event is MapEventRotateEnd) {
                          _handleCameraIdle(event.camera);
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: state.tileSource.urlTemplate,
                        subdomains: state.tileSource.subdomains,
                        userAgentPackageName:
                            state.tileSource.userAgentPackageName,
                        tileProvider: state.tileSource.tileProvider,
                      ),
                      if (state.visitedOverlayPolygons.isNotEmpty)
                        PolygonLayer(
                          polygons: _buildVisitedPolygons(context, state),
                          polygonCulling: false,
                        ),
                      if (state.importedSamples.isNotEmpty)
                        CircleLayer(
                          circles: _buildImportedCircles(state),
                        ),
                      if (lastLocation != null)
                        MarkerLayer(
                          markers: [
                            _buildLocationMarker(
                              LatLng(
                                lastLocation.latitude,
                                lastLocation.longitude,
                              ),
                            ),
                          ],
                        ),
                      const MapScaleIndicator(),
                    ],
                  );
                },
              ),
              // Keep any load errors visible without blocking the map render.
              if (state.error != null)
                const Positioned(
                  top: 16,
                  right: 72,
                  child: Icon(Icons.error_outline, color: Colors.redAccent),
                ),
              Positioned(
                top: 16,
                left: 16,
                right: 72,
                child: SafeArea(
                  child: _buildLocationPanel(state),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: SafeArea(
                  child: MapMenuButton(
                    onActionSelected: _handleMenuAction,
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                right: 16,
                child: SafeArea(
                  child: FloatingActionButton.small(
                    tooltip: LocaleKeys.map_action_recenter_location.tr(),
                    onPressed: lastLocation == null
                        ? null
                        : () => _recenterToUserLocation(state),
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AttributionBanner(
                  text: LocaleKeys.map_attribution.tr(),
                  linkLabel: LocaleKeys.map_attribution_source.tr(),
                  tapRecognizer: _attributionTapRecognizer,
                ),
              ),
              GpxImportProcessingOverlay(
                viewModel: widget.gpxImportViewModel,
              ),
              _buildGpxFeedbackListener(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationPanel(MapViewState state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: state.isLocationPanelVisible
          ? _buildExpandedLocationPanel(state)
          : _buildCollapsedLocationPanel(),
    );
  }

  Widget _buildExpandedLocationPanel(MapViewState state) {
    return Stack(
      key: const ValueKey('expanded-panel'),
      clipBehavior: Clip.none,
      children: [
        LocationTrackingPanel(
          key: const ValueKey('tracking-panel'),
          state: state.locationTracking,
        ),
        Positioned(
          top: -8,
          right: -8,
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            shape: const CircleBorder(),
            elevation: 2,
            child: IconButton(
              iconSize: 20,
              tooltip: LocaleKeys.location_panel_collapse_tooltip.tr(),
              onPressed: widget.viewModel.toggleLocationPanelVisibility,
              icon: const Icon(Icons.close),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedLocationPanel() {
    return Align(
      key: const ValueKey('collapsed-panel'),
      alignment: Alignment.centerLeft,
      child: LocationTrackingPanelToggle(
        label: LocaleKeys.location_panel_title.tr(),
        tooltip: LocaleKeys.location_panel_expand_tooltip.tr(),
        onTap: () => widget.viewModel.setLocationPanelVisibility(true),
      ),
    );
  }

  Marker _buildLocationMarker(LatLng position) {
    return Marker(
      point: position,
      width: 28,
      height: 28,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue.shade400,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade200.withValues(alpha: 0.8),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.circle,
            color: Colors.white70,
            size: 12,
          ),
        ),
      ),
    );
  }

  List<Polygon> _buildVisitedPolygons(
    BuildContext context,
    MapViewState state,
  ) {
    final fill = Theme.of(context).colorScheme.primary.withValues(alpha: 0.25);
    final border = Theme.of(context).colorScheme.primary.withValues(alpha: 0.55);
    return state.visitedOverlayPolygons
        .map(
          (polygon) => Polygon(
            points: polygon.outer,
            holePointsList: polygon.holes.isEmpty ? null : polygon.holes,
            color: fill,
            borderColor: border,
            borderStrokeWidth: 0.7,
          ),
        )
        .toList(growable: false);
  }

  List<CircleMarker> _buildImportedCircles(MapViewState state) {
    return [
      for (final sample in state.importedSamples)
        CircleMarker(
          point: LatLng(sample.latitude, sample.longitude),
          radius: 4,
          color: Colors.orangeAccent.withValues(alpha: 0.65),
          borderColor: Colors.white.withValues(alpha: 0.8),
          borderStrokeWidth: 1,
        ),
    ];
  }

  void _handleCameraChanged(MapCamera camera) {
    widget.viewModel.onCameraChanged(
      bounds: _boundsFromCamera(camera),
      zoom: camera.zoom,
    );
  }

  void _handleCameraIdle(MapCamera camera) {
    widget.viewModel.onCameraIdle(
      bounds: _boundsFromCamera(camera),
      zoom: camera.zoom,
    );
  }

  VisitedGridBounds _boundsFromCamera(MapCamera camera) {
    return VisitedGridBounds(
      north: camera.visibleBounds.north,
      south: camera.visibleBounds.south,
      east: camera.visibleBounds.east,
      west: camera.visibleBounds.west,
    );
  }

  double _minZoomForHeight(double height) {
    if (height <= 0) {
      return 0;
    }

    final zoom = const Epsg3857().zoom(height);
    if (!zoom.isFinite) {
      return 0;
    }

    return zoom < 0 ? 0 : zoom;
  }

  void _recenterToUserLocation(MapViewState state) {
    final lastLocation = state.locationTracking.lastLocation;
    if (lastLocation == null) {
      return;
    }
    final target = LatLng(lastLocation.latitude, lastLocation.longitude);
    _mapController.move(target, state.recenterZoom);
  }

  Widget _buildGpxFeedbackListener() {
    return AnimatedBuilder(
      animation: widget.gpxImportViewModel,
      builder: (context, _) {
        final feedback = widget.gpxImportViewModel.state.feedback;
        if (feedback == null || feedback.id == _lastGpxFeedbackId) {
          return const SizedBox.shrink();
        }
        _lastGpxFeedbackId = feedback.id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                feedback.messageKey.tr(namedArgs: feedback.namedArgs ?? {}),
              ),
              backgroundColor: feedback.isError
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
          );
        });
        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _handleMenuAction(MapMenuAction action) async {
    switch (action) {
      case MapMenuAction.permissions:
        await _openPermissions();
        break;
      case MapMenuAction.importGpx:
        await _openGpxImport();
        break;
    }
  }

  Future<void> _openGpxImport() async {
    await Future<void>.delayed(Duration.zero);
    if (!mounted) {
      return;
    }
    await widget.gpxImportViewModel.importGpx();
  }

  Future<void> _openPermissions() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => PermissionsManagementView(
        viewModel: widget.permissionsViewModel,
      ),
    );
  }
}
