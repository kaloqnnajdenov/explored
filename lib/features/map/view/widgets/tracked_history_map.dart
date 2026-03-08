import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../location/data/models/lat_lng_sample.dart';
import '../../data/models/map_tile_source.dart';
import 'map_scale_indicator.dart';

typedef TrackedHistoryMapTapCallback =
    void Function(TapPosition tapPosition, LatLng latLng);

typedef TrackedHistoryMapPositionChangedCallback =
    void Function(MapCamera position, bool hasGesture);

/// Shared map canvas with tile + tracked GPS overlays.
class TrackedHistoryMap extends StatefulWidget {
  const TrackedHistoryMap({
    required this.tileSource,
    required this.persistedSamples,
    required this.initialCenter,
    required this.initialZoom,
    super.key,
    this.currentLocation,
    this.mapController,
    this.minZoom,
    this.interactionOptions,
    this.onTap,
    this.onPositionChanged,
    this.baseLayers = const <Widget>[],
    this.showScaleIndicator = false,
  });

  final MapTileSource tileSource;
  final List<LatLngSample> persistedSamples;
  final LatLng? currentLocation;
  final LatLng initialCenter;
  final double initialZoom;
  final MapController? mapController;
  final double? minZoom;
  final InteractionOptions? interactionOptions;
  final TrackedHistoryMapTapCallback? onTap;
  final TrackedHistoryMapPositionChangedCallback? onPositionChanged;
  final List<Widget> baseLayers;
  final bool showScaleIndicator;

  @override
  State<TrackedHistoryMap> createState() => _TrackedHistoryMapState();
}

class _TrackedHistoryMapState extends State<TrackedHistoryMap> {
  List<LatLngSample>? _lastPersistedSamples;
  List<CircleMarker> _cachedPersistedCircles = const [];

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        initialCenter: widget.initialCenter,
        initialZoom: widget.initialZoom,
        minZoom: widget.minZoom,
        interactionOptions:
            widget.interactionOptions ?? const InteractionOptions(),
        onTap: widget.onTap,
        onPositionChanged: widget.onPositionChanged,
      ),
      children: [
        TileLayer(
          urlTemplate: widget.tileSource.urlTemplate,
          subdomains: widget.tileSource.subdomains,
          userAgentPackageName: widget.tileSource.userAgentPackageName,
          tileProvider: widget.tileSource.tileProvider,
        ),
        ...widget.baseLayers,
        if (widget.persistedSamples.isNotEmpty)
          CircleLayer(circles: _buildPersistedCircles()),
        if (widget.currentLocation != null)
          MarkerLayer(markers: [_buildLocationMarker(widget.currentLocation!)]),
        if (widget.showScaleIndicator) const MapScaleIndicator(),
      ],
    );
  }

  List<CircleMarker> _buildPersistedCircles() {
    final samples = widget.persistedSamples;
    if (identical(_lastPersistedSamples, samples)) {
      return _cachedPersistedCircles;
    }

    _lastPersistedSamples = samples;
    _cachedPersistedCircles = [
      for (final sample in samples)
        CircleMarker(
          point: LatLng(sample.latitude, sample.longitude),
          radius: 2,
          color: Colors.orangeAccent.withValues(alpha: 0.55),
          borderColor: Colors.white.withValues(alpha: 0.65),
          borderStrokeWidth: 0.5,
        ),
    ];
    return _cachedPersistedCircles;
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
          child: Icon(Icons.circle, color: Colors.white70, size: 12),
        ),
      ),
    );
  }
}
