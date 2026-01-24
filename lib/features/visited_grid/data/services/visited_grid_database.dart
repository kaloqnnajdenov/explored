import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:explored/constants.dart';

import '../models/visited_grid_cell.dart';
import '../models/visited_grid_cell_bounds.dart';
import 'visited_grid_h3_service.dart';

part 'visited_grid_database.g.dart';

@TableIndex(name: 'visits_daily_res_day', columns: {#res, #dayYyyyMmdd})
@TableIndex(name: 'visits_daily_res_cell', columns: {#res, #cellId})
class VisitsDaily extends Table {
  IntColumn get res => integer()();
  TextColumn get cellId => text()();
  IntColumn get dayYyyyMmdd => integer()();
  IntColumn get hourMask => integer()();
  IntColumn get firstTs => integer()();
  IntColumn get lastTs => integer()();
  IntColumn get samples => integer()();
  IntColumn get latE5 => integer()();
  IntColumn get lonE5 => integer()();

  @override
  Set<Column> get primaryKey => {res, cellId, dayYyyyMmdd};

}

@TableIndex(name: 'visits_lifetime_res', columns: {#res})
class VisitsLifetime extends Table {
  IntColumn get res => integer()();
  TextColumn get cellId => text()();
  IntColumn get firstTs => integer()();
  IntColumn get lastTs => integer()();
  IntColumn get samples => integer()();
  IntColumn get daysVisited => integer().withDefault(const Constant(0))();
  IntColumn get latE5 => integer()();
  IntColumn get lonE5 => integer()();

  @override
  Set<Column> get primaryKey => {res, cellId};

}

@TableIndex(name: 'visits_lifetime_days_res_day', columns: {#res, #dayYyyyMmdd})
class VisitsLifetimeDays extends Table {
  IntColumn get res => integer()();
  TextColumn get cellId => text()();
  IntColumn get dayYyyyMmdd => integer()();

  @override
  Set<Column> get primaryKey => {res, cellId, dayYyyyMmdd};

}

@TableIndex(
  name: 'cell_bounds_res_lat',
  columns: {#res, #minLatE5, #maxLatE5},
)
@TableIndex(
  name: 'cell_bounds_res_lon',
  columns: {#res, #minLonE5, #maxLonE5},
)
class VisitedCellBounds extends Table {
  IntColumn get res => integer()();
  TextColumn get cellId => text()();
  IntColumn get segment => integer()();
  IntColumn get minLatE5 => integer()();
  IntColumn get maxLatE5 => integer()();
  IntColumn get minLonE5 => integer()();
  IntColumn get maxLonE5 => integer()();

  @override
  Set<Column> get primaryKey => {res, cellId, segment};
}

class VisitedGridMeta extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  IntColumn get lastCleanupTs => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('VisitedGridStatsRow')
class VisitedGridStatsTable extends Table {
  @override
  String get tableName => 'visited_grid_stats';

  IntColumn get id => integer().withDefault(const Constant(0))();
  RealColumn get totalAreaM2 =>
      real().withDefault(const Constant(0))();
  IntColumn get cellCount => integer().withDefault(const Constant(0))();
  IntColumn get canonicalVersion =>
      integer().withDefault(const Constant(0))();
  IntColumn get lastUpdatedTs => integer().nullable()();
  IntColumn get lastReconciledTs => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    VisitsDaily,
    VisitsLifetime,
    VisitsLifetimeDays,
    VisitedCellBounds,
    VisitedGridMeta,
    VisitedGridStatsTable,
  ],
  daos: [VisitedGridDao],
)
class VisitedGridDatabase extends _$VisitedGridDatabase {
  VisitedGridDatabase({
    QueryExecutor? executor,
    String databaseName = 'visited_grid',
    bool shareAcrossIsolates = false,
  }) : super(
          executor ??
              driftDatabase(
                name: databaseName,
                native: DriftNativeOptions(
                  shareAcrossIsolates: shareAcrossIsolates,
                ),
              ),
        );

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(visitedCellBounds);
            await _backfillBounds();
          }
          if (from < 3) {
            await m.createTable(visitedGridStatsTable);
          }
        },
      );

  Future<void> _backfillBounds() async {
    final rows = await customSelect(
      'SELECT res, cell_id FROM visits_lifetime',
    ).get();
    if (rows.isEmpty) {
      return;
    }

    final h3Service = VisitedGridH3Service();
    for (var i = 0; i < rows.length; i += kVisitedGridDaoBatchSize) {
      final end = i + kVisitedGridDaoBatchSize > rows.length
          ? rows.length
          : i + kVisitedGridDaoBatchSize;
      final batchRows = rows.sublist(i, end);
      final boundsRows = <VisitedCellBoundsCompanion>[];
      for (final row in batchRows) {
        final cellId = row.read<String>('cell_id');
        final cell = h3Service.decodeCellId(cellId);
        final segments = h3Service.cellBounds(cell);
        for (final segment in segments) {
          boundsRows.add(
            VisitedCellBoundsCompanion(
              res: Value(segment.resolution),
              cellId: Value(segment.cellId),
              segment: Value(segment.segment),
              minLatE5: Value(segment.minLatE5),
              maxLatE5: Value(segment.maxLatE5),
              minLonE5: Value(segment.minLonE5),
              maxLonE5: Value(segment.maxLonE5),
            ),
          );
        }
      }
      await batch((b) {
        b.insertAll(
          visitedCellBounds,
          boundsRows,
          mode: InsertMode.insertOrIgnore,
        );
      });
    }
  }
}

class VisitedGridUpsertResult {
  const VisitedGridUpsertResult({
    required this.isNewBaseCell,
    this.statsRow,
  });

  final bool isNewBaseCell;
  final VisitedGridStatsRow? statsRow;
}

@DriftAccessor(
  tables: [
    VisitsDaily,
    VisitsLifetime,
    VisitsLifetimeDays,
    VisitedCellBounds,
    VisitedGridMeta,
    VisitedGridStatsTable,
  ],
)
class VisitedGridDao extends DatabaseAccessor<VisitedGridDatabase>
    with _$VisitedGridDaoMixin {
  VisitedGridDao(super.db);

  Future<VisitedGridUpsertResult> upsertVisit({
    required List<VisitedGridCell> cells,
    required List<VisitedGridCellBounds> cellBounds,
    required int day,
    required int hourMask,
    required int epochSeconds,
    required int latE5,
    required int lonE5,
    required int baseResolution,
    required String baseCellId,
    required double baseCellAreaM2,
  }) async {
    if (cells.isEmpty) {
      return const VisitedGridUpsertResult(isNewBaseCell: false);
    }

    var insertedBaseCell = false;
    await transaction(() async {
      for (final cell in cells) {
        await customStatement(
          '''
INSERT INTO visits_daily (
  res,
  cell_id,
  day_yyyy_mmdd,
  hour_mask,
  first_ts,
  last_ts,
  samples,
  lat_e5,
  lon_e5
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
ON CONFLICT(res, cell_id, day_yyyy_mmdd) DO UPDATE SET
  hour_mask = visits_daily.hour_mask | excluded.hour_mask,
  first_ts = MIN(visits_daily.first_ts, excluded.first_ts),
  last_ts = MAX(visits_daily.last_ts, excluded.last_ts),
  samples = visits_daily.samples + excluded.samples,
  lat_e5 = excluded.lat_e5,
  lon_e5 = excluded.lon_e5
''',
          [
            cell.resolution,
            cell.cellId,
            day,
            hourMask,
            epochSeconds,
            epochSeconds,
            1,
            latE5,
            lonE5,
          ],
        );

        final inserted = await _insertLifetimeRow(
          cell: cell,
          epochSeconds: epochSeconds,
          latE5: latE5,
          lonE5: lonE5,
        );
        if (!inserted) {
          await _updateLifetimeRow(
            cell: cell,
            epochSeconds: epochSeconds,
            latE5: latE5,
            lonE5: lonE5,
          );
        }
        if (cell.resolution == baseResolution &&
            cell.cellId == baseCellId &&
            inserted) {
          insertedBaseCell = true;
        }

        await customStatement(
          '''
INSERT OR IGNORE INTO visits_lifetime_days (
  res,
  cell_id,
  day_yyyy_mmdd
) VALUES (?, ?, ?)
''',
          [cell.resolution, cell.cellId, day],
        );

        final changes =
            await customSelect('SELECT changes() AS changes').getSingle();
        if (changes.read<int>('changes') > 0) {
          await customStatement(
            '''
UPDATE visits_lifetime
SET days_visited = days_visited + 1
WHERE res = ? AND cell_id = ?
''',
            [cell.resolution, cell.cellId],
          );
        }
      }

      for (final bounds in cellBounds) {
        await customStatement(
          '''
INSERT OR IGNORE INTO visited_cell_bounds (
  res,
  cell_id,
  segment,
  min_lat_e5,
  max_lat_e5,
  min_lon_e5,
  max_lon_e5
) VALUES (?, ?, ?, ?, ?, ?, ?)
''',
          [
            bounds.resolution,
            bounds.cellId,
            bounds.segment,
            bounds.minLatE5,
            bounds.maxLatE5,
            bounds.minLonE5,
            bounds.maxLonE5,
          ],
        );
      }

      if (insertedBaseCell) {
        await _incrementStats(
          deltaAreaM2: baseCellAreaM2,
          epochSeconds: epochSeconds,
        );
      }
    });

    if (!insertedBaseCell) {
      return const VisitedGridUpsertResult(isNewBaseCell: false);
    }
    final stats = await fetchStats();
    return VisitedGridUpsertResult(
      isNewBaseCell: true,
      statsRow: stats,
    );
  }

  Future<bool> _insertLifetimeRow({
    required VisitedGridCell cell,
    required int epochSeconds,
    required int latE5,
    required int lonE5,
  }) async {
    await customStatement(
      '''
INSERT OR IGNORE INTO visits_lifetime (
  res,
  cell_id,
  first_ts,
  last_ts,
  samples,
  days_visited,
  lat_e5,
  lon_e5
) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
''',
      [
        cell.resolution,
        cell.cellId,
        epochSeconds,
        epochSeconds,
        1,
        0,
        latE5,
        lonE5,
      ],
    );
    final changes =
        await customSelect('SELECT changes() AS changes').getSingle();
    return changes.read<int>('changes') > 0;
  }

  Future<void> _updateLifetimeRow({
    required VisitedGridCell cell,
    required int epochSeconds,
    required int latE5,
    required int lonE5,
  }) {
    return customStatement(
      '''
UPDATE visits_lifetime
SET first_ts = MIN(first_ts, ?),
    last_ts = MAX(last_ts, ?),
    samples = samples + 1,
    lat_e5 = ?,
    lon_e5 = ?
WHERE res = ? AND cell_id = ?
''',
      [
        epochSeconds,
        epochSeconds,
        latE5,
        lonE5,
        cell.resolution,
        cell.cellId,
      ],
    );
  }

  Future<void> _incrementStats({
    required double deltaAreaM2,
    required int epochSeconds,
  }) {
    return customStatement(
      '''
INSERT INTO visited_grid_stats (
  id,
  total_area_m2,
  cell_count,
  canonical_version,
  last_updated_ts,
  last_reconciled_ts
) VALUES (0, ?, 1, 1, ?, NULL)
ON CONFLICT(id) DO UPDATE SET
  total_area_m2 = visited_grid_stats.total_area_m2 + excluded.total_area_m2,
  cell_count = visited_grid_stats.cell_count + 1,
  canonical_version = visited_grid_stats.canonical_version + 1,
  last_updated_ts = excluded.last_updated_ts
''',
      [deltaAreaM2, epochSeconds],
    );
  }

  Future<VisitedGridStatsRow?> fetchStats() {
    return (select(visitedGridStatsTable)
          ..where((tbl) => tbl.id.equals(kVisitedGridStatsRowId)))
        .getSingleOrNull();
  }

  Future<void> upsertStats(VisitedGridStatsRow row) {
    return into(visitedGridStatsTable).insertOnConflictUpdate(row);
  }

  Future<int> countBoundsForResolution(int resolution) async {
    final row = await customSelect(
      'SELECT COUNT(*) AS total FROM visited_cell_bounds WHERE res = ?',
      variables: [Variable.withInt(resolution)],
    ).getSingle();
    return row.read<int>('total');
  }

  Future<List<String>> fetchLifetimeCellIds(int resolution) async {
    final rows = await customSelect(
      'SELECT cell_id FROM visits_lifetime WHERE res = ?',
      variables: [Variable.withInt(resolution)],
    ).get();
    return [for (final row in rows) row.read<String>('cell_id')];
  }

  Future<void> insertCellBounds(List<VisitedGridCellBounds> bounds) async {
    if (bounds.isEmpty) {
      return;
    }
    final companions = [
      for (final segment in bounds)
        VisitedCellBoundsCompanion(
          res: Value(segment.resolution),
          cellId: Value(segment.cellId),
          segment: Value(segment.segment),
          minLatE5: Value(segment.minLatE5),
          maxLatE5: Value(segment.maxLatE5),
          minLonE5: Value(segment.minLonE5),
          maxLonE5: Value(segment.maxLonE5),
        ),
    ];
    await batch((batch) {
      batch.insertAll(
        visitedCellBounds,
        companions,
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  Future<int?> fetchLastCleanupTs() async {
    final row = await (select(visitedGridMeta)
          ..where((tbl) => tbl.id.equals(kVisitedGridMetaRowId)))
        .getSingleOrNull();
    return row?.lastCleanupTs;
  }

  Future<void> setLastCleanupTs(int epochSeconds) async {
    await into(visitedGridMeta).insert(
      VisitedGridMetaCompanion(
        id: const Value(kVisitedGridMetaRowId),
        lastCleanupTs: Value(epochSeconds),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<int> deleteDailyOlderThan(int cutoffDay) {
    return (delete(visitsDaily)
          ..where((tbl) => tbl.dayYyyyMmdd.isSmallerThanValue(cutoffDay)))
        .go();
  }

  Future<Set<String>> fetchVisitedDailyCells({
    required int resolution,
    required List<String> cellIds,
    required int startDay,
    required int endDay,
  }) async {
    if (cellIds.isEmpty) {
      return <String>{};
    }

    final result = <String>{};
    for (final chunk in _chunk(cellIds, kVisitedGridMaxInClauseItems)) {
      final placeholders = List.filled(chunk.length, '?').join(', ');
      final query = '''
SELECT DISTINCT cell_id
FROM visits_daily
WHERE res = ?
  AND day_yyyy_mmdd BETWEEN ? AND ?
  AND cell_id IN ($placeholders)
''';
      final variables = <Variable>[
        Variable.withInt(resolution),
        Variable.withInt(startDay),
        Variable.withInt(endDay),
        ...chunk.map(Variable.withString),
      ];
      final rows = await customSelect(query, variables: variables).get();
      for (final row in rows) {
        result.add(row.read<String>('cell_id'));
      }
    }

    return result;
  }

  Future<Set<String>> fetchVisitedDailyInBounds({
    required int resolution,
    required int startDay,
    required int endDay,
    required int southLatE5,
    required int northLatE5,
    required int westLonE5,
    required int eastLonE5,
  }) async {
    final query = '''
SELECT DISTINCT b.cell_id
FROM visited_cell_bounds b
JOIN visits_daily d
  ON d.res = b.res AND d.cell_id = b.cell_id
WHERE b.res = ?
  AND d.day_yyyy_mmdd BETWEEN ? AND ?
  AND b.max_lat_e5 >= ?
  AND b.min_lat_e5 <= ?
  AND b.max_lon_e5 >= ?
  AND b.min_lon_e5 <= ?
''';
    final variables = <Variable>[
      Variable.withInt(resolution),
      Variable.withInt(startDay),
      Variable.withInt(endDay),
      Variable.withInt(southLatE5),
      Variable.withInt(northLatE5),
      Variable.withInt(westLonE5),
      Variable.withInt(eastLonE5),
    ];
    final rows = await customSelect(query, variables: variables).get();
    return {
      for (final row in rows) row.read<String>('cell_id'),
    };
  }

  Future<Set<String>> fetchVisitedLifetimeCells({
    required int resolution,
    required List<String> cellIds,
  }) async {
    if (cellIds.isEmpty) {
      return <String>{};
    }

    final result = <String>{};
    for (final chunk in _chunk(cellIds, kVisitedGridMaxInClauseItems)) {
      final placeholders = List.filled(chunk.length, '?').join(', ');
      final query = '''
SELECT cell_id
FROM visits_lifetime
WHERE res = ?
  AND cell_id IN ($placeholders)
''';
      final variables = <Variable>[
        Variable.withInt(resolution),
        ...chunk.map(Variable.withString),
      ];
      final rows = await customSelect(query, variables: variables).get();
      for (final row in rows) {
        result.add(row.read<String>('cell_id'));
      }
    }

    return result;
  }

  Future<Set<String>> fetchVisitedLifetimeInBounds({
    required int resolution,
    required int southLatE5,
    required int northLatE5,
    required int westLonE5,
    required int eastLonE5,
  }) async {
    final query = '''
SELECT DISTINCT b.cell_id
FROM visited_cell_bounds b
JOIN visits_lifetime v
  ON v.res = b.res AND v.cell_id = b.cell_id
WHERE b.res = ?
  AND b.max_lat_e5 >= ?
  AND b.min_lat_e5 <= ?
  AND b.max_lon_e5 >= ?
  AND b.min_lon_e5 <= ?
''';
    final variables = <Variable>[
      Variable.withInt(resolution),
      Variable.withInt(southLatE5),
      Variable.withInt(northLatE5),
      Variable.withInt(westLonE5),
      Variable.withInt(eastLonE5),
    ];
    final rows = await customSelect(query, variables: variables).get();
    return {
      for (final row in rows) row.read<String>('cell_id'),
    };
  }

  Iterable<List<T>> _chunk<T>(List<T> input, int size) sync* {
    for (var i = 0; i < input.length; i += size) {
      yield input.sublist(
        i,
        i + size > input.length ? input.length : i + size,
      );
    }
  }
}
