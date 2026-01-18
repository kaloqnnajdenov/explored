import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/visited_grid/data/models/visited_grid_cell.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_cell_bounds.dart';
import 'package:explored/features/visited_grid/data/services/visited_grid_database.dart';

import 'visited_grid_test_utils.dart';

class FailingVisitedGridDao extends VisitedGridDao {
  FailingVisitedGridDao(super.db);

  int statementCalls = 0;

  @override
  Future<void> customStatement(String sql, [List<dynamic>? variables]) {
    statementCalls += 1;
    if (statementCalls == 2) {
      throw StateError('Injected failure');
    }
    return super.customStatement(sql, variables);
  }
}

Future<Set<String>> _tableColumns(
  VisitedGridDatabase db,
  String tableName,
) async {
  final rows =
      await db.customSelect('PRAGMA table_info($tableName)').get();
  return rows.map((row) => row.read<String>('name')).toSet();
}

List<VisitedGridCellBounds> _boundsFor(VisitedGridCell cell) {
  return [
    VisitedGridCellBounds(
      resolution: cell.resolution,
      cellId: cell.cellId,
      segment: 0,
      minLatE5: 0,
      maxLatE5: 0,
      minLonE5: 0,
      maxLonE5: 0,
    ),
  ];
}

void main() {
  group('VisitedGridDao upserts', () {
    late VisitedGridDatabase db;
    late VisitedGridDao dao;

    setUp(() {
      db = buildTestDb();
      dao = db.visitedGridDao;
    });

    tearDown(() async {
      await db.close();
    });

    test('Merges daily rows and updates masks, timestamps, samples', () async {
      const cellId = 'cell_a';
      const day = 20240101;
      final cell = VisitedGridCell(resolution: 12, cellId: cellId);

      await dao.upsertVisit(
        cells: [cell],
        cellBounds: _boundsFor(cell),
        day: day,
        hourMask: 1 << 3,
        epochSeconds: 100,
        latE5: 111,
        lonE5: 222,
      );
      await dao.upsertVisit(
        cells: [cell],
        cellBounds: _boundsFor(cell),
        day: day,
        hourMask: 1 << 5,
        epochSeconds: 200,
        latE5: 333,
        lonE5: 444,
      );

      final dailyRow = await (db.select(db.visitsDaily)
            ..where((tbl) => tbl.cellId.equals(cellId))
            ..where((tbl) => tbl.res.equals(12))
            ..where((tbl) => tbl.dayYyyyMmdd.equals(day)))
          .getSingle();
      expect(dailyRow.hourMask, (1 << 3) | (1 << 5));
      expect(dailyRow.firstTs, 100);
      expect(dailyRow.lastTs, 200);
      expect(dailyRow.samples, 2);
      expect(dailyRow.latE5, 333);
      expect(dailyRow.lonE5, 444);

      final lifetimeRow = await (db.select(db.visitsLifetime)
            ..where((tbl) => tbl.cellId.equals(cellId))
            ..where((tbl) => tbl.res.equals(12)))
          .getSingle();
      expect(lifetimeRow.firstTs, 100);
      expect(lifetimeRow.lastTs, 200);
      expect(lifetimeRow.samples, 2);
      expect(lifetimeRow.daysVisited, 1);
      expect(lifetimeRow.latE5, 333);
      expect(lifetimeRow.lonE5, 444);

      final days = await (db.select(db.visitsLifetimeDays)
            ..where((tbl) => tbl.cellId.equals(cellId))
            ..where((tbl) => tbl.res.equals(12)))
          .get();
      expect(days, hasLength(1));
      expect(days.first.dayYyyyMmdd, day);
    });

    test('Increments daysVisited only for new day inserts', () async {
      const cellId = 'cell_b';
      final cell = VisitedGridCell(resolution: 12, cellId: cellId);

      await dao.upsertVisit(
        cells: [cell],
        cellBounds: _boundsFor(cell),
        day: 20240101,
        hourMask: 1 << 1,
        epochSeconds: 100,
        latE5: 1,
        lonE5: 2,
      );
      await dao.upsertVisit(
        cells: [cell],
        cellBounds: _boundsFor(cell),
        day: 20240101,
        hourMask: 1 << 2,
        epochSeconds: 200,
        latE5: 3,
        lonE5: 4,
      );
      await dao.upsertVisit(
        cells: [cell],
        cellBounds: _boundsFor(cell),
        day: 20240102,
        hourMask: 1 << 3,
        epochSeconds: 300,
        latE5: 5,
        lonE5: 6,
      );

      final lifetimeRow = await (db.select(db.visitsLifetime)
            ..where((tbl) => tbl.cellId.equals(cellId))
            ..where((tbl) => tbl.res.equals(12)))
          .getSingle();
      expect(lifetimeRow.daysVisited, 2);

      final days = await (db.select(db.visitsLifetimeDays)
            ..where((tbl) => tbl.cellId.equals(cellId))
            ..where((tbl) => tbl.res.equals(12)))
          .get();
      final dayKeys = days.map((row) => row.dayYyyyMmdd).toSet();
      expect(dayKeys, {20240101, 20240102});
    });
  });

  group('VisitedGridDao fetches', () {
    late VisitedGridDatabase db;
    late VisitedGridDao dao;

    setUp(() {
      db = buildTestDb();
      dao = db.visitedGridDao;
    });

    tearDown(() async {
      await db.close();
    });

    test('Chunks daily queries across large candidate lists', () async {
      const day = 20240101;
      const res = 12;
      final candidates = List.generate(901, (index) => 'cell_$index');
      await db.customStatement(
        '''
INSERT INTO visits_daily (
  res, cell_id, day_yyyy_mmdd, hour_mask, first_ts, last_ts, samples, lat_e5, lon_e5
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
''',
        [res, 'cell_0', day, 1, 1, 1, 1, 0, 0],
      );
      await db.customStatement(
        '''
INSERT INTO visits_daily (
  res, cell_id, day_yyyy_mmdd, hour_mask, first_ts, last_ts, samples, lat_e5, lon_e5
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
''',
        [res, 'cell_900', day, 1, 1, 1, 1, 0, 0],
      );

      final visited = await dao.fetchVisitedDailyCells(
        resolution: res,
        cellIds: candidates,
        startDay: day,
        endDay: day,
      );

      expect(visited.contains('cell_0'), isTrue);
      expect(visited.contains('cell_900'), isTrue);
    });

    test('Chunks lifetime queries across large candidate lists', () async {
      const res = 12;
      final candidates = List.generate(901, (index) => 'cell_$index');
      await db.customStatement(
        '''
INSERT INTO visits_lifetime (
  res, cell_id, first_ts, last_ts, samples, days_visited, lat_e5, lon_e5
) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
''',
        [res, 'cell_0', 1, 1, 1, 1, 0, 0],
      );
      await db.customStatement(
        '''
INSERT INTO visits_lifetime (
  res, cell_id, first_ts, last_ts, samples, days_visited, lat_e5, lon_e5
) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
''',
        [res, 'cell_900', 1, 1, 1, 1, 0, 0],
      );

      final visited = await dao.fetchVisitedLifetimeCells(
        resolution: res,
        cellIds: candidates,
      );

      expect(visited.contains('cell_0'), isTrue);
      expect(visited.contains('cell_900'), isTrue);
    });

    test('Fetches lifetime cells within bounds', () async {
      const res = 12;
      await db.customStatement(
        '''
INSERT INTO visits_lifetime (
  res, cell_id, first_ts, last_ts, samples, days_visited, lat_e5, lon_e5
) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
''',
        [res, 'cell_a', 1, 1, 1, 1, 0, 0],
      );
      await db.customStatement(
        '''
INSERT INTO visited_cell_bounds (
  res, cell_id, segment, min_lat_e5, max_lat_e5, min_lon_e5, max_lon_e5
) VALUES (?, ?, ?, ?, ?, ?, ?)
''',
        [res, 'cell_a', 0, 0, 100000, 0, 100000],
      );

      final visited = await dao.fetchVisitedLifetimeInBounds(
        resolution: res,
        southLatE5: -50000,
        northLatE5: 150000,
        westLonE5: -50000,
        eastLonE5: 150000,
      );

      expect(visited, {'cell_a'});
    });

    test('Fetches daily cells within bounds and date range', () async {
      const res = 12;
      const day = 20240101;
      await db.customStatement(
        '''
INSERT INTO visits_daily (
  res, cell_id, day_yyyy_mmdd, hour_mask, first_ts, last_ts, samples, lat_e5, lon_e5
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
''',
        [res, 'cell_b', day, 1, 1, 1, 1, 0, 0],
      );
      await db.customStatement(
        '''
INSERT INTO visited_cell_bounds (
  res, cell_id, segment, min_lat_e5, max_lat_e5, min_lon_e5, max_lon_e5
) VALUES (?, ?, ?, ?, ?, ?, ?)
''',
        [res, 'cell_b', 0, 0, 100000, 0, 100000],
      );

      final visited = await dao.fetchVisitedDailyInBounds(
        resolution: res,
        startDay: day,
        endDay: day,
        southLatE5: -50000,
        northLatE5: 150000,
        westLonE5: -50000,
        eastLonE5: 150000,
      );

      expect(visited, {'cell_b'});
    });
  });

  group('VisitedGridDao transactions', () {
    late VisitedGridDatabase db;

    setUp(() {
      db = buildTestDb();
    });

    tearDown(() async {
      await db.close();
    });

    test('Upsert is atomic across tables', () async {
      final dao = FailingVisitedGridDao(db);
      final cell = VisitedGridCell(resolution: 12, cellId: 'cell_fail');

      expect(
        () => dao.upsertVisit(
          cells: [cell],
          cellBounds: _boundsFor(cell),
          day: 20240101,
          hourMask: 1,
          epochSeconds: 100,
          latE5: 1,
          lonE5: 2,
        ),
        throwsStateError,
      );

      final dailyRows = await db.select(db.visitsDaily).get();
      final lifetimeRows = await db.select(db.visitsLifetime).get();
      final dayRows = await db.select(db.visitsLifetimeDays).get();
      final boundsRows = await db.select(db.visitedCellBounds).get();
      expect(dailyRows, isEmpty);
      expect(lifetimeRows, isEmpty);
      expect(dayRows, isEmpty);
      expect(boundsRows, isEmpty);
    });
  });

  group('VisitedGrid privacy contract', () {
    late VisitedGridDatabase db;

    setUp(() {
      db = buildTestDb();
    });

    tearDown(() async {
      await db.close();
    });

    test('Schema contains only aggregated visit tables', () async {
      final rows = await db
          .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
          .get();
      final names = rows.map((row) => row.read<String>('name')).toSet();
      const expected = {
        'visits_daily',
        'visits_lifetime',
        'visits_lifetime_days',
        'visited_cell_bounds',
        'visited_grid_meta',
      };
      final filtered = names.where((name) {
        return !name.startsWith('sqlite_') && name != 'android_metadata';
      }).toSet();

      expect(filtered, expected);
    });

    test('Tables store only aggregated columns', () async {
      final dailyColumns = await _tableColumns(db, 'visits_daily');
      expect(
        dailyColumns,
        {
          'res',
          'cell_id',
          'day_yyyy_mmdd',
          'hour_mask',
          'first_ts',
          'last_ts',
          'samples',
          'lat_e5',
          'lon_e5',
        },
      );

      final lifetimeColumns = await _tableColumns(db, 'visits_lifetime');
      expect(
        lifetimeColumns,
        {
          'res',
          'cell_id',
          'first_ts',
          'last_ts',
          'samples',
          'days_visited',
          'lat_e5',
          'lon_e5',
        },
      );

      final dayColumns = await _tableColumns(db, 'visits_lifetime_days');
      expect(
        dayColumns,
        {
          'res',
          'cell_id',
          'day_yyyy_mmdd',
        },
      );

      final boundsColumns = await _tableColumns(db, 'visited_cell_bounds');
      expect(
        boundsColumns,
        {
          'res',
          'cell_id',
          'segment',
          'min_lat_e5',
          'max_lat_e5',
          'min_lon_e5',
          'max_lon_e5',
        },
      );

      final metaColumns = await _tableColumns(db, 'visited_grid_meta');
      expect(metaColumns, {'id', 'last_cleanup_ts'});
    });
  });
}
