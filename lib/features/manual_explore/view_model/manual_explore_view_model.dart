import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../map/data/repositories/map_repository.dart';
import '../../visited_grid/view_model/fog_of_war_overlay_controller.dart';
import '../../visited_grid/view_model/h3_boundary_cache.dart';
import '../data/models/manual_explore_action.dart';
import '../data/models/manual_explore_delete_summary.dart';
import '../data/models/manual_explore_edit_kind.dart';
import '../data/models/manual_explore_mode.dart';
import '../data/models/manual_explore_view_state.dart';
import '../data/repositories/manual_explore_repository.dart';

class ManualExploreViewModel extends ChangeNotifier {
  ManualExploreViewModel({
    required ManualExploreRepository repository,
    required MapRepository mapRepository,
    required FogOfWarOverlayController overlayController,
    DateTime Function()? nowProvider,
  })  : _repository = repository,
        _mapRepository = mapRepository,
        _overlayController = overlayController,
        _now = nowProvider ?? DateTime.now,
        _state = ManualExploreViewState.initial(
          mapRepository.getMapConfig(),
        );

  final ManualExploreRepository _repository;
  final MapRepository _mapRepository;
  final FogOfWarOverlayController _overlayController;
  final DateTime Function() _now;
  ManualExploreViewState _state;
  bool _hasInitialized = false;

  ManualExploreViewState get state => _state;
  TileProvider get overlayTileProvider => _overlayController.tileProvider;
  Stream<void> get overlayResetStream => _overlayController.resetStream;

  final Set<String> _stagedAdds = <String>{};
  final Set<String> _stagedDeletes = <String>{};
  final List<ManualExploreAction> _actions = <ManualExploreAction>[];
  int _actionIndex = 0;
  Set<String>? _activeStrokeCells;
  final H3BoundaryCache _boundaryCache = H3BoundaryCache(maxEntries: 2000);

  Future<void> initialize() async {
    if (_hasInitialized) {
      return;
    }
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final overlayTileSize = await _mapRepository.fetchOverlayTileSize();
      await _overlayController.setTileSize(overlayTileSize.size);
      final config = _mapRepository.getMapConfig();
      _state = _state.copyWith(
        center: config.initialCenter,
        zoom: config.initialZoom,
        tileSource: config.tileSource,
        overlayTileSize: overlayTileSize,
        isLoading: false,
        clearError: true,
      );
      _hasInitialized = true;
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        error: error,
        clearError: false,
      );
    }

    notifyListeners();
  }

  void setMode(ManualExploreMode mode) {
    if (_state.mode == mode) {
      return;
    }
    _cancelActiveStroke();
    _state = _state.copyWith(mode: mode);
    notifyListeners();
  }

  void toggleControlPanelCollapsed() {
    final shouldCollapse = !_state.isControlPanelCollapsed;
    _state = _state.copyWith(
      isControlPanelCollapsed: shouldCollapse,
    );
    notifyListeners();
  }

  void updateMapZoom(double zoom) {
    if ((zoom - _state.zoom).abs() < 0.001) {
      return;
    }
    _boundaryCache.clear();
    _state = _state.copyWith(zoom: zoom);
    if (_stagedAdds.isEmpty && _stagedDeletes.isEmpty) {
      notifyListeners();
      return;
    }
    _refreshDerivedState();
  }

  void setApplyDateTime(DateTime? localDateTime) {
    _state = _state.copyWith(
      setApplyDateTimeLocal: true,
      applyDateTimeLocal: localDateTime,
    );
    notifyListeners();
  }

  void resetApplyDateToNow() {
    setApplyDateTime(null);
  }

  void beginPaintStroke() {
    _activeStrokeCells = <String>{};
  }

  void addPaintSample(LatLng position) {
    final kind = _state.mode.editKind;
    final currentStroke = _activeStrokeCells;
    if (currentStroke == null) {
      return;
    }
    final cellId = _repository.cellIdForLatLng(position);
    if (kind == ManualExploreEditKind.delete &&
        !_stagedAdds.contains(cellId) &&
        !_repository.isCellExplored(cellId)) {
      return;
    }
    var changed = false;
    if (currentStroke.add(cellId)) {
      changed = true;
      _stageCell(kind, cellId);
    }
    if (changed) {
      _refreshDerivedState();
    }
  }

  void endPaintStroke() {
    final kind = _state.mode.editKind;
    final currentStroke = _activeStrokeCells;
    _activeStrokeCells = null;
    if (currentStroke == null || currentStroke.isEmpty) {
      return;
    }
    _commitAction(kind: kind, cellIds: currentStroke);
  }

  void cancelPaintStroke() {
    if (_activeStrokeCells == null) {
      return;
    }
    _activeStrokeCells = null;
    _rebuildFromActions();
  }

  bool get canUndo => _actionIndex > 0;
  bool get canRedo => _actionIndex < _actions.length;

  void undo() {
    if (!canUndo) {
      return;
    }
    _actionIndex -= 1;
    _rebuildFromActions();
  }

  void redo() {
    if (!canRedo) {
      return;
    }
    _actionIndex += 1;
    _rebuildFromActions();
  }

  Future<ManualExploreDeleteSummary> fetchDeleteSummary() {
    return _repository.fetchDeleteSummary(_stagedDeletes);
  }

  Future<bool> saveEdits() async {
    if (_state.isSaving || !_hasChanges) {
      return false;
    }
    _state = _state.copyWith(isSaving: true, clearError: true);
    notifyListeners();

    final timestampLocal = _state.applyDateTimeLocal ?? _now();
    final timestampUtc = timestampLocal.toUtc();
    try {
      await _repository.applyEdits(
        addCellIds: _stagedAdds,
        deleteCellIds: _stagedDeletes,
        timestampUtc: timestampUtc,
      );
      _clearSession();
      _state = _state.copyWith(isSaving: false);
      notifyListeners();
      return true;
    } catch (error) {
      _state = _state.copyWith(isSaving: false, error: error);
      notifyListeners();
      return false;
    }
  }

  void resetSession() {
    _clearSession();
    notifyListeners();
  }

  bool get _hasChanges =>
      _stagedAdds.isNotEmpty || _stagedDeletes.isNotEmpty;

  void _commitAction({
    required ManualExploreEditKind kind,
    required Set<String> cellIds,
  }) {
    if (cellIds.isEmpty) {
      return;
    }
    if (_actionIndex < _actions.length) {
      _actions.removeRange(_actionIndex, _actions.length);
    }
    _actions.add(ManualExploreAction(kind: kind, cellIds: cellIds));
    _actionIndex = _actions.length;
    _rebuildFromActions();
  }

  void _rebuildFromActions() {
    _stagedAdds.clear();
    _stagedDeletes.clear();
    for (var i = 0; i < _actionIndex; i += 1) {
      final action = _actions[i];
      for (final cellId in action.cellIds) {
        _stageCell(action.kind, cellId);
      }
    }
    _refreshDerivedState();
  }

  void _stageCell(ManualExploreEditKind kind, String cellId) {
    switch (kind) {
      case ManualExploreEditKind.add:
        _stagedDeletes.remove(cellId);
        _stagedAdds.add(cellId);
        break;
      case ManualExploreEditKind.delete:
        _stagedAdds.remove(cellId);
        _stagedDeletes.add(cellId);
        break;
    }
  }

  void _refreshDerivedState() {
    final addPolygons = _buildPolygons(_stagedAdds);
    final deletePolygons = _buildPolygons(_stagedDeletes);
    _state = _state.copyWith(
      canUndo: canUndo,
      canRedo: canRedo,
      hasChanges: _hasChanges,
      stagedAddCount: _stagedAdds.length,
      stagedDeleteCount: _stagedDeletes.length,
      addPolygons: addPolygons,
      deletePolygons: deletePolygons,
    );
    notifyListeners();
  }

  List<List<LatLng>> _buildPolygons(Set<String> cellIds) {
    if (cellIds.isEmpty) {
      return const [];
    }
    final sorted = SplayTreeSet<String>.from(cellIds);
    final polygons = <List<LatLng>>[];
    for (final cellId in sorted) {
      final cached = _boundaryCache.get(cellId);
      if (cached != null) {
        polygons.add(cached);
        continue;
      }
      final boundary = _repository.cellBoundary(
        cellId: cellId,
        zoom: _state.zoom,
      );
      _boundaryCache.put(cellId, boundary);
      polygons.add(boundary);
    }
    return polygons;
  }

  void _clearSession() {
    _activeStrokeCells = null;
    _actions.clear();
    _actionIndex = 0;
    _stagedAdds.clear();
    _stagedDeletes.clear();
    _boundaryCache.clear();
    _state = _state.copyWith(
      canUndo: false,
      canRedo: false,
      hasChanges: false,
      stagedAddCount: 0,
      stagedDeleteCount: 0,
      addPolygons: const [],
      deletePolygons: const [],
    );
  }

  void _cancelActiveStroke() {
    if (_activeStrokeCells == null) {
      return;
    }
    cancelPaintStroke();
  }
}
