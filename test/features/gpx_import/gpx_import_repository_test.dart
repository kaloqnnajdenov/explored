import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/gpx_import/data/models/gpx_point.dart';
import 'package:explored/features/gpx_import/data/repositories/gpx_import_repository.dart';
import 'package:explored/features/gpx_import/data/services/gpx_file_picker_service.dart';
import 'package:explored/features/gpx_import/data/services/gpx_parser_service.dart';
import 'package:explored/features/location/data/location_tracking_config.dart';
import 'package:explored/features/location/data/models/lat_lng_sample.dart';
import 'package:explored/features/location/data/repositories/location_history_repository.dart';
import 'package:explored/features/location/data/services/platform_info.dart';
import 'package:explored/features/permissions/data/services/file_access_permission_service.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_bounds.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_overlay.dart';
import 'package:explored/features/visited_grid/data/models/visited_overlay_polygon.dart';
import 'package:explored/features/visited_grid/data/models/visited_time_filter.dart';
import 'package:explored/features/visited_grid/data/repositories/visited_grid_repository.dart';

class FakePlatformInfo implements PlatformInfo {
  FakePlatformInfo({
    required this.isAndroid,
    required this.isIOS,
    required this.androidSdkInt,
  });

  @override
  final bool isAndroid;

  @override
  final bool isIOS;

  @override
  final int? androidSdkInt;
}

class FakeFileAccessPermissionService implements FileAccessPermissionService {
  FakeFileAccessPermissionService({
    required this.granted,
    required this.requestResult,
  });

  bool granted;
  bool requestResult;

  @override
  Future<bool> isGranted() async => granted;

  @override
  Future<bool> request() async => requestResult;
}

class FakeGpxFilePickerService extends GpxFilePickerService {
  FakeGpxFilePickerService(
    this.selection, {
    PlatformInfo? platformInfo,
  }) : super(
          client: _FakeFilePickerClient(selection),
          platformInfo: platformInfo ??
              FakePlatformInfo(
                isAndroid: false,
                isIOS: true,
                androidSdkInt: null,
              ),
        );

  final GpxSelectedFile? selection;
}

class _FakeFilePickerClient implements FilePickerClient {
  _FakeFilePickerClient(this.selection);

  final GpxSelectedFile? selection;
  FileType? lastType;
  List<String>? lastAllowedExtensions;

  @override
  Future<GpxSelectedFile?> pickFile({
    required FileType type,
    List<String>? allowedExtensions,
  }) async {
    lastType = type;
    lastAllowedExtensions = allowedExtensions;
    return selection;
  }
}

class FakeGpxParserService implements GpxParserService {
  FakeGpxParserService(this.points);

  final List<GpxPoint> points;

  @override
  Future<List<GpxPoint>> parse(Uint8List bytes) async {
    return points;
  }
}

class FakeLocationHistoryRepository implements LocationHistoryRepository {
  List<LatLngSample> addedSamples = <LatLngSample>[];

  @override
  Stream<List<LatLngSample>> get historyStream =>
      const Stream<List<LatLngSample>>.empty();

  @override
  List<LatLngSample> get currentSamples => const [];

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<List<LatLngSample>> addImportedSamples(
    List<LatLngSample> samples,
  ) async {
    addedSamples = samples;
    return samples;
  }
}

class FakeVisitedGridRepository implements VisitedGridRepository {
  List<LatLngSample> ingested = <LatLngSample>[];

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> ingestSamples(Iterable<LatLngSample> samples) async {
    ingested = List<LatLngSample>.from(samples);
  }

  @override
  Future<VisitedGridOverlay> loadOverlay({
    required VisitedGridBounds bounds,
    required double zoom,
    required VisitedTimeFilter timeFilter,
  }) async {
    return const VisitedGridOverlay(
      resolution: 0,
      polygons: <VisitedOverlayPolygon>[],
    );
  }
}

void main() {
  test('prepareImport fails when permission is denied', () async {
    final repository = DefaultGpxImportRepository(
      fileAccessPermissionService: FakeFileAccessPermissionService(
        granted: false,
        requestResult: false,
      ),
      filePickerService: FakeGpxFilePickerService(null),
      parserService: FakeGpxParserService(const []),
      locationHistoryRepository: FakeLocationHistoryRepository(),
      visitedGridRepository: FakeVisitedGridRepository(),
      config: const LocationTrackingConfig(),
    );

    final preparation = await repository.prepareImport();

    expect(preparation.outcome, GpxImportOutcome.failure);
    expect(preparation.messageKey, 'gpx_import_permission_denied');
  });

  test('prepareImport rejects non-gpx file extensions', () async {
    final repository = DefaultGpxImportRepository(
      fileAccessPermissionService: FakeFileAccessPermissionService(
        granted: true,
        requestResult: true,
      ),
      filePickerService: FakeGpxFilePickerService(
        GpxSelectedFile(
          name: 'track.txt',
          bytes: Uint8List.fromList([1, 2]),
        ),
      ),
      parserService: FakeGpxParserService(const []),
      locationHistoryRepository: FakeLocationHistoryRepository(),
      visitedGridRepository: FakeVisitedGridRepository(),
      config: const LocationTrackingConfig(),
    );

    final preparation = await repository.prepareImport();

    expect(preparation.outcome, GpxImportOutcome.failure);
    expect(preparation.messageKey, 'gpx_import_invalid_extension');
  });

  test('processFile parses points and fills gaps', () async {
    final historyRepository = FakeLocationHistoryRepository();
    final visitedGridRepository = FakeVisitedGridRepository();
    final repository = DefaultGpxImportRepository(
      fileAccessPermissionService: FakeFileAccessPermissionService(
        granted: true,
        requestResult: true,
      ),
      filePickerService: FakeGpxFilePickerService(null),
      parserService: FakeGpxParserService(
        [
          GpxPoint(
            latitude: 42.0,
            longitude: 23.0,
            timestamp: DateTime.utc(2024, 1, 1, 0, 0, 0),
          ),
          GpxPoint(
            latitude: 42.0001,
            longitude: 23.0001,
            timestamp: DateTime.utc(2024, 1, 1, 0, 0, 30),
          ),
        ],
      ),
      locationHistoryRepository: historyRepository,
      visitedGridRepository: visitedGridRepository,
      config: const LocationTrackingConfig(gapFillIntervalSeconds: 15),
    );

    final result = await repository.processFile(
      GpxSelectedFile(
        name: 'track.gpx',
        bytes: Uint8List.fromList([1, 2]),
      ),
    );

    expect(result.outcome, GpxImportOutcome.success);
    expect(historyRepository.addedSamples.length, 3);
    expect(
      historyRepository.addedSamples.any((sample) => sample.isInterpolated),
      isTrue,
    );
    expect(visitedGridRepository.ingested.length, 3);
    expect(
      historyRepository.addedSamples
          .every((sample) => sample.source == LatLngSampleSource.imported),
      isTrue,
    );
  });
}
