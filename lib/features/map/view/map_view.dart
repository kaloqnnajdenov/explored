import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:explored/features/map/data/models/map_view_state.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../translations/locale_keys.g.dart';
import '../../location/data/models/location_notification.dart';
import '../view_model/map_view_model.dart';
import 'widgets/attribution_banner.dart';
import 'widgets/location_tracking_panel.dart';
import 'widgets/location_tracking_panel_toggle.dart';

/// Map screen view; renders state from [MapViewModel] without holding logic.
class MapView extends StatefulWidget {
  const MapView({required this.viewModel, super.key});

  final MapViewModel viewModel;

  @override
  State<MapView> createState() => _MapViewState();
}

/// Bridges MapView to the ViewModel via AnimatedBuilder.
class _MapViewState extends State<MapView> with WidgetsBindingObserver {
  late final MapController _mapController;
  late final TapGestureRecognizer _attributionTapRecognizer;
  static const String _androidNotificationIcon = '@mipmap/ic_launcher';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mapController = MapController();
    _attributionTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        unawaited(widget.viewModel.openAttribution());
      };
    widget.viewModel.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _attributionTapRecognizer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.viewModel.handleAppLifecycleState(state);
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

        final notificationTitle = LocaleKeys.location_notification_title.tr();
        widget.viewModel.setBackgroundNotification(
          LocationNotification(
            title: notificationTitle,
            message:
                LocaleKeys.location_notification_message_background.tr(),
            iconName: _androidNotificationIcon,
          ),
        );

        final lastLocation = state.locationTracking.lastLocation;
        return Scaffold(
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: state.center,
                  initialZoom: state.zoom,
                ),
                children: [
                  TileLayer(
                    urlTemplate: state.tileSource.urlTemplate,
                    subdomains: state.tileSource.subdomains,
                    userAgentPackageName: state.tileSource.userAgentPackageName,
                    tileProvider: state.tileSource.tileProvider,
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
                ],
              ),
              // Keep any load errors visible without blocking the map render.
              if (state.error != null)
                const Positioned(
                  top: 16,
                  right: 16,
                  child: Icon(Icons.error_outline, color: Colors.redAccent),
                ),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: SafeArea(
                  child: _buildLocationPanel(state),
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
          onRequestForegroundPermission: () {
            unawaited(widget.viewModel.requestForegroundPermission());
          },
          onRequestBackgroundPermission: () {
            unawaited(widget.viewModel.requestBackgroundPermission());
          },
          onRequestNotificationPermission: () {
            unawaited(widget.viewModel.requestNotificationPermission());
          },
          onOpenSettings: () {
            unawaited(widget.viewModel.openAppSettings());
          },
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
              color: Colors.blue.shade200.withOpacity(0.8),
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

  void _recenterToUserLocation(MapViewState state) {
    final lastLocation = state.locationTracking.lastLocation;
    if (lastLocation == null) {
      return;
    }
    final target = LatLng(lastLocation.latitude, lastLocation.longitude);
    _mapController.move(target, state.recenterZoom);
  }
}
