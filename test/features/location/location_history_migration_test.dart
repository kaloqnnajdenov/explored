import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:drift/native.dart';

import 'package:explored/features/location/data/services/location_history_database.dart';
import 'package:explored/features/location/data/services/location_history_h3_service.dart';

void main() {
  test('migration adds h3_base and backfills existing rows', () async {
    final tempDir = await Directory.systemTemp.createTemp('history_migration');
    final dbFile = File('${tempDir.path}/history.sqlite');

    final sqliteDb = sqlite3.open(dbFile.path);
    sqliteDb.execute('''
CREATE TABLE location_samples (
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  timestamp TEXT NOT NULL,
  accuracy_meters REAL,
  is_interpolated INTEGER NOT NULL DEFAULT 0,
  source TEXT NOT NULL
);
''');
    sqliteDb.execute(
      'CREATE INDEX location_samples_timestamp ON location_samples(timestamp)');
    sqliteDb.execute('PRAGMA user_version = 1');
    sqliteDb.execute('''
INSERT INTO location_samples (
  latitude, longitude, timestamp, accuracy_meters, is_interpolated, source
) VALUES (10.0, 20.0, '2024-01-01T00:00:00.000Z', NULL, 0, 'live');
''');
    sqliteDb.dispose();

    final resolver = (double lat, double lon) =>
        '${(lat * 100000).round()}_${(lon * 100000).round()}';
    final driftDb = LocationHistoryDatabase(
      executor: NativeDatabase(dbFile),
      h3Service: LocationHistoryH3Service(cellIdResolver: resolver),
    );

    final rows = await driftDb.customSelect(
      'SELECT h3_base FROM location_samples',
    ).get();
    expect(rows.length, 1);
    final h3Base = rows.first.read<String>('h3_base');
    final expected = LocationHistoryH3Service(
      cellIdResolver: resolver,
    ).cellIdForLatLng(
      latitude: 10.0,
      longitude: 20.0,
    );
    expect(h3Base, expected);

    final indexRows = await driftDb
        .customSelect("PRAGMA index_list('location_samples')")
        .get();
    final indexNames = [
      for (final row in indexRows) row.read<String>('name'),
    ];
    expect(indexNames, contains('location_samples_h3_base'));

    await driftDb.close();
    await tempDir.delete(recursive: true);
  });
}
