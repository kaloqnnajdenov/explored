import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:explored/domain/usecases/h3_overlay_worker.dart';
import 'package:explored/features/location/data/models/lat_lng_sample.dart';
import 'package:explored/features/location/data/models/history_export_result.dart';
import 'package:explored/features/location/data/models/location_permission_level.dart';
import 'package:explored/features/location/data/models/location_status.dart';
import 'package:explored/features/location/data/models/location_tracking_mode.dart';
import 'package:explored/features/location/data/repositories/location_history_repository.dart';
import 'package:explored/features/location/data/repositories/location_updates_repository.dart';
import 'package:explored/features/map/data/models/map_tile_source.dart';
import 'package:explored/features/map/data/repositories/map_repository.dart';
import 'package:explored/features/map/data/services/map_attribution_service.dart';
import 'package:explored/features/map/data/services/map_tile_service.dart';
import 'package:explored/features/map/view_model/map_view_model.dart';
import 'package:explored/features/permissions/data/models/app_permission.dart';
import 'package:explored/features/permissions/data/repositories/permissions_repository.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_bounds.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_overlay.dart';
import 'package:explored/features/visited_grid/data/models/visited_overlay_mode.dart';
import 'package:explored/features/visited_grid/data/models/visited_overlay_polygon.dart';
import 'package:explored/features/visited_grid/data/models/visited_overlay_render_mode.dart';
import 'package:explored/features/visited_grid/data/models/visited_time_filter.dart';
import 'package:explored/features/visited_grid/data/repositories/visited_grid_repository.dart';

class FakeMapTileService implements MapTileService {
  @override
  MapTileSource getTileSource() {
    return const MapTileSource(
      urlTemplate: 'https://example.com/{z}/{x}/{y}.png',
      subdomains: ['a'],
      userAgentPackageName: 'com.explored.test',
    );
  }
}

class FakeMapAttributionService implements MapAttributionService {
  bool opened = false;

  @override
  Future<void> openAttribution() async {
    opened = true;
  }
}

class FakeLocationUpdatesRepository implements LocationUpdatesRepository {
  FakeLocationUpdatesRepository({
    this.permissionLevel = LocationPermissionLevel.foreground,
    this.serviceEnabled = true,
    this.notificationRequired = false,
    this.notificationGranted = true,
    this.requiresBackgroundPermissionFlag = false,
  });

  final StreamController<LatLngSample> _controller =
      StreamController<LatLngSample>.broadcast();
  bool _isRunning = false;
  LocationPermissionLevel permissionLevel;
  bool serviceEnabled;
  bool notificationRequired;
  bool notificationGranted;
  bool requiresBackgroundPermissionFlag;
  int startTrackingCalls = 0;
  int requestForegroundCalls = 0;
  int openAppSettingsCalls = 0;
  int openNotificationSettingsCalls = 0;

  @override
  Stream<LatLngSample> get locationUpdates => _controller.stream;

  @override
  bool get isRunning => _isRunning;

  @override
  Future<void> startTracking() async {
    _isRunning = true;
    startTrackingCalls += 1;
  }

  @override
  Future<void> stopTracking() async {
    _isRunning = false;
  }

  @override
  Future<void> refreshPermissions() async {}

  @override
  Future<LocationPermissionLevel> checkPermissionLevel() async {
    return permissionLevel;
  }

  @override
  Future<LocationPermissionLevel> requestForegroundPermission() async {
    requestForegroundCalls += 1;
    return permissionLevel;
  }

  @override
  Future<LocationPermissionLevel> requestBackgroundPermission() async {
    return permissionLevel;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return serviceEnabled;
  }

  @override
  Future<bool> isNotificationPermissionGranted() async {
    return notificationGranted;
  }

  @override
  Future<bool> requestNotificationPermission() async {
    return notificationGranted;
  }

  @override
  bool get isNotificationPermissionRequired => notificationRequired;

  @override
  Future<bool> openAppSettings() async {
    openAppSettingsCalls += 1;
    return true;
  }

  @override
  Future<bool> openNotificationSettings() async {
    openNotificationSettingsCalls += 1;
    return true;
  }

  @override
  bool get requiresBackgroundPermission => requiresBackgroundPermissionFlag;

  void emit(LatLngSample sample) {
    _controller.add(sample);
  }
}

class FakeVisitedGridRepository implements VisitedGridRepository {
  int startCalls = 0;

  @override
  Future<void> start() async {
    startCalls += 1;
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> ingestSamples(Iterable<LatLngSample> samples) async {}

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

class FakeLocationHistoryRepository implements LocationHistoryRepository {
  final StreamController<List<LatLngSample>> _controller =
      StreamController<List<LatLngSample>>.broadcast();
  final List<LatLngSample> _samples = <LatLngSample>[];
  int startCalls = 0;
  int exportCalls = 0;
  int downloadCalls = 0;
  HistoryExportResult exportResult =
      const HistoryExportResult.success(filePath: 'export.csv');
  HistoryExportResult downloadResult =
      const HistoryExportResult.success(filePath: 'download.csv');

  @override
  Stream<List<LatLngSample>> get historyStream => _controller.stream;

  @override
  List<LatLngSample> get currentSamples => List.unmodifiable(_samples);

  @override
  Future<void> start() async {
    startCalls += 1;
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<List<LatLngSample>> addImportedSamples(
    List<LatLngSample> samples,
  ) async {
    _samples.addAll(samples);
    _controller.add(List.unmodifiable(_samples));
    return samples;
  }

  @override
  Future<HistoryExportResult> exportHistory() async {
    exportCalls += 1;
    return exportResult;
  }

  @override
  Future<HistoryExportResult> downloadHistory() async {
    downloadCalls += 1;
    return downloadResult;
  }
}

class FakePermissionsRepository implements PermissionsRepository {
  int requestInitialCalls = 0;

  @override
  Future<List<AppPermissionStatus>> fetchPermissions() async {
    return const [];
  }

  @override
  Future<void> requestInitialPermissionsIfNeeded() async {
    requestInitialCalls += 1;
  }

  @override
  Future<void> requestPermission(AppPermissionType type) async {}
}

class FakeVisitedOverlayWorker implements VisitedOverlayWorker {
  @override
  Future<H3OverlayResult> queryOverlay({
    required int requestId,
    required VisitedGridBounds bounds,
    required double zoom,
    required OverlayMode mode,
  }) async {
    return H3OverlayResult(
      requestId: requestId,
      resolution: 0,
      visitedCellIds: <String>{},
      renderMode: VisitedOverlayRenderMode.perCell,
      mergedPolygons: const [],
    );
  }

  @override
  Future<void> dispose() async {}
}

List<LatLng> fakeBoundaryResolver(String cellId) => const [];

void main() {
  test('Location updates update the map state', () async {
    final locationRepository = FakeLocationUpdatesRepository();
    final mapRepository = MapRepository(
      tileService: FakeMapTileService(),
      attributionService: FakeMapAttributionService(),
    );
    final viewModel = MapViewModel(
      mapRepository: mapRepository,
      locationUpdatesRepository: locationRepository,
      locationHistoryRepository: FakeLocationHistoryRepository(),
      permissionsRepository: FakePermissionsRepository(),
      visitedGridRepository: FakeVisitedGridRepository(),
      overlayWorker: FakeVisitedOverlayWorker(),
      boundaryResolver: fakeBoundaryResolver,
    );

    await viewModel.initialize();

    final sample = LatLngSample(
      latitude: 42.12345,
      longitude: 23.54321,
      timestamp: DateTime(2024, 1, 1),
    );
    locationRepository.emit(sample);
    await Future<void>.delayed(Duration.zero);

    final lastLocation = viewModel.state.locationTracking.lastLocation;
    expect(lastLocation, isNotNull);
    expect(lastLocation!.latitude, 42.12345);
    expect(lastLocation.longitude, 23.54321);
    expect(
      viewModel.state.locationTracking.trackingMode,
      LocationTrackingMode.background,
    );
    expect(
      viewModel.state.locationTracking.status,
      LocationStatus.trackingStartedBackground,
    );

    viewModel.dispose();
  });

  test('Location panel visibility toggles via ViewModel', () {
    final locationRepository = FakeLocationUpdatesRepository();
    final mapRepository = MapRepository(
      tileService: FakeMapTileService(),
      attributionService: FakeMapAttributionService(),
    );
    final viewModel = MapViewModel(
      mapRepository: mapRepository,
      locationUpdatesRepository: locationRepository,
      locationHistoryRepository: FakeLocationHistoryRepository(),
      permissionsRepository: FakePermissionsRepository(),
      visitedGridRepository: FakeVisitedGridRepository(),
      overlayWorker: FakeVisitedOverlayWorker(),
      boundaryResolver: fakeBoundaryResolver,
    );

    expect(viewModel.state.isLocationPanelVisible, isTrue);

    viewModel.setLocationPanelVisibility(false);
    expect(viewModel.state.isLocationPanelVisible, isFalse);

    viewModel.toggleLocationPanelVisibility();
    expect(viewModel.state.isLocationPanelVisible, isTrue);

    viewModel.dispose();
  });

  test('Recenter zoom can be updated via ViewModel', () {
    final locationRepository = FakeLocationUpdatesRepository();
    final mapRepository = MapRepository(
      tileService: FakeMapTileService(),
      attributionService: FakeMapAttributionService(),
    );
    final viewModel = MapViewModel(
      mapRepository: mapRepository,
      locationUpdatesRepository: locationRepository,
      locationHistoryRepository: FakeLocationHistoryRepository(),
      permissionsRepository: FakePermissionsRepository(),
      visitedGridRepository: FakeVisitedGridRepository(),
      overlayWorker: FakeVisitedOverlayWorker(),
      boundaryResolver: fakeBoundaryResolver,
    );

    final initialZoom = viewModel.state.recenterZoom;
    viewModel.setRecenterZoom(initialZoom + 1);
    expect(viewModel.state.recenterZoom, initialZoom + 1);

    viewModel.dispose();
  });

  test('Initialize sets permission denied status when missing', () async {
    final locationRepository = FakeLocationUpdatesRepository(
      permissionLevel: LocationPermissionLevel.denied,
    );
    final mapRepository = MapRepository(
      tileService: FakeMapTileService(),
      attributionService: FakeMapAttributionService(),
    );
    final viewModel = MapViewModel(
      mapRepository: mapRepository,
      locationUpdatesRepository: locationRepository,
      locationHistoryRepository: FakeLocationHistoryRepository(),
      permissionsRepository: FakePermissionsRepository(),
      visitedGridRepository: FakeVisitedGridRepository(),
      overlayWorker: FakeVisitedOverlayWorker(),
      boundaryResolver: fakeBoundaryResolver,
    );

    await viewModel.initialize();

    expect(
      viewModel.state.locationTracking.status,
      LocationStatus.permissionDenied,
    );

    viewModel.dispose();
  });

  test('Initialize flags notification permission when required', () async {
    final locationRepository = FakeLocationUpdatesRepository(
      permissionLevel: LocationPermissionLevel.background,
      notificationRequired: true,
      notificationGranted: false,
    );
    final mapRepository = MapRepository(
      tileService: FakeMapTileService(),
      attributionService: FakeMapAttributionService(),
    );
    final viewModel = MapViewModel(
      mapRepository: mapRepository,
      locationUpdatesRepository: locationRepository,
      locationHistoryRepository: FakeLocationHistoryRepository(),
      permissionsRepository: FakePermissionsRepository(),
      visitedGridRepository: FakeVisitedGridRepository(),
      overlayWorker: FakeVisitedOverlayWorker(),
      boundaryResolver: fakeBoundaryResolver,
    );

    await viewModel.initialize();

    expect(
      viewModel.state.locationTracking.status,
      LocationStatus.notificationPermissionDenied,
    );
    expect(
      viewModel.state.locationTracking.isNotificationPermissionGranted,
      isFalse,
    );

    viewModel.dispose();
  });

  test('Requesting foreground permission triggers tracking restart', () async {
    final locationRepository = FakeLocationUpdatesRepository(
      permissionLevel: LocationPermissionLevel.denied,
    );
    final mapRepository = MapRepository(
      tileService: FakeMapTileService(),
      attributionService: FakeMapAttributionService(),
    );
    final viewModel = MapViewModel(
      mapRepository: mapRepository,
      locationUpdatesRepository: locationRepository,
      locationHistoryRepository: FakeLocationHistoryRepository(),
      permissionsRepository: FakePermissionsRepository(),
      visitedGridRepository: FakeVisitedGridRepository(),
      overlayWorker: FakeVisitedOverlayWorker(),
      boundaryResolver: fakeBoundaryResolver,
    );

    await viewModel.initialize();
    await viewModel.requestForegroundPermission();

    expect(locationRepository.requestForegroundCalls, 1);
    expect(locationRepository.startTrackingCalls, 2);
    expect(
      viewModel.state.locationTracking.status,
      LocationStatus.permissionDenied,
    );

    viewModel.dispose();
  });

  test(
      'Open settings routes to notification settings when notifications blocked',
      () async {
    final locationRepository = FakeLocationUpdatesRepository(
      permissionLevel: LocationPermissionLevel.background,
      notificationRequired: true,
      notificationGranted: false,
    );
    final mapRepository = MapRepository(
      tileService: FakeMapTileService(),
      attributionService: FakeMapAttributionService(),
    );
    final viewModel = MapViewModel(
      mapRepository: mapRepository,
      locationUpdatesRepository: locationRepository,
      locationHistoryRepository: FakeLocationHistoryRepository(),
      permissionsRepository: FakePermissionsRepository(),
      visitedGridRepository: FakeVisitedGridRepository(),
      overlayWorker: FakeVisitedOverlayWorker(),
      boundaryResolver: fakeBoundaryResolver,
    );

    await viewModel.initialize();
    await viewModel.openAppSettings();

    expect(locationRepository.openNotificationSettingsCalls, 1);
    expect(locationRepository.openAppSettingsCalls, 0);

    viewModel.dispose();
  });

  test('exportHistory emits success feedback', () async {
    final locationRepository = FakeLocationUpdatesRepository();
    final mapRepository = MapRepository(
      tileService: FakeMapTileService(),
      attributionService: FakeMapAttributionService(),
    );
    final historyRepository = FakeLocationHistoryRepository()
      ..exportResult =
          const HistoryExportResult.success(filePath: 'export.csv');
    final viewModel = MapViewModel(
      mapRepository: mapRepository,
      locationUpdatesRepository: locationRepository,
      locationHistoryRepository: historyRepository,
      permissionsRepository: FakePermissionsRepository(),
      visitedGridRepository: FakeVisitedGridRepository(),
      overlayWorker: FakeVisitedOverlayWorker(),
      boundaryResolver: fakeBoundaryResolver,
    );

    await viewModel.exportHistory();

    expect(historyRepository.exportCalls, 1);
    expect(viewModel.state.exportFeedback?.messageKey, 'export_ready');
    expect(viewModel.state.exportFeedback?.isError, isFalse);

    viewModel.dispose();
  });

  test('exportHistory emits failure feedback', () async {
    final locationRepository = FakeLocationUpdatesRepository();
    final mapRepository = MapRepository(
      tileService: FakeMapTileService(),
      attributionService: FakeMapAttributionService(),
    );
    final historyRepository = FakeLocationHistoryRepository()
      ..exportResult = const HistoryExportResult.failure(error: 'boom');
    final viewModel = MapViewModel(
      mapRepository: mapRepository,
      locationUpdatesRepository: locationRepository,
      locationHistoryRepository: historyRepository,
      permissionsRepository: FakePermissionsRepository(),
      visitedGridRepository: FakeVisitedGridRepository(),
      overlayWorker: FakeVisitedOverlayWorker(),
      boundaryResolver: fakeBoundaryResolver,
    );

    await viewModel.exportHistory();

    expect(historyRepository.exportCalls, 1);
    expect(viewModel.state.exportFeedback?.messageKey, 'export_failed');
    expect(viewModel.state.exportFeedback?.isError, isTrue);

    viewModel.dispose();
  });

  test('downloadHistory emits success feedback', () async {
    final locationRepository = FakeLocationUpdatesRepository();
    final mapRepository = MapRepository(
      tileService: FakeMapTileService(),
      attributionService: FakeMapAttributionService(),
    );
    final historyRepository = FakeLocationHistoryRepository()
      ..downloadResult =
          const HistoryExportResult.success(filePath: 'download.csv');
    final viewModel = MapViewModel(
      mapRepository: mapRepository,
      locationUpdatesRepository: locationRepository,
      locationHistoryRepository: historyRepository,
      permissionsRepository: FakePermissionsRepository(),
      visitedGridRepository: FakeVisitedGridRepository(),
      overlayWorker: FakeVisitedOverlayWorker(),
      boundaryResolver: fakeBoundaryResolver,
    );

    await viewModel.downloadHistory();

    expect(historyRepository.downloadCalls, 1);
    expect(viewModel.state.exportFeedback?.messageKey, 'download_ready');
    expect(viewModel.state.exportFeedback?.isError, isFalse);

    viewModel.dispose();
  });

  test('downloadHistory emits failure feedback', () async {
    final locationRepository = FakeLocationUpdatesRepository();
    final mapRepository = MapRepository(
      tileService: FakeMapTileService(),
      attributionService: FakeMapAttributionService(),
    );
    final historyRepository = FakeLocationHistoryRepository()
      ..downloadResult = const HistoryExportResult.failure(error: 'boom');
    final viewModel = MapViewModel(
      mapRepository: mapRepository,
      locationUpdatesRepository: locationRepository,
      locationHistoryRepository: historyRepository,
      permissionsRepository: FakePermissionsRepository(),
      visitedGridRepository: FakeVisitedGridRepository(),
      overlayWorker: FakeVisitedOverlayWorker(),
      boundaryResolver: fakeBoundaryResolver,
    );

    await viewModel.downloadHistory();

    expect(historyRepository.downloadCalls, 1);
    expect(viewModel.state.exportFeedback?.messageKey, 'download_failed');
    expect(viewModel.state.exportFeedback?.isError, isTrue);

    viewModel.dispose();
  });
}
