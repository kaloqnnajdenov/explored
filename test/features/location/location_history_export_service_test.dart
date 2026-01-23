import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/location/data/models/history_export_result.dart';
import 'package:explored/features/location/data/services/location_history_database.dart';
import 'package:explored/features/location/data/services/location_history_export_service.dart';

class FakeHistoryDao extends LocationHistoryDao {
  FakeHistoryDao(
    super.db, {
    required this.exportData,
  });

  final LocationHistoryExportData exportData;

  @override
  Future<LocationHistoryExportData> fetchExportData() async {
    return exportData;
  }
}

class FakePathProviderClient implements PathProviderClient {
  FakePathProviderClient(this.temporaryDirectory);

  final Directory temporaryDirectory;

  @override
  Future<Directory> getTemporaryDirectory() async => temporaryDirectory;
}

class FakeShareClient implements ShareClient {
  int calls = 0;
  String? lastPath;
  String? lastMimeType;

  @override
  Future<void> shareFile({
    required String path,
    required String mimeType,
  }) async {
    calls += 1;
    lastPath = path;
    lastMimeType = mimeType;
  }
}

class FakeFileSaveClient implements FileSaveClient {
  FakeFileSaveClient(this.pathToReturn);

  int calls = 0;
  String? lastFileName;
  List<String>? lastExtensions;
  Uint8List? lastBytes;
  String? pathToReturn;

  @override
  Future<String?> saveFile({
    required String fileName,
    required List<String> allowedExtensions,
    required Uint8List bytes,
  }) async {
    calls += 1;
    lastFileName = fileName;
    lastExtensions = allowedExtensions;
    lastBytes = bytes;
    final path = pathToReturn;
    if (path == null) {
      return null;
    }
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return path;
  }
}

LocationHistoryDatabase _buildTestDb() {
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return LocationHistoryDatabase(executor: NativeDatabase.memory());
}

void main() {
  test('exportHistory writes CSV and invokes sharing', () async {
    final db = _buildTestDb();
    final exportData = LocationHistoryExportData(
      columnNames: ['alpha', 'beta'],
      rows: [
        ['value,with,comma', 'quote "here"'],
        ['line\nbreak', null],
      ],
    );
    final dao = FakeHistoryDao(db, exportData: exportData);
    final tempDir = await Directory.systemTemp.createTemp('export_test_');
    final pathProvider = FakePathProviderClient(tempDir);
    final shareClient = FakeShareClient();
    final fileSaveClient = FakeFileSaveClient(null);
    final service = LocationHistoryExportService(
      historyDao: dao,
      pathProvider: pathProvider,
      shareClient: shareClient,
      fileSaveClient: fileSaveClient,
      nowProvider: () => DateTime(2024, 1, 2, 3, 4, 5),
    );

    final result = await service.exportHistory();

    expect(result.outcome, HistoryExportOutcome.success);
    expect(shareClient.calls, 1);
    expect(shareClient.lastMimeType, 'text/csv');
    expect(shareClient.lastPath, isNotNull);

    final file = File(result.filePath!);
    final content = await file.readAsString();
    const expected =
        'alpha,beta\n"value,with,comma","quote ""here"""\n"line\nbreak",\n';
    expect(content, expected);

    await tempDir.delete(recursive: true);
    await db.close();
  });

  test('downloadHistory writes CSV without invoking sharing', () async {
    final db = _buildTestDb();
    final exportData = LocationHistoryExportData(
      columnNames: ['alpha', 'beta'],
      rows: [
        ['value,with,comma', 'quote "here"'],
      ],
    );
    final dao = FakeHistoryDao(db, exportData: exportData);
    final tempDir = await Directory.systemTemp.createTemp('download_test_');
    final pathProvider = FakePathProviderClient(tempDir);
    final shareClient = FakeShareClient();
    final fileSaveClient =
        FakeFileSaveClient('${tempDir.path}/saved_export.csv');
    final service = LocationHistoryExportService(
      historyDao: dao,
      pathProvider: pathProvider,
      shareClient: shareClient,
      fileSaveClient: fileSaveClient,
      nowProvider: () => DateTime(2024, 1, 2, 3, 4, 5),
    );

    final result = await service.downloadHistory();

    expect(result.outcome, HistoryExportOutcome.success);
    expect(shareClient.calls, 0);
    expect(result.filePath, isNotNull);
    expect(fileSaveClient.calls, 1);

    final file = File(result.filePath!);
    final content = await file.readAsString();
    const expected =
        'alpha,beta\n"value,with,comma","quote ""here"""\n';
    expect(content, expected);

    await tempDir.delete(recursive: true);
    await db.close();
  });
}
