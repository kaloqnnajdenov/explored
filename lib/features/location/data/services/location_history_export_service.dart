import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:share_plus/share_plus.dart';

import '../models/history_export_result.dart';
import '../models/lat_lng_sample.dart';
import 'location_history_database.dart';

abstract class PathProviderClient {
  Future<Directory> getTemporaryDirectory();
}

class PathProviderClientImpl implements PathProviderClient {
  @override
  Future<Directory> getTemporaryDirectory() {
    return path_provider.getTemporaryDirectory();
  }
}

abstract class ShareClient {
  Future<void> shareFile({
    required String path,
    required String mimeType,
  });
}

class SharePlusClient implements ShareClient {
  @override
  Future<void> shareFile({
    required String path,
    required String mimeType,
  }) async {
    await Share.shareXFiles(
      [
        XFile(path, mimeType: mimeType),
      ],
    );
  }
}

abstract class FileSaveClient {
  Future<String?> saveFile({
    required String fileName,
    required List<String> allowedExtensions,
    required Uint8List bytes,
  });
}

class FilePickerSaveClient implements FileSaveClient {
  @override
  Future<String?> saveFile({
    required String fileName,
    required List<String> allowedExtensions,
    required Uint8List bytes,
  }) async {
    try {
      return FilePicker.platform.saveFile(
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        bytes: bytes,
      );
    } on UnsupportedError {
      final path = await FilePicker.platform.saveFile(
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );
      if (path == null) {
        return null;
      }
      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);
      return path;
    }
  }
}

class LocationHistoryExportService {
  LocationHistoryExportService({
    required LocationHistoryDao historyDao,
    required PathProviderClient pathProvider,
    required ShareClient shareClient,
    required FileSaveClient fileSaveClient,
    DateTime Function()? nowProvider,
  })  : _historyDao = historyDao,
        _pathProvider = pathProvider,
        _shareClient = shareClient,
        _fileSaveClient = fileSaveClient,
        _now = nowProvider ?? DateTime.now;

  final LocationHistoryDao _historyDao;
  final PathProviderClient _pathProvider;
  final ShareClient _shareClient;
  final FileSaveClient _fileSaveClient;
  final DateTime Function() _now;

  /// Builds a full CSV export and opens the platform share sheet.
  Future<HistoryExportResult> exportHistory() async {
    try {
      final exportData = await _historyDao.fetchExportData();
      final filePath = await _writeCsv(
        exportData,
        directoryProvider: _pathProvider.getTemporaryDirectory,
      );
      await _shareClient.shareFile(path: filePath, mimeType: 'text/csv');
      _logSuccess(
        action: 'share',
        filePath: filePath,
        exportData: exportData,
      );
      return HistoryExportResult.success(filePath: filePath);
    } catch (error, stackTrace) {
      _logFailure(action: 'share', error: error, stackTrace: stackTrace);
      return HistoryExportResult.failure(error: error);
    }
  }

  /// Builds a full CSV export and saves it to a files directory.
  Future<HistoryExportResult> downloadHistory() async {
    try {
      final exportData = await _historyDao.fetchExportData();
      final csv = _buildCsv(exportData);
      final fileName = _buildFilename(_now());
      final bytes = Uint8List.fromList(utf8.encode(csv));
      final filePath = await _fileSaveClient.saveFile(
        fileName: fileName,
        allowedExtensions: const ['csv'],
        bytes: bytes,
      );
      if (filePath == null || filePath.isEmpty) {
        _logFailure(
          action: 'download',
          error: 'User cancelled download',
          stackTrace: StackTrace.current,
        );
        return const HistoryExportResult.failure(
          error: 'download_cancelled',
        );
      }
      _logSuccess(
        action: 'download',
        filePath: filePath,
        exportData: exportData,
      );
      return HistoryExportResult.success(filePath: filePath);
    } catch (error, stackTrace) {
      _logFailure(action: 'download', error: error, stackTrace: stackTrace);
      return HistoryExportResult.failure(error: error);
    }
  }

  String _buildCsv(LocationHistoryExportData exportData) {
    final buffer = StringBuffer();
    buffer.writeln(_buildRow(exportData.columnNames));
    for (final row in exportData.rows) {
      buffer.writeln(
        _buildRow(
          [
            for (final value in row) _formatCsvValue(value),
          ],
        ),
      );
    }
    return buffer.toString();
  }

  String _buildRow(List<String> values) {
    return values.map(_escapeCsv).join(',');
  }

  String _formatCsvValue(Object? value) {
    if (value == null) {
      return '';
    }
    if (value is DateTime) {
      return value.toUtc().toIso8601String();
    }
    if (value is LatLngSampleSource) {
      return value.name;
    }
    if (value is double) {
      return value.toString();
    }
    if (value is bool) {
      return value ? 'true' : 'false';
    }
    return value.toString();
  }

  String _escapeCsv(String value) {
    if (!value.contains(',') &&
        !value.contains('"') &&
        !value.contains('\n') &&
        !value.contains('\r')) {
      return value;
    }
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  Future<String> _writeCsv(
    LocationHistoryExportData exportData, {
    required Future<Directory> Function() directoryProvider,
  }) async {
    final csv = _buildCsv(exportData);
    final directory = await directoryProvider();
    await directory.create(recursive: true);
    final filename = _buildFilename(_now());
    final filePath = _joinPath(directory.path, filename);
    final file = File(filePath);
    await file.writeAsString(csv, encoding: utf8);
    return filePath;
  }

  String _buildFilename(DateTime timestamp) {
    final local = timestamp.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final second = local.second.toString().padLeft(2, '0');
    return 'gps_history_export_$year-$month-${day}_$hour-$minute-$second.csv';
  }

  String _joinPath(String directory, String filename) {
    final separator = Platform.pathSeparator;
    if (directory.endsWith(separator)) {
      return '$directory$filename';
    }
    return '$directory$separator$filename';
  }

  void _logSuccess({
    required String action,
    required String filePath,
    required LocationHistoryExportData exportData,
  }) {
    debugPrint(
      'History $action ready: path=$filePath rows=${exportData.rows.length} '
      'columns=${exportData.columnNames.length}',
    );
  }

  void _logFailure({
    required String action,
    required Object error,
    required StackTrace stackTrace,
  }) {
    debugPrint('History $action failed: $error');
    debugPrint('$stackTrace');
  }
}
