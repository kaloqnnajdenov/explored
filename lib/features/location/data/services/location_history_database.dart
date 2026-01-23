import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/lat_lng_sample.dart';

part 'location_history_database.g.dart';

@TableIndex(name: 'location_samples_timestamp', columns: {#timestamp})
class LocationSamples extends Table {
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  /// ISO-8601 UTC timestamp for stable ordering and export.
  TextColumn get timestamp => text()();
  RealColumn get accuracyMeters => real().nullable()();
  BoolColumn get isInterpolated =>
      boolean().withDefault(const Constant(false))();
  TextColumn get source => textEnum<LatLngSampleSource>()();
}

@DriftDatabase(tables: [LocationSamples], daos: [LocationHistoryDao])
class LocationHistoryDatabase extends _$LocationHistoryDatabase {
  LocationHistoryDatabase({
    QueryExecutor? executor,
    String databaseName = 'location_history',
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
  LocationHistoryDao(super.db);

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
    return LocationSamplesCompanion.insert(
      latitude: sample.latitude,
      longitude: sample.longitude,
      timestamp: sample.timestamp.toUtc().toIso8601String(),
      accuracyMeters: Value(sample.accuracyMeters),
      isInterpolated: Value(sample.isInterpolated),
      source: sample.source,
    );
  }
}
