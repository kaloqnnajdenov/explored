import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../visited_grid/data/models/visited_grid_stats.dart';
import '../../visited_grid/data/repositories/visited_grid_repository.dart';
import '../data/models/explored_area_filter.dart';
import '../data/models/explored_area_view_state.dart';

class ExploredAreaViewModel extends ChangeNotifier {
  ExploredAreaViewModel({
    required VisitedGridRepository visitedGridRepository,
  }) : _visitedGridRepository = visitedGridRepository;

  final VisitedGridRepository _visitedGridRepository;
  ExploredAreaViewState _state = ExploredAreaViewState.initial();
  StreamSubscription<VisitedGridStats>? _statsSubscription;
  bool _hasInitialized = false;
  int _requestId = 0;

  ExploredAreaViewState get state => _state;

  Future<void> initialize() async {
    if (_hasInitialized) {
      return;
    }
    _hasInitialized = true;
    await _refreshArea();
    await _visitedGridRepository.logExploredAreaViewed();
    _statsSubscription =
        _visitedGridRepository.statsUpdates.listen(_handleStatsUpdate);
  }

  Future<void> selectPreset(ExploredAreaFilterPreset preset) async {
    final updated = _state.filter.copyWith(
      preset: preset,
      clearCustom: preset != ExploredAreaFilterPreset.custom,
    );
    _state = _state.copyWith(filter: updated, clearError: true);
    notifyListeners();
    if (preset != ExploredAreaFilterPreset.custom) {
      await _refreshArea();
      return;
    }
    if (updated.hasCustomRange) {
      await _refreshArea();
    }
  }

  Future<void> setCustomStart(DateTime? start) async {
    final updated = _state.filter.copyWith(
      preset: ExploredAreaFilterPreset.custom,
      customStart: start,
    );
    _state = _state.copyWith(filter: updated, clearError: true);
    notifyListeners();
    if (updated.hasCustomRange) {
      await _refreshArea();
    }
  }

  Future<void> setCustomEnd(DateTime? end) async {
    final updated = _state.filter.copyWith(
      preset: ExploredAreaFilterPreset.custom,
      customEnd: end,
    );
    _state = _state.copyWith(filter: updated, clearError: true);
    notifyListeners();
    if (updated.hasCustomRange) {
      await _refreshArea();
    }
  }

  void _handleStatsUpdate(VisitedGridStats stats) {
    if (_state.filter.preset != ExploredAreaFilterPreset.allTime) {
      return;
    }
    _state = _state.copyWith(areaKm2: stats.totalAreaKm2);
    notifyListeners();
  }

  Future<void> _refreshArea() async {
    final requestId = ++_requestId;
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final filter = _state.filter;
      DateTime? start;
      DateTime? end;
      if (filter.preset == ExploredAreaFilterPreset.custom) {
        start = filter.customStart;
        end = filter.customEnd;
        if (start == null || end == null) {
          _state = _state.copyWith(isLoading: false);
          notifyListeners();
          return;
        }
      } else if (filter.preset == ExploredAreaFilterPreset.allTime) {
        start = null;
        end = null;
      } else {
        final now = DateTime.now();
        switch (filter.preset) {
          case ExploredAreaFilterPreset.last7Days:
            start = _startOfDay(now.subtract(const Duration(days: 6)));
            end = _startOfDay(now);
            break;
          case ExploredAreaFilterPreset.last30Days:
            start = _startOfDay(now.subtract(const Duration(days: 29)));
            end = _startOfDay(now);
            break;
          case ExploredAreaFilterPreset.thisMonth:
            start = DateTime(now.year, now.month);
            end = _startOfDay(now);
            break;
          case ExploredAreaFilterPreset.custom:
          case ExploredAreaFilterPreset.allTime:
            break;
        }
      }

      final areaKm2 = await _visitedGridRepository.fetchExploredAreaKm2(
        start: start,
        end: end,
      );
      if (_requestId != requestId) {
        return;
      }
      _state = _state.copyWith(
        areaKm2: areaKm2,
        isLoading: false,
        clearError: true,
      );
      notifyListeners();
    } catch (error) {
      if (_requestId != requestId) {
        return;
      }
      _state = _state.copyWith(isLoading: false, error: error);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _statsSubscription?.cancel();
    super.dispose();
  }

  DateTime _startOfDay(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
