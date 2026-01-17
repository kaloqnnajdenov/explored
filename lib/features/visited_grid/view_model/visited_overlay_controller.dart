import 'dart:async';

import 'package:latlong2/latlong.dart';

import 'package:explored/domain/usecases/h3_overlay_worker.dart';

import '../data/models/visited_grid_bounds.dart';
import '../data/models/visited_overlay_mode.dart';
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

  final List<List<LatLng>> polygons;
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
  })  : _worker = worker,
        _boundaryResolver = boundaryResolver,
        _boundaryCache = boundaryCache,
        _onOverlayUpdated = onOverlayUpdated,
        _onOverlayError = onOverlayError,
        _onLoadingChanged = onLoadingChanged,
        _mode = initialMode,
        _debounceDuration = debounceDuration;

  final VisitedOverlayWorker _worker;
  final CellBoundaryResolver _boundaryResolver;
  final H3BoundaryCache _boundaryCache;
  final void Function(VisitedOverlayUpdate update) _onOverlayUpdated;
  final void Function(Object error)? _onOverlayError;
  final void Function(bool isLoading)? _onLoadingChanged;
  final Duration _debounceDuration;

  final Map<String, List<LatLng>> _visiblePolygons = {};
  Set<String> _currentVisible = <String>{};
  Set<String> _currentCandidates = <String>{};
  OverlayMode _mode;
  CameraState? _lastCameraState;
  Timer? _debounceTimer;
  int _nextRequestId = 0;
  int _latestRequestId = 0;
  int? _currentResolution;
  bool _isLoading = false;
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
    if (!_currentCandidates.contains(cellId) ||
        _currentVisible.contains(cellId)) {
      return;
    }

    _currentVisible.add(cellId);
    _visiblePolygons[cellId] = _boundaryFor(cellId);
    _emitUpdate(
      OverlayDiff(added: {cellId}, removed: const <String>{}),
      resolution,
    );
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _debounceTimer?.cancel();
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
    }
  }

  void _applyResult(H3OverlayResult result) {
    final nextVisible = Set<String>.from(result.visitedCellIds);
    final diff = computeOverlayDiff(_currentVisible, nextVisible);
    for (final cellId in diff.added) {
      _visiblePolygons[cellId] = _boundaryFor(cellId);
    }
    for (final cellId in diff.removed) {
      _visiblePolygons.remove(cellId);
    }

    final resolutionChanged = _currentResolution != result.resolution;
    _currentResolution = result.resolution;
    _currentVisible = nextVisible;
    _currentCandidates = Set<String>.from(result.candidateCellIds);

    if (!diff.isEmpty || resolutionChanged) {
      _emitUpdate(diff, result.resolution);
    }
  }

  List<LatLng> _boundaryFor(String cellId) {
    final cached = _boundaryCache.get(cellId);
    if (cached != null) {
      return cached;
    }
    final boundary = _boundaryResolver(cellId);
    _boundaryCache.put(cellId, boundary);
    return boundary;
  }

  void _emitUpdate(OverlayDiff diff, int resolution) {
    _onOverlayUpdated(
      VisitedOverlayUpdate(
        polygons: _visiblePolygons.values.toList(growable: false),
        resolution: resolution,
        addedCellIds: Set.unmodifiable(diff.added),
        removedCellIds: Set.unmodifiable(diff.removed),
      ),
    );
  }

  void _setLoading(bool isLoading) {
    if (_isLoading == isLoading) {
      return;
    }
    _isLoading = isLoading;
    _onLoadingChanged?.call(isLoading);
  }
}
