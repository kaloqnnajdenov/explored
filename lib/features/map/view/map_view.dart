import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../view_model/map_view_model.dart';

/// Map screen view; renders state from [MapViewModel] without holding logic.
class MapView extends StatefulWidget {
  const MapView({required this.viewModel, super.key});

  final MapViewModel viewModel;

  @override
  State<MapView> createState() => _MapViewState();
}

/// Bridges MapView to the ViewModel via AnimatedBuilder.
class _MapViewState extends State<MapView> {
  late final TapGestureRecognizer _attributionTapRecognizer;

  @override
  void initState() {
    super.initState();
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
              if (state.attribution.isNotEmpty &&
                  state.attributionSource.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _AttributionBanner(
                    text: state.attribution,
                    linkLabel: state.attributionSource,
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

class _AttributionBanner extends StatelessWidget {
  const _AttributionBanner({
    required this.text,
    required this.linkLabel,
    required this.tapRecognizer,
  });

  final String text;
  final String linkLabel;
  final GestureRecognizer tapRecognizer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface,
    );

    return SafeArea(
      minimum: const EdgeInsets.all(12),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: RichText(
              text: TextSpan(
                style: baseStyle,
                children: [
                  TextSpan(text: '$text '),
                  TextSpan(
                    text: linkLabel,
                    style: baseStyle?.copyWith(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: tapRecognizer,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
