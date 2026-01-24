import 'dart:async';

import 'package:flutter_map/flutter_map.dart';

import '../data/models/visited_grid_cell_update.dart';
import '../data/repositories/fog_of_war_tile_repository.dart';
import '../data/repositories/visited_grid_repository.dart';
import 'fog_of_war_tile_provider.dart';

abstract class FogOfWarOverlayController {
  TileProvider get tileProvider;
  Stream<void> get resetStream;
  int get tileSize;
  Future<void> setTileSize(int tileSize);
  Future<void> dispose();
}

class DefaultFogOfWarOverlayController implements FogOfWarOverlayController {
  DefaultFogOfWarOverlayController({
    required VisitedGridRepository visitedGridRepository,
    required FogOfWarTileRepository tileRepository,
    Duration resetDebounce = const Duration(milliseconds: 200),
  })  : _visitedGridRepository = visitedGridRepository,
        _tileRepository = tileRepository,
        _resetDebounce = resetDebounce {
    _tileProvider = FogOfWarTileProvider(repository: tileRepository);
    _subscription = _visitedGridRepository.cellUpdates.listen(
      _handleCellUpdate,
    );
  }

  final VisitedGridRepository _visitedGridRepository;
  final FogOfWarTileRepository _tileRepository;
  final Duration _resetDebounce;
  late final FogOfWarTileProvider _tileProvider;
  final StreamController<void> _resetController =
      StreamController<void>.broadcast();
  StreamSubscription<VisitedGridCellUpdate>? _subscription;
  Timer? _resetTimer;
  bool _disposed = false;

  @override
  TileProvider get tileProvider => _tileProvider;

  @override
  Stream<void> get resetStream => _resetController.stream;

  @override
  int get tileSize => _tileRepository.tileSize;

  @override
  Future<void> setTileSize(int tileSize) async {
    if (_disposed) {
      return;
    }
    await _tileRepository.setTileSize(tileSize);
    _emitReset();
  }

  void _handleCellUpdate(VisitedGridCellUpdate update) {
    if (_disposed) {
      return;
    }
    _tileRepository.invalidateForCell(update.cellId);
    _scheduleReset();
  }

  void _scheduleReset() {
    _resetTimer?.cancel();
    _resetTimer = Timer(_resetDebounce, _emitReset);
  }

  void _emitReset() {
    if (_disposed || _resetController.isClosed) {
      return;
    }
    _resetController.add(null);
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _resetTimer?.cancel();
    await _subscription?.cancel();
    await _resetController.close();
  }
}
