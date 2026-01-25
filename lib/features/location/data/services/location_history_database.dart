import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../../../constants.dart';
import '../models/lat_lng_sample.dart';
import 'location_history_h3_service.dart';

part 'location_history_database.g.dart';

@TableIndex(name: 'location_samples_timestamp', columns: {#timestamp})
@TableIndex(name: 'location_samples_h3_base', columns: {#h3Base})
class LocationSamples extends Table {
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  /// ISO-8601 UTC timestamp for stable ordering and export.
  TextColumn get timestamp => text()();
  RealColumn get accuracyMeters => real().nullable()();
  BoolColumn get isInterpolated =>
      boolean().withDefault(const Constant(false))();
  TextColumn get source => textEnum<LatLngSampleSource>()();
  TextColumn get h3Base => text().nullable()();
}

@DriftDatabase(tables: [LocationSamples], daos: [LocationHistoryDao])
class LocationHistoryDatabase extends _$LocationHistoryDatabase {
  LocationHistoryDatabase({
    QueryExecutor? executor,
    String databaseName = 'location_history',
    bool shareAcrossIsolates = false,
    LocationHistoryH3Service? h3Service,
  })  : _h3Service = h3Service ?? LocationHistoryH3Service(),
        super(
          executor ??
              driftDatabase(
                name: databaseName,
                native: DriftNativeOptions(
                  shareAcrossIsolates: shareAcrossIsolates,
                ),
              ),
        );

  final LocationHistoryH3Service _h3Service;

  @override
  late final LocationHistoryDao locationHistoryDao = LocationHistoryDao(
    this,
    h3Service: _h3Service,
  );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(locationSamples, locationSamples.h3Base);
            await customStatement(
              'CREATE INDEX IF NOT EXISTS location_samples_h3_base '
              'ON location_samples(h3_base)',
            );
            await _backfillH3Base();
          }
        },
      );

  Future<void> _backfillH3Base() async {
    final rows = await customSelect(
      'SELECT rowid, latitude, longitude '
      'FROM location_samples '
      'WHERE h3_base IS NULL',
    ).get();
    if (rows.isEmpty) {
      return;
    }

    final h3Service = _h3Service;
    await batch((batch) {
      for (final row in rows) {
        final rowId = row.read<int>('rowid');
        final latitude = row.read<double>('latitude');
        final longitude = row.read<double>('longitude');
        if (!latitude.isFinite ||
            !longitude.isFinite ||
            latitude < -90 ||
            latitude > 90 ||
            longitude < -180 ||
            longitude > 180) {
          continue;
        }
        final cellId = h3Service.cellIdForLatLng(
          latitude: latitude,
          longitude: longitude,
        );
        batch.customStatement(
          'UPDATE location_samples SET h3_base = ? WHERE rowid = ?',
          [cellId, rowId],
        );
      }
    });
  }
}

class LocationHistoryExportData {
  const LocationHistoryExportData({
    required this.columnNames,
    required this.rows,
  });

  final List<String> columnNames;
  final List<List<Object?>> rows;
}

@DriftAccessor(tables: [LocationSamples])
class LocationHistoryDao extends DatabaseAccessor<LocationHistoryDatabase>
    with _$LocationHistoryDaoMixin {
  LocationHistoryDao(
    super.db, {
    LocationHistoryH3Service? h3Service,
  }) : _h3Service = h3Service ?? LocationHistoryH3Service();

  final LocationHistoryH3Service _h3Service;

  List<String> get exportColumnNames =>
      locationSamples.$columns.map((column) => column.$name).toList();

  Future<List<LocationSample>> fetchAllSamples() {
    return (select(locationSamples)
          ..orderBy(
            [
              (tbl) => OrderingTerm(expression: tbl.timestamp),
            ],
          ))
        .get();
  }

  Future<List<LocationSample>> fetchAllSamplesStable() {
    return (select(locationSamples)
          ..orderBy(
            [
              (tbl) => OrderingTerm(expression: tbl.timestamp),
              (tbl) => OrderingTerm(expression: tbl.latitude),
              (tbl) => OrderingTerm(expression: tbl.longitude),
            ],
          ))
        .get();
  }

  Future<int> fetchSampleCount() async {
    final row = await customSelect(
      'SELECT COUNT(*) AS count FROM location_samples',
    ).getSingle();
    return row.read<int>('count');
  }

  Future<void> replaceAllSamples(Iterable<LatLngSample> samples) async {
    await transaction(() async {
      await delete(locationSamples).go();
      if (samples.isEmpty) {
        return;
      }
      final entries = [
        for (final sample in samples) _toCompanion(sample),
      ];
      await batch((batch) {
        batch.insertAll(locationSamples, entries);
      });
    });
  }

  Future<LocationHistoryExportData> fetchExportData() async {
    final rows = await fetchAllSamples();
    final columnNames = exportColumnNames;
    final rowValues = <List<Object?>>[];
    for (final row in rows) {
      rowValues.add(
        [
          for (final name in columnNames) _valueForColumn(row, name),
        ],
      );
    }
    return LocationHistoryExportData(
      columnNames: columnNames,
      rows: rowValues,
    );
  }

  Object? _valueForColumn(LocationSample row, String columnName) {
    switch (columnName) {
      case 'latitude':
        return row.latitude;
      case 'longitude':
        return row.longitude;
      case 'timestamp':
        return row.timestamp;
      case 'accuracy_meters':
        return row.accuracyMeters;
      case 'is_interpolated':
        return row.isInterpolated;
      case 'source':
        return row.source;
      case 'h3_base':
        return row.h3Base;
      default:
        return null;
    }
  }

  Future<void> insertSamples(Iterable<LatLngSample> samples) async {
    if (samples.isEmpty) {
      return;
    }
    final entries = [
      for (final sample in samples) _toCompanion(sample),
    ];
    await batch((batch) {
      batch.insertAll(locationSamples, entries);
    });
  }

  LocationSamplesCompanion _toCompanion(LatLngSample sample) {
    final h3Base = _h3Service.cellIdForLatLng(
      latitude: sample.latitude,
      longitude: sample.longitude,
    );
    return LocationSamplesCompanion.insert(
      latitude: sample.latitude,
      longitude: sample.longitude,
      timestamp: sample.timestamp.toUtc().toIso8601String(),
      accuracyMeters: Value(sample.accuracyMeters),
      isInterpolated: Value(sample.isInterpolated),
      source: sample.source,
      h3Base: Value(h3Base),
    );
  }

  Future<Set<String>> fetchExistingBaseCellIds(
    Iterable<String> cellIds,
  ) async {
    final ids = cellIds.toList(growable: false);
    if (ids.isEmpty) {
      return const <String>{};
    }
    final results = <String>{};
    for (final chunk in _chunk(ids, kVisitedGridMaxInClauseItems)) {
      final placeholders = List.filled(chunk.length, '?').join(', ');
      final rows = await customSelect(
        'SELECT DISTINCT h3_base FROM location_samples '
        'WHERE h3_base IS NOT NULL AND h3_base IN ($placeholders)',
        variables: chunk.map(Variable.withString).toList(),
      ).get();
      for (final row in rows) {
        final value = row.read<String>('h3_base');
        results.add(value);
      }
    }
    return results;
  }

  Future<int> countSamplesForBaseCellIds(
    Iterable<String> cellIds,
  ) async {
    final ids = cellIds.toList(growable: false);
    if (ids.isEmpty) {
      return 0;
    }
    var total = 0;
    for (final chunk in _chunk(ids, kVisitedGridMaxInClauseItems)) {
      final placeholders = List.filled(chunk.length, '?').join(', ');
      final row = await customSelect(
        'SELECT COUNT(*) AS count FROM location_samples '
        'WHERE h3_base IN ($placeholders)',
        variables: chunk.map(Variable.withString).toList(),
      ).getSingle();
      total += row.read<int>('count');
    }
    return total;
  }

  Future<int> deleteSamplesForBaseCellIds(
    Iterable<String> cellIds,
  ) async {
    final ids = cellIds.toList(growable: false);
    if (ids.isEmpty) {
      return 0;
    }
    var deleted = 0;
    for (final chunk in _chunk(ids, kVisitedGridMaxInClauseItems)) {
      final placeholders = List.filled(chunk.length, '?').join(', ');
      await customStatement(
        'DELETE FROM location_samples WHERE h3_base IN ($placeholders)',
        chunk,
      );
      final row =
          await customSelect('SELECT changes() AS count').getSingle();
      deleted += row.read<int>('count');
    }
    return deleted;
  }

  Iterable<List<String>> _chunk(List<String> items, int size) sync* {
    if (items.isEmpty) {
      return;
    }
    for (var i = 0; i < items.length; i += size) {
      final end = i + size > items.length ? items.length : i + size;
      yield items.sublist(i, end);
    }
  }
}
