import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:explored/features/map/data/models/map_view_state.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../location/data/models/lat_lng_sample.dart';
import '../../../translations/locale_keys.g.dart';
import '../view_model/map_view_model.dart';
import 'widgets/attribution_banner.dart';
import 'widgets/tracked_history_map.dart';

/// Map screen view; renders state from [MapViewModel] without holding logic.
class MapView extends StatefulWidget {
  const MapView({
    required this.viewModel,
    super.key,
    this.showBackButton = false,
    this.onBack,
  });

  final MapViewModel viewModel;
  final bool showBackButton;
  final VoidCallback? onBack;

  @override
  State<MapView> createState() => _MapViewState();
}

/// Bridges MapView to the ViewModel via AnimatedBuilder.
class _MapViewState extends State<MapView> {
  late final MapController _mapController;
  late final TapGestureRecognizer _attributionTapRecognizer;

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
                  final height =
                      constraints.maxHeight.isFinite &&
                          constraints.maxHeight > 0
                      ? constraints.maxHeight
                      : MediaQuery.sizeOf(context).height;
                  final minZoom = _minZoomForHeight(height);
                  return TrackedHistoryMap(
                    mapController: _mapController,
                    tileSource: state.tileSource,
                    persistedSamples: state.persistedSamples,
                    currentLocation: _toLatLng(lastLocation),
                    initialCenter: state.center,
                    initialZoom: state.zoom,
                    minZoom: minZoom,
                    showScaleIndicator: true,
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
              if (widget.showBackButton)
                Positioned(
                  top: 16,
                  left: 16,
                  child: SafeArea(
                    child: FloatingActionButton.small(
                      heroTag: 'map_view_back_button',
                      onPressed: widget.onBack,
                      child: const Icon(Icons.arrow_back),
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
            ],
          ),
        );
      },
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

  LatLng? _toLatLng(LatLngSample? sample) {
    if (sample == null) {
      return null;
    }
    return LatLng(sample.latitude, sample.longitude);
  }

  void _recenterToUserLocation(MapViewState state) {
    final lastLocation = state.locationTracking.lastLocation;
    if (lastLocation == null) {
      return;
    }
    final target = LatLng(lastLocation.latitude, lastLocation.longitude);
    _mapController.move(target, state.recenterZoom);
  }
}
