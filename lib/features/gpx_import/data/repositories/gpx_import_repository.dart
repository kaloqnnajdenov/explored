import 'package:flutter/foundation.dart';

import 'package:explored/features/gpx_import/data/models/gpx_point.dart';
import 'package:explored/features/gpx_import/data/services/gpx_file_picker_service.dart';
import 'package:explored/features/gpx_import/data/services/gpx_parser_service.dart';
import 'package:explored/features/permissions/data/services/file_access_permission_service.dart';
import 'package:explored/features/location/data/models/lat_lng_sample.dart';
import 'package:explored/features/location/data/repositories/location_history_repository.dart';

enum GpxImportOutcome { success, cancelled, failure }

class GpxImportPreparation {
  const GpxImportPreparation({
    required this.outcome,
    this.file,
    this.messageKey,
  });

  final GpxImportOutcome outcome;
  final GpxSelectedFile? file;
  final String? messageKey;
}

class GpxImportResult {
  const GpxImportResult({
    required this.outcome,
    this.addedSamples = 0,
    this.messageKey,
    this.namedArgs,
  });

  final GpxImportOutcome outcome;
  final int addedSamples;
  final String? messageKey;
  final Map<String, String>? namedArgs;
}

abstract class GpxImportRepository {
  Future<GpxImportPreparation> prepareImport();

  Future<GpxImportResult> processFile(GpxSelectedFile file);
}

class DefaultGpxImportRepository implements GpxImportRepository {
  DefaultGpxImportRepository({
    required FileAccessPermissionService fileAccessPermissionService,
    required GpxFilePickerService filePickerService,
    required GpxParserService parserService,
    required LocationHistoryRepository locationHistoryRepository,
    DateTime Function()? nowProvider,
  }) : _fileAccessPermissionService = fileAccessPermissionService,
       _filePickerService = filePickerService,
       _parserService = parserService,
       _locationHistoryRepository = locationHistoryRepository,
       _now = nowProvider ?? DateTime.now;

  final FileAccessPermissionService _fileAccessPermissionService;
  final GpxFilePickerService _filePickerService;
  final GpxParserService _parserService;
  final LocationHistoryRepository _locationHistoryRepository;
  final DateTime Function() _now;

  @override
  Future<GpxImportPreparation> prepareImport() async {
    final granted = await _fileAccessPermissionService.isGranted();
    if (!granted) {
      final requested = await _fileAccessPermissionService.request();
      if (!requested) {
        return const GpxImportPreparation(
          outcome: GpxImportOutcome.failure,
          messageKey: 'gpx_import_permission_denied',
        );
      }
    }

    GpxSelectedFile? selection;
    try {
      selection = await _filePickerService.pickGpxFile();
    } catch (error) {
      debugPrint('Failed to open file picker: $error');
      return const GpxImportPreparation(
        outcome: GpxImportOutcome.failure,
        messageKey: 'gpx_import_invalid_file',
      );
    }
    if (selection == null) {
      return const GpxImportPreparation(outcome: GpxImportOutcome.cancelled);
    }

    if (!_isGpxFile(selection.name)) {
      return const GpxImportPreparation(
        outcome: GpxImportOutcome.failure,
        messageKey: 'gpx_import_invalid_extension',
      );
    }

    return GpxImportPreparation(
      outcome: GpxImportOutcome.success,
      file: selection,
    );
  }

  @override
  Future<GpxImportResult> processFile(GpxSelectedFile file) async {
    try {
      final points = await _parserService.parse(file.bytes);
      if (points.isEmpty) {
        return const GpxImportResult(
          outcome: GpxImportOutcome.failure,
          messageKey: 'gpx_import_no_points',
        );
      }

      final samples = _buildSamples(points);
      if (samples.isEmpty) {
        return const GpxImportResult(
          outcome: GpxImportOutcome.failure,
          messageKey: 'gpx_import_invalid_file',
        );
      }

      final addedSamples = await _locationHistoryRepository.addImportedSamples(
        samples,
      );

      return GpxImportResult(
        outcome: GpxImportOutcome.success,
        addedSamples: addedSamples.length,
        messageKey: 'gpx_import_success',
        namedArgs: {'count': addedSamples.length.toString()},
      );
    } catch (error) {
      debugPrint('Failed to import GPX: $error');
      return const GpxImportResult(
        outcome: GpxImportOutcome.failure,
        messageKey: 'gpx_import_invalid_file',
      );
    }
  }

  List<LatLngSample> _buildSamples(List<GpxPoint> points) {
    final results = <LatLngSample>[];
    final baseTime = _now().toUtc();
    DateTime? lastTimestamp;

    for (final point in points) {
      if (!_isValidCoordinate(point.latitude, point.longitude)) {
        continue;
      }

      DateTime timestamp;
      if (point.timestamp != null) {
        timestamp = point.timestamp!.toUtc();
        if (lastTimestamp != null && !timestamp.isAfter(lastTimestamp)) {
          timestamp = lastTimestamp.add(const Duration(seconds: 1));
        }
      } else if (lastTimestamp != null) {
        timestamp = lastTimestamp.add(const Duration(seconds: 1));
      } else {
        timestamp = baseTime;
      }

      lastTimestamp = timestamp;
      results.add(
        LatLngSample(
          latitude: point.latitude,
          longitude: point.longitude,
          timestamp: timestamp,
          isInterpolated: false,
          source: LatLngSampleSource.imported,
        ),
      );
    }

    return results;
  }

  bool _isGpxFile(String filename) {
    return filename.toLowerCase().endsWith('.gpx');
  }

  bool _isValidCoordinate(double latitude, double longitude) {
    if (!latitude.isFinite || !longitude.isFinite) {
      return false;
    }
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }
}
