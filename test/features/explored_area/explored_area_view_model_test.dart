import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/explored_area/view_model/explored_area_view_model.dart';
import 'package:explored/features/explored_area/data/models/explored_area_filter.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_bounds.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_cell_update.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_overlay.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_stats.dart';
import 'package:explored/features/visited_grid/data/models/visited_overlay_polygon.dart';
import 'package:explored/features/visited_grid/data/models/visited_time_filter.dart';
import 'package:explored/features/visited_grid/data/repositories/visited_grid_repository.dart';
import 'package:explored/features/location/data/models/lat_lng_sample.dart';

class FakeVisitedGridRepository implements VisitedGridRepository {
  FakeVisitedGridRepository({required this.initialAreaKm2});

  final double initialAreaKm2;
  int fetchAreaCalls = 0;
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
  Future<void> rebuildFromHistory() async {}

  @override
  Future<VisitedGridStats> fetchStats() async => const VisitedGridStats(
        totalAreaM2: 0,
        cellCount: 0,
        canonicalVersion: 0,
      );

  @override
  Future<double> fetchExploredAreaKm2({
    DateTime? start,
    DateTime? end,
  }) async {
    fetchAreaCalls += 1;
    return initialAreaKm2;
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
    final repository = FakeVisitedGridRepository(initialAreaKm2: 1.2);
    final viewModel =
        ExploredAreaViewModel(visitedGridRepository: repository);

    await viewModel.initialize();

    expect(repository.fetchAreaCalls, 1);
    expect(repository.logCalls, 1);
    expect(viewModel.state.areaKm2, 1.2);
    expect(viewModel.state.isLoading, isFalse);

    viewModel.dispose();
  });

  test('stats updates refresh state for all time', () async {
    final repository = FakeVisitedGridRepository(initialAreaKm2: 0.5);
    final viewModel =
        ExploredAreaViewModel(visitedGridRepository: repository);

    await viewModel.initialize();

    const updated = VisitedGridStats(
      totalAreaM2: 2000000,
      cellCount: 2,
      canonicalVersion: 2,
    );
    repository.emitStats(updated);
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.state.areaKm2, 2);

    await viewModel.selectPreset(ExploredAreaFilterPreset.last7Days);
    repository.emitStats(const VisitedGridStats(
      totalAreaM2: 5000000,
      cellCount: 5,
      canonicalVersion: 3,
    ));
    await Future<void>.delayed(Duration.zero);
    expect(viewModel.state.areaKm2, isNot(5));

    viewModel.dispose();
  });
}
