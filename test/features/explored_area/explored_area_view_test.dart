import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/explored_area/view/explored_area_view.dart';
import 'package:explored/features/explored_area/view_model/explored_area_view_model.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_bounds.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_cell_update.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_overlay.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_stats.dart';
import 'package:explored/features/visited_grid/data/models/visited_overlay_polygon.dart';
import 'package:explored/features/visited_grid/data/models/visited_time_filter.dart';
import 'package:explored/features/visited_grid/data/repositories/visited_grid_repository.dart';
import 'package:explored/features/location/data/models/lat_lng_sample.dart';
import '../../test_utils/localization_test_utils.dart';

class FakeVisitedGridRepository implements VisitedGridRepository {
  FakeVisitedGridRepository(this.stats);

  final VisitedGridStats stats;
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
  Future<VisitedGridStats> fetchStats() async => stats;

  @override
  Future<void> logExploredAreaViewed() async {}

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
}

void main() {
  testWidgets('explored area text fits without overflow', (tester) async {
    final repository = FakeVisitedGridRepository(
      const VisitedGridStats(
        totalAreaM2: 12345678,
        cellCount: 10,
        canonicalVersion: 1,
      ),
    );
    final viewModel =
        ExploredAreaViewModel(visitedGridRepository: repository);
    final app = await buildLocalizedTestApp(
      ExploredAreaView(viewModel: viewModel),
    );

    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    expect(find.textContaining('Explored:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
