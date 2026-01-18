import 'dart:async';

import 'package:latlong2/latlong.dart';

import 'package:explored/domain/usecases/h3_overlay_worker.dart';

import '../data/models/visited_grid_bounds.dart';
import '../data/models/visited_overlay_mode.dart';
import '../data/models/visited_overlay_polygon.dart';
import '../data/models/visited_overlay_render_mode.dart';
import 'h3_boundary_cache.dart';

typedef CellBoundaryResolver = List<LatLng> Function(String cellId);

class CameraState {
  const CameraState({required this.bounds, required this.zoom});

  final VisitedGridBounds bounds;
  final double zoom;
}

class VisitedOverlayUpdate {
  const VisitedOverlayUpdate({
    required this.polygons,
    required this.resolution,
    required this.addedCellIds,
    required this.removedCellIds,
  });

  final List<VisitedOverlayPolygon> polygons;
  final int resolution;
  final Set<String> addedCellIds;
  final Set<String> removedCellIds;
}

class OverlayDiff {
  const OverlayDiff({
    required this.added,
    required this.removed,
  });

  final Set<String> added;
  final Set<String> removed;

  bool get isEmpty => added.isEmpty && removed.isEmpty;
}

OverlayDiff computeOverlayDiff(Set<String> current, Set<String> next) {
  final added = next.difference(current);
  final removed = current.difference(next);
  return OverlayDiff(added: added, removed: removed);
}

class VisitedOverlayController {
  VisitedOverlayController({
    required VisitedOverlayWorker worker,
    required CellBoundaryResolver boundaryResolver,
    required H3BoundaryCache boundaryCache,
    required void Function(VisitedOverlayUpdate update) onOverlayUpdated,
    void Function(Object error)? onOverlayError,
    void Function(bool isLoading)? onLoadingChanged,
    OverlayMode initialMode = const OverlayModeAllTime(),
    Duration debounceDuration = const Duration(milliseconds: 200),
    Duration patchDebounceDuration = const Duration(milliseconds: 200),
  })  : _worker = worker,
        _boundaryResolver = boundaryResolver,
        _boundaryCache = boundaryCache,
        _onOverlayUpdated = onOverlayUpdated,
        _onOverlayError = onOverlayError,
        _onLoadingChanged = onLoadingChanged,
        _mode = initialMode,
        _debounceDuration = debounceDuration,
        _patchDebounceDuration = patchDebounceDuration;

  final VisitedOverlayWorker _worker;
  final CellBoundaryResolver _boundaryResolver;
  final H3BoundaryCache _boundaryCache;
  final void Function(VisitedOverlayUpdate update) _onOverlayUpdated;
  final void Function(Object error)? _onOverlayError;
  final void Function(bool isLoading)? _onLoadingChanged;
  final Duration _debounceDuration;
  final Duration _patchDebounceDuration;

  final Map<String, VisitedOverlayPolygon> _visiblePolygons = {};
  List<VisitedOverlayPolygon> _currentPolygons = const [];
  Set<String> _currentVisible = <String>{};
  OverlayMode _mode;
  VisitedOverlayRenderMode _currentRenderMode =
      VisitedOverlayRenderMode.perCell;
  CameraState? _lastCameraState;
  Timer? _debounceTimer;
  Timer? _patchDebounceTimer;
  int _nextRequestId = 0;
  int _latestRequestId = 0;
  int? _currentResolution;
  bool _isLoading = false;
  bool _pendingRefresh = false;
  bool _disposed = false;

  void onCameraChanged(CameraState state) {
    if (_disposed) {
      return;
    }
    _lastCameraState = state;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      unawaited(_refreshOverlay());
    });
  }

  void onCameraIdle(CameraState state) {
    if (_disposed) {
      return;
    }
    _lastCameraState = state;
    _debounceTimer?.cancel();
    unawaited(_refreshOverlay());
  }

  void setMode(OverlayMode mode) {
    if (_mode == mode || _disposed) {
      return;
    }
    _mode = mode;
    unawaited(_refreshOverlay());
  }

  void patchVisitedCell({
    required String cellId,
    required int resolution,
  }) {
    if (_disposed) {
      return;
    }
    if (_currentResolution != resolution) {
      return;
    }
    if (_currentRenderMode == VisitedOverlayRenderMode.merged) {
      _scheduleMergedRefresh();
      return;
    }
    if (_currentVisible.contains(cellId)) {
      return;
    }
    final cameraState = _lastCameraState;
    if (cameraState == null) {
      return;
    }

    _currentVisible.add(cellId);
    final polygon = _polygonFor(cellId);
    if (!_ringIntersectsBounds(polygon.outer, cameraState.bounds)) {
      _currentVisible.remove(cellId);
      return;
    }
    _visiblePolygons[cellId] = polygon;
    _emitUpdate(
      OverlayDiff(added: {cellId}, removed: const <String>{}),
      resolution,
      _visiblePolygons.values.toList(growable: false),
    );
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _debounceTimer?.cancel();
    _patchDebounceTimer?.cancel();
    await _worker.dispose();
  }

  Future<void> _refreshOverlay() async {
    if (_disposed) {
      return;
    }
    final cameraState = _lastCameraState;
    if (cameraState == null) {
      return;
    }
    if (_isLoading) {
      _pendingRefresh = true;
      return;
    }
    _pendingRefresh = false;
    _patchDebounceTimer?.cancel();

    final requestId = ++_nextRequestId;
    _latestRequestId = requestId;
    _setLoading(true);

    try {
      final result = await _worker.queryOverlay(
        requestId: requestId,
        bounds: cameraState.bounds,
        zoom: cameraState.zoom,
        mode: _mode,
      );
      if (_disposed || _latestRequestId != requestId) {
        return;
      }
      _applyResult(result);
    } catch (error) {
      if (_disposed || _latestRequestId != requestId) {
        return;
      }
      _onOverlayError?.call(error);
    } finally {
      if (!_disposed && _latestRequestId == requestId) {
        _setLoading(false);
      }
      if (!_disposed && _pendingRefresh) {
        unawaited(_refreshOverlay());
      }
    }
  }

  void _applyResult(H3OverlayResult result) {
    final resolutionChanged = _currentResolution != result.resolution;
    final modeChanged = _currentRenderMode != result.renderMode;
    _currentResolution = result.resolution;

    if (modeChanged) {
      _visiblePolygons.clear();
      _currentVisible = <String>{};
    }
    _currentRenderMode = result.renderMode;

    if (result.renderMode == VisitedOverlayRenderMode.perCell) {
      final nextVisible = Set<String>.from(result.visitedCellIds);
      final diff = computeOverlayDiff(_currentVisible, nextVisible);
      for (final cellId in diff.added) {
        _visiblePolygons[cellId] = _polygonFor(cellId);
      }
      for (final cellId in diff.removed) {
        _visiblePolygons.remove(cellId);
      }
      _currentVisible = nextVisible;
      _currentPolygons = _visiblePolygons.values.toList(growable: false);
      if (!diff.isEmpty || resolutionChanged || modeChanged) {
        _emitUpdate(diff, result.resolution, _currentPolygons);
      }
      return;
    }

    _currentVisible = Set<String>.from(result.visitedCellIds);
    _currentPolygons = _polygonsFromMulti(result.mergedPolygons);
    _emitUpdate(
      const OverlayDiff(added: <String>{}, removed: <String>{}),
      result.resolution,
      _currentPolygons,
    );
  }

  VisitedOverlayPolygon _polygonFor(String cellId) {
    final cached = _boundaryCache.get(cellId);
    if (cached != null) {
      return VisitedOverlayPolygon(outer: cached);
    }
    final boundary = _unwrapRing(_boundaryResolver(cellId));
    _boundaryCache.put(cellId, boundary);
    return VisitedOverlayPolygon(outer: boundary);
  }

  void _emitUpdate(
    OverlayDiff diff,
    int resolution,
    List<VisitedOverlayPolygon> polygons,
  ) {
    _onOverlayUpdated(
      VisitedOverlayUpdate(
        polygons: polygons,
        resolution: resolution,
        addedCellIds: Set.unmodifiable(diff.added),
        removedCellIds: Set.unmodifiable(diff.removed),
      ),
    );
  }

  void _scheduleMergedRefresh() {
    _pendingRefresh = true;
    _patchDebounceTimer?.cancel();
    _patchDebounceTimer = Timer(_patchDebounceDuration, () {
      if (_disposed) {
        return;
      }
      unawaited(_refreshOverlay());
    });
  }

  List<VisitedOverlayPolygon> _polygonsFromMulti(
    List<List<List<List<double>>>> multiPolygons,
  ) {
    final result = <VisitedOverlayPolygon>[];
    for (final polygon in multiPolygons) {
      if (polygon.isEmpty) {
        continue;
      }
      final outer = _toRing(polygon.first);
      final holes = <List<LatLng>>[];
      for (final ring in polygon.skip(1)) {
        holes.add(_toRing(ring));
      }
      result.add(VisitedOverlayPolygon(outer: outer, holes: holes));
    }
    return result;
  }

  List<LatLng> _toRing(List<List<double>> ring) {
    if (ring.isEmpty) {
      return const [];
    }
    final points = [
      for (final coord in ring) LatLng(coord[0], coord[1]),
    ];
    return _unwrapRing(points);
  }

  void _setLoading(bool isLoading) {
    if (_isLoading == isLoading) {
      return;
    }
    _isLoading = isLoading;
    _onLoadingChanged?.call(isLoading);
  }
}

class _LonRange {
  const _LonRange(this.min, this.max);

  final double min;
  final double max;
}

List<LatLng> _unwrapRing(List<LatLng> ring) {
  if (ring.isEmpty) {
    return ring;
  }
  final unwrapped = <LatLng>[ring.first];
  var prevLon = ring.first.longitude;
  var offset = 0.0;
  for (var i = 1; i < ring.length; i++) {
    var lon = ring[i].longitude + offset;
    final delta = lon - prevLon;
    if (delta > 180) {
      offset -= 360;
      lon -= 360;
    } else if (delta < -180) {
      offset += 360;
      lon += 360;
    }
    unwrapped.add(LatLng(ring[i].latitude, lon));
    prevLon = lon;
  }
  return unwrapped;
}

bool _ringIntersectsBounds(List<LatLng> ring, VisitedGridBounds bounds) {
  if (ring.isEmpty) {
    return false;
  }

  var minLat = ring.first.latitude;
  var maxLat = ring.first.latitude;
  var minLon = ring.first.longitude;
  var maxLon = ring.first.longitude;

  for (var i = 1; i < ring.length; i++) {
    final point = ring[i];
    if (point.latitude < minLat) {
      minLat = point.latitude;
    }
    if (point.latitude > maxLat) {
      maxLat = point.latitude;
    }
    if (point.longitude < minLon) {
      minLon = point.longitude;
    }
    if (point.longitude > maxLon) {
      maxLon = point.longitude;
    }
  }

  if (maxLat < bounds.south || minLat > bounds.north) {
    return false;
  }

  final ringCenter = (minLon + maxLon) / 2;
  final ranges = bounds.east >= bounds.west
      ? [_LonRange(bounds.west, bounds.east)]
      : [
          _LonRange(bounds.west, 180),
          _LonRange(-180, bounds.east),
        ];

  for (final range in ranges) {
    final shifted = _shiftRangeToCenter(range, ringCenter);
    if (maxLon >= shifted.min && minLon <= shifted.max) {
      return true;
    }
  }
  return false;
}

double _unwrapLonToCenter(double lon, double center) {
  var unwrapped = lon;
  while (unwrapped - center > 180) {
    unwrapped -= 360;
  }
  while (unwrapped - center < -180) {
    unwrapped += 360;
  }
  return unwrapped;
}

_LonRange _shiftRangeToCenter(_LonRange range, double center) {
  final rangeCenter = (range.min + range.max) / 2;
  final shiftedCenter = _unwrapLonToCenter(rangeCenter, center);
  final shift = shiftedCenter - rangeCenter;
  return _LonRange(range.min + shift, range.max + shift);
}
