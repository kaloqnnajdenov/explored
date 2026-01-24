import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:explored/features/map/data/models/map_view_state.dart';
import 'package:explored/features/map/data/models/overlay_tile_size.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../gpx_import/view/widgets/gpx_import_processing_overlay.dart';
import '../../gpx_import/view_model/gpx_import_view_model.dart';
import '../../permissions/view/permissions_management_view.dart';
import '../../permissions/view_model/permissions_view_model.dart';
import '../../../translations/locale_keys.g.dart';
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
  int? _lastExportFeedbackId;

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
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: state.tileSource.urlTemplate,
                        subdomains: state.tileSource.subdomains,
                        userAgentPackageName:
                            state.tileSource.userAgentPackageName,
                        tileProvider: state.tileSource.tileProvider,
                      ),
                      TileLayer(
                        tileProvider: widget.viewModel.overlayTileProvider,
                        tileSize: state.overlayTileSize.size.toDouble(),
                        maxNativeZoom: 19,
                        keepBuffer: 2,
                        panBuffer: 1,
                        tileDisplay:
                            const TileDisplay.instantaneous(opacity: 1),
                        reset: widget.viewModel.overlayResetStream,
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
              _buildExportFeedbackListener(),
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
      case MapMenuAction.exportHistory:
        await widget.viewModel.exportHistory();
        break;
      case MapMenuAction.downloadHistory:
        await widget.viewModel.downloadHistory();
        break;
      case MapMenuAction.exploredArea:
        await _openExploredArea();
        break;
      case MapMenuAction.overlayTileSize:
        await _openOverlayTileSize();
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

  Future<void> _openExploredArea() async {
    await Future<void>.delayed(Duration.zero);
    if (!mounted) {
      return;
    }
    context.push('/explored-area');
  }

  Future<void> _openOverlayTileSize() async {
    final selected = await showModalBottomSheet<OverlayTileSize>(
      context: context,
      showDragHandle: true,
      builder: (_) => _OverlayTileSizeSheet(
        current: widget.viewModel.state.overlayTileSize,
      ),
    );
    if (!mounted || selected == null) {
      return;
    }
    await widget.viewModel.setOverlayTileSize(selected);
  }

  Widget _buildExportFeedbackListener() {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        final feedback = widget.viewModel.state.exportFeedback;
        if (feedback == null || feedback.id == _lastExportFeedbackId) {
          return const SizedBox.shrink();
        }
        _lastExportFeedbackId = feedback.id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(feedback.messageKey.tr()),
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
}

class _OverlayTileSizeSheet extends StatelessWidget {
  const _OverlayTileSizeSheet({required this.current});

  final OverlayTileSize current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: RadioGroup<OverlayTileSize>(
          groupValue: current,
          onChanged: (value) {
            if (value == null) {
              return;
            }
            Navigator.of(context).pop(value);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  LocaleKeys.overlay_tile_size_title.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              RadioListTile<OverlayTileSize>(
                value: OverlayTileSize.s256,
                title: Text(LocaleKeys.overlay_tile_size_256.tr()),
              ),
              RadioListTile<OverlayTileSize>(
                value: OverlayTileSize.s512,
                title: Text(LocaleKeys.overlay_tile_size_512.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
