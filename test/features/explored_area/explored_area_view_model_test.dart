import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/explored_area/view_model/explored_area_view_model.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_bounds.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_cell_update.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_overlay.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_stats.dart';
import 'package:explored/features/visited_grid/data/models/visited_overlay_polygon.dart';
import 'package:explored/features/visited_grid/data/models/visited_time_filter.dart';
import 'package:explored/features/visited_grid/data/repositories/visited_grid_repository.dart';
import 'package:explored/features/location/data/models/lat_lng_sample.dart';

class FakeVisitedGridRepository implements VisitedGridRepository {
  FakeVisitedGridRepository({required this.initialStats});

  final VisitedGridStats initialStats;
  int fetchCalls = 0;
  int logCalls = 0;
  final StreamController<VisitedGridCellUpdate> _cellUpdates =
      StreamController<VisitedGridCellUpdate>.broadcast();
  final StreamController<VisitedGridStats> _statsUpdates =
      StreamController<VisitedGridStats>.broadcast();

  @override
  Stream<VisitedGridCellUpdate> get cellUpdates => _cellUpdates.stream;

  @override
  Stream<VisitedGridStats> get statsUpdates => _statsUpdates.stream;

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {
    await _cellUpdates.close();
    await _statsUpdates.close();
  }

  @override
  Future<void> ingestSamples(Iterable<LatLngSample> samples) async {}

  @override
  Future<VisitedGridStats> fetchStats() async {
    fetchCalls += 1;
    return initialStats;
  }

  @override
  Future<void> logExploredAreaViewed() async {
    logCalls += 1;
  }

  @override
  Future<VisitedGridOverlay> loadOverlay({
    required VisitedGridBounds bounds,
    required double zoom,
    required VisitedTimeFilter timeFilter,
  }) async {
    return const VisitedGridOverlay(
      resolution: 0,
      polygons: <VisitedOverlayPolygon>[],
    );
  }

  void emitStats(VisitedGridStats stats) {
    _statsUpdates.add(stats);
  }
}

void main() {
  test('initialize loads stats and logs view', () async {
    const stats = VisitedGridStats(
      totalAreaM2: 1200,
      cellCount: 3,
      canonicalVersion: 2,
    );
    final repository = FakeVisitedGridRepository(initialStats: stats);
    final viewModel =
        ExploredAreaViewModel(visitedGridRepository: repository);

    await viewModel.initialize();

    expect(repository.fetchCalls, 1);
    expect(repository.logCalls, 1);
    expect(viewModel.state.totalAreaM2, 1200);
    expect(viewModel.state.cellCount, 3);
    expect(viewModel.state.isLoading, isFalse);

    viewModel.dispose();
  });

  test('stats updates refresh state', () async {
    const initial = VisitedGridStats(
      totalAreaM2: 500,
      cellCount: 1,
      canonicalVersion: 1,
    );
    final repository = FakeVisitedGridRepository(initialStats: initial);
    final viewModel =
        ExploredAreaViewModel(visitedGridRepository: repository);

    await viewModel.initialize();

    const updated = VisitedGridStats(
      totalAreaM2: 1500,
      cellCount: 4,
      canonicalVersion: 2,
    );
    repository.emitStats(updated);
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.state.totalAreaM2, 1500);
    expect(viewModel.state.cellCount, 4);

    viewModel.dispose();
  });
}
