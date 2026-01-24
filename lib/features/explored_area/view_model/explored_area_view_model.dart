import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../visited_grid/data/models/visited_grid_stats.dart';
import '../../visited_grid/data/repositories/visited_grid_repository.dart';
import '../data/models/explored_area_view_state.dart';

class ExploredAreaViewModel extends ChangeNotifier {
  ExploredAreaViewModel({
    required VisitedGridRepository visitedGridRepository,
  }) : _visitedGridRepository = visitedGridRepository;

  final VisitedGridRepository _visitedGridRepository;
  ExploredAreaViewState _state = ExploredAreaViewState.initial();
  StreamSubscription<VisitedGridStats>? _statsSubscription;
  bool _hasInitialized = false;

  ExploredAreaViewState get state => _state;

  Future<void> initialize() async {
    if (_hasInitialized) {
      return;
    }
    _hasInitialized = true;
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final stats = await _visitedGridRepository.fetchStats();
      _state = _state.copyWith(
        totalAreaM2: stats.totalAreaM2,
        cellCount: stats.cellCount,
        isLoading: false,
        clearError: true,
      );
      notifyListeners();
      await _visitedGridRepository.logExploredAreaViewed();
      _statsSubscription =
          _visitedGridRepository.statsUpdates.listen(_handleStatsUpdate);
    } catch (error) {
      _state = _state.copyWith(isLoading: false, error: error);
      notifyListeners();
    }
  }

  void _handleStatsUpdate(VisitedGridStats stats) {
    _state = _state.copyWith(
      totalAreaM2: stats.totalAreaM2,
      cellCount: stats.cellCount,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _statsSubscription?.cancel();
    super.dispose();
  }
}
