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
    this.initialCameraFit,
    this.showScaleIndicator = false,
    this.maxRenderedSamples = 4000,
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
  final CameraFit? initialCameraFit;
  final bool showScaleIndicator;
  final int maxRenderedSamples;

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
        initialCameraFit: widget.initialCameraFit,
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

    final step = _sampleStep(samples.length);
    _lastPersistedSamples = samples;
    _cachedPersistedCircles = [
      for (var index = 0; index < samples.length; index += step)
        _buildPersistedCircle(samples[index]),
      if (samples.isNotEmpty && (samples.length - 1) % step != 0)
        _buildPersistedCircle(samples.last),
    ];
    return _cachedPersistedCircles;
  }

  int _sampleStep(int sampleCount) {
    if (widget.maxRenderedSamples <= 0 ||
        sampleCount <= widget.maxRenderedSamples) {
      return 1;
    }
    return (sampleCount / widget.maxRenderedSamples).ceil();
  }

  CircleMarker _buildPersistedCircle(LatLngSample sample) {
    return CircleMarker(
      point: LatLng(sample.latitude, sample.longitude),
      radius: 2,
      color: Colors.orangeAccent.withValues(alpha: 0.55),
      borderColor: Colors.white.withValues(alpha: 0.65),
      borderStrokeWidth: 0.5,
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
          child: Icon(Icons.circle, color: Colors.white70, size: 12),
        ),
      ),
    );
  }
}
