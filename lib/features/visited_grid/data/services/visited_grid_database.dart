import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/visited_grid_cell.dart';

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

class VisitedGridMeta extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  IntColumn get lastCleanupTs => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    VisitsDaily,
    VisitsLifetime,
    VisitsLifetimeDays,
    VisitedGridMeta,
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
  int get schemaVersion => 1;
}

@DriftAccessor(
  tables: [
    VisitsDaily,
    VisitsLifetime,
    VisitsLifetimeDays,
    VisitedGridMeta,
  ],
)
class VisitedGridDao extends DatabaseAccessor<VisitedGridDatabase>
    with _$VisitedGridDaoMixin {
  VisitedGridDao(super.db);

  static const _metaRowId = 0;
  static const _maxInClauseItems = 900;

  Future<void> upsertVisit({
    required List<VisitedGridCell> cells,
    required int day,
    required int hourMask,
    required int epochSeconds,
    required int latE5,
    required int lonE5,
  }) async {
    if (cells.isEmpty) {
      return;
    }

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

        await customStatement(
          '''
INSERT INTO visits_lifetime (
  res,
  cell_id,
  first_ts,
  last_ts,
  samples,
  days_visited,
  lat_e5,
  lon_e5
) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
ON CONFLICT(res, cell_id) DO UPDATE SET
  first_ts = MIN(visits_lifetime.first_ts, excluded.first_ts),
  last_ts = MAX(visits_lifetime.last_ts, excluded.last_ts),
  samples = visits_lifetime.samples + excluded.samples,
  lat_e5 = excluded.lat_e5,
  lon_e5 = excluded.lon_e5
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
    });
  }

  Future<int?> fetchLastCleanupTs() async {
    final row = await (select(visitedGridMeta)
          ..where((tbl) => tbl.id.equals(_metaRowId)))
        .getSingleOrNull();
    return row?.lastCleanupTs;
  }

  Future<void> setLastCleanupTs(int epochSeconds) async {
    await into(visitedGridMeta).insert(
      VisitedGridMetaCompanion(
        id: const Value(_metaRowId),
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
    for (final chunk in _chunk(cellIds, _maxInClauseItems)) {
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

  Future<Set<String>> fetchVisitedLifetimeCells({
    required int resolution,
    required List<String> cellIds,
  }) async {
    if (cellIds.isEmpty) {
      return <String>{};
    }

    final result = <String>{};
    for (final chunk in _chunk(cellIds, _maxInClauseItems)) {
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

  Iterable<List<T>> _chunk<T>(List<T> input, int size) sync* {
    for (var i = 0; i < input.length; i += size) {
      yield input.sublist(
        i,
        i + size > input.length ? input.length : i + size,
      );
    }
  }
}
