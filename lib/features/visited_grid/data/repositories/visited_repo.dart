import '../models/visited_grid_bounds.dart';
import '../models/visited_grid_cell_bounds.dart';
import '../services/visited_grid_database.dart';

abstract class VisitedRepo {
  Future<int> countBoundsForResolution({
    required int resolution,
  });

  Future<List<String>> fetchLifetimeCellIds({
    required int resolution,
  });

  Future<void> upsertCellBounds({
    required List<VisitedGridCellBounds> bounds,
  });

  Future<Set<String>> fetchLifetimeVisitedInBounds({
    required int resolution,
    required VisitedGridBounds bounds,
  });

  Future<Set<String>> fetchDailyVisitedInBounds({
    required int resolution,
    required int fromDay,
    required int toDay,
    required VisitedGridBounds bounds,
  });
}

class DriftVisitedRepo implements VisitedRepo {
  DriftVisitedRepo({
    required VisitedGridDao visitedGridDao,
  }) : _visitedGridDao = visitedGridDao;

  final VisitedGridDao _visitedGridDao;

  @override
  Future<int> countBoundsForResolution({
    required int resolution,
  }) {
    return _visitedGridDao.countBoundsForResolution(resolution);
  }

  @override
  Future<List<String>> fetchLifetimeCellIds({
    required int resolution,
  }) {
    return _visitedGridDao.fetchLifetimeCellIds(resolution);
  }

  @override
  Future<void> upsertCellBounds({
    required List<VisitedGridCellBounds> bounds,
  }) {
    return _visitedGridDao.insertCellBounds(bounds);
  }

  @override
  Future<Set<String>> fetchLifetimeVisitedInBounds({
    required int resolution,
    required VisitedGridBounds bounds,
  }) async {
    final result = <String>{};
    final ranges = _lonRangesForBounds(bounds);
    for (final range in ranges) {
      result.addAll(
        await _visitedGridDao.fetchVisitedLifetimeInBounds(
          resolution: resolution,
          southLatE5: (bounds.south * 100000).floor(),
          northLatE5: (bounds.north * 100000).ceil(),
          westLonE5: range.westE5,
          eastLonE5: range.eastE5,
        ),
      );
    }
    return result;
  }

  @override
  Future<Set<String>> fetchDailyVisitedInBounds({
    required int resolution,
    required int fromDay,
    required int toDay,
    required VisitedGridBounds bounds,
  }) async {
    final result = <String>{};
    final ranges = _lonRangesForBounds(bounds);
    for (final range in ranges) {
      result.addAll(
        await _visitedGridDao.fetchVisitedDailyInBounds(
          resolution: resolution,
          startDay: fromDay,
          endDay: toDay,
          southLatE5: (bounds.south * 100000).floor(),
          northLatE5: (bounds.north * 100000).ceil(),
          westLonE5: range.westE5,
          eastLonE5: range.eastE5,
        ),
      );
    }
    return result;
  }
}

class _LonRangeE5 {
  const _LonRangeE5({required this.westE5, required this.eastE5});

  final int westE5;
  final int eastE5;
}

List<_LonRangeE5> _lonRangesForBounds(VisitedGridBounds bounds) {
  if (bounds.east >= bounds.west) {
    return [
      _LonRangeE5(
        westE5: (bounds.west * 100000).floor(),
        eastE5: (bounds.east * 100000).ceil(),
      ),
    ];
  }
  return [
    _LonRangeE5(
      westE5: (bounds.west * 100000).floor(),
      eastE5: 18000000,
    ),
    _LonRangeE5(
      westE5: -18000000,
      eastE5: (bounds.east * 100000).ceil(),
    ),
  ];
}
