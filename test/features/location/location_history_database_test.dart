import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/location/data/models/lat_lng_sample.dart';
import 'package:explored/features/location/data/services/location_history_database.dart';

LocationHistoryDatabase _buildTestDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return LocationHistoryDatabase(executor: NativeDatabase.memory());
}

void main() {
  test('fetchAllSamples returns rows ordered by timestamp', () async {
    final db = _buildTestDb();
    final dao = db.locationHistoryDao;

    await dao.insertSamples(
      [
        LatLngSample(
          latitude: 2.0,
          longitude: 2.0,
          timestamp: DateTime.utc(2024, 1, 2),
        ),
        LatLngSample(
          latitude: 1.0,
          longitude: 1.0,
          timestamp: DateTime.utc(2024, 1, 1),
        ),
      ],
    );

    final rows = await dao.fetchAllSamples();
    expect(rows.length, 2);
    expect(rows.first.timestamp, '2024-01-01T00:00:00.000Z');
    expect(rows.last.timestamp, '2024-01-02T00:00:00.000Z');

    await db.close();
  });

  test('fetchExportData includes all columns and rows', () async {
    final db = _buildTestDb();
    final dao = db.locationHistoryDao;

    await dao.insertSamples(
      [
        LatLngSample(
          latitude: 42.0,
          longitude: 23.0,
          timestamp: DateTime.utc(2024, 1, 1, 10, 30, 15),
          accuracyMeters: 5.5,
          isInterpolated: true,
          source: LatLngSampleSource.imported,
        ),
      ],
    );

    final exportData = await dao.fetchExportData();
    expect(
      exportData.columnNames,
      [
        'latitude',
        'longitude',
        'timestamp',
        'accuracy_meters',
        'is_interpolated',
        'source',
      ],
    );
    expect(exportData.rows.length, 1);
    expect(exportData.rows.first[0], 42.0);
    expect(exportData.rows.first[1], 23.0);
    expect(exportData.rows.first[2], '2024-01-01T10:30:15.000Z');
    expect(exportData.rows.first[3], 5.5);
    expect(exportData.rows.first[4], true);
    expect(exportData.rows.first[5], LatLngSampleSource.imported);

    await db.close();
  });

  test('fetchSampleCount returns total rows', () async {
    final db = _buildTestDb();
    final dao = db.locationHistoryDao;

    await dao.insertSamples(
      [
        LatLngSample(
          latitude: 2.0,
          longitude: 2.0,
          timestamp: DateTime.utc(2024, 1, 2),
        ),
        LatLngSample(
          latitude: 1.0,
          longitude: 1.0,
          timestamp: DateTime.utc(2024, 1, 1),
        ),
      ],
    );

    final count = await dao.fetchSampleCount();
    expect(count, 2);

    await db.close();
  });

  test('replaceAllSamples clears and stores new rows', () async {
    final db = _buildTestDb();
    final dao = db.locationHistoryDao;

    await dao.insertSamples(
      [
        LatLngSample(
          latitude: 2.0,
          longitude: 2.0,
          timestamp: DateTime.utc(2024, 1, 2),
        ),
        LatLngSample(
          latitude: 1.0,
          longitude: 1.0,
          timestamp: DateTime.utc(2024, 1, 1),
        ),
      ],
    );

    await dao.replaceAllSamples(
      [
        LatLngSample(
          latitude: 3.0,
          longitude: 3.0,
          timestamp: DateTime.utc(2024, 1, 3),
        ),
      ],
    );

    final rows = await dao.fetchAllSamples();
    expect(rows.length, 1);
    expect(rows.first.latitude, 3.0);
    expect(rows.first.longitude, 3.0);

    await db.close();
  });
}
