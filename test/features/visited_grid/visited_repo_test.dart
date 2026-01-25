import 'package:flutter_test/flutter_test.dart';

import 'package:explored/constants.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_bounds.dart';
import 'package:explored/features/visited_grid/data/repositories/visited_repo.dart';

import 'visited_grid_test_utils.dart';

void main() {
  test('DriftVisitedRepo splits antimeridian bounds and unions results', () async {
    final db = buildTestDb();
    final repo = DriftVisitedRepo(visitedGridDao: db.visitedGridDao);

    await db.customStatement(
      '''
INSERT INTO visits_lifetime (
  res, cell_id, first_ts, last_ts, samples, days_visited, lat_e5, lon_e5
) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
''',
      [kBaseH3Resolution, 'cell_dateline', 1, 1, 1, 1, 0, 0],
    );
    await db.customStatement(
      '''
INSERT INTO visited_cell_bounds (
  res, cell_id, segment, min_lat_e5, max_lat_e5, min_lon_e5, max_lon_e5
) VALUES (?, ?, ?, ?, ?, ?, ?)
''',
      [
        kBaseH3Resolution,
        'cell_dateline',
        0,
        -100000,
        100000,
        17900000,
        18000000
      ],
    );

    final visited = await repo.fetchLifetimeVisitedInBounds(
      resolution: kBaseH3Resolution,
      bounds: const VisitedGridBounds(
        north: 1,
        south: -1,
        east: -170,
        west: 170,
      ),
    );

    expect(visited, {'cell_dateline'});

    await db.close();
  });
}
