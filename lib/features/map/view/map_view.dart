import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../translations/locale_keys.g.dart';
import '../../location/data/models/location_notification.dart';
import '../view_model/map_view_model.dart';
import 'widgets/attribution_banner.dart';
import 'widgets/location_tracking_panel.dart';

/// Map screen view; renders state from [MapViewModel] without holding logic.
class MapView extends StatefulWidget {
  const MapView({required this.viewModel, super.key});

  final MapViewModel viewModel;

  @override
  State<MapView> createState() => _MapViewState();
}

/// Bridges MapView to the ViewModel via AnimatedBuilder.
class _MapViewState extends State<MapView> with WidgetsBindingObserver {
  late final TapGestureRecognizer _attributionTapRecognizer;
  static const String _androidNotificationIcon = '@mipmap/ic_launcher';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

        return Scaffold(
          body: Stack(
            children: [
              FlutterMap(
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
                  child: LocationTrackingPanel(
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
}
