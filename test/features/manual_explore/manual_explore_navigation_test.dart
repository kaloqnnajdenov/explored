import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import 'package:explored/features/gpx_import/data/repositories/gpx_import_repository.dart';
import 'package:explored/features/gpx_import/data/services/gpx_file_picker_service.dart';
import 'package:explored/features/gpx_import/view_model/gpx_import_view_model.dart';
import 'package:explored/features/location/data/models/lat_lng_sample.dart';
import 'package:explored/features/location/data/models/history_export_result.dart';
import 'package:explored/features/location/data/models/location_permission_level.dart';
import 'package:explored/features/location/data/repositories/location_history_repository.dart';
import 'package:explored/features/location/data/repositories/location_updates_repository.dart';
import 'package:explored/features/map/data/models/map_tile_source.dart';
import 'package:explored/features/map/data/repositories/map_repository.dart';
import 'package:explored/features/map/data/services/map_attribution_service.dart';
import 'package:explored/features/map/data/services/map_overlay_settings_service.dart';
import 'package:explored/features/map/data/services/map_tile_service.dart';
import 'package:explored/features/map/view/map_view.dart';
import 'package:explored/features/map/view_model/map_view_model.dart';
import 'package:explored/features/manual_explore/data/models/manual_explore_delete_summary.dart';
import 'package:explored/features/manual_explore/data/repositories/manual_explore_repository.dart';
import 'package:explored/features/manual_explore/view/manual_explore_view.dart';
import 'package:explored/features/manual_explore/view_model/manual_explore_view_model.dart';
import 'package:explored/features/permissions/data/models/app_permission.dart';
import 'package:explored/features/permissions/data/repositories/permissions_repository.dart';
import 'package:explored/features/permissions/view_model/permissions_view_model.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_bounds.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_cell_update.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_overlay.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_stats.dart';
import 'package:explored/features/visited_grid/data/models/visited_overlay_polygon.dart';
import 'package:explored/features/visited_grid/data/models/visited_time_filter.dart';
import 'package:explored/features/visited_grid/data/repositories/visited_grid_repository.dart';
import 'package:explored/features/visited_grid/view_model/fog_of_war_overlay_controller.dart';

import '../../test_utils/localization_test_utils.dart';

class FakeMapTileService implements MapTileService {
  @override
  MapTileSource getTileSource() {
    return MapTileSource(
      urlTemplate: 'https://example.com/{z}/{x}/{y}.png',
      subdomains: ['a'],
      userAgentPackageName: 'com.explored.test',
      tileProvider: _EmptyTileProvider(),
    );
  }
}

class FakeMapAttributionService implements MapAttributionService {
  @override
  Future<void> openAttribution() async {}
}

class FakeOverlaySettingsService implements MapOverlaySettingsService {
  @override
  Future<int?> loadTileSize() async => 256;

  @override
  Future<void> saveTileSize(int size) async {}
}

class FakeLocationUpdatesRepository implements LocationUpdatesRepository {
  @override
  Stream<LatLngSample> get locationUpdates => const Stream.empty();

  @override
  bool get isRunning => false;

  @override
  Future<void> startTracking() async {}

  @override
  Future<void> stopTracking() async {}

  @override
  Future<void> refreshPermissions() async {}

  @override
  Future<LocationPermissionLevel> checkPermissionLevel() async {
    return LocationPermissionLevel.foreground;
  }

  @override
  Future<LocationPermissionLevel> requestForegroundPermission() async {
    return LocationPermissionLevel.foreground;
  }

  @override
  Future<LocationPermissionLevel> requestBackgroundPermission() async {
    return LocationPermissionLevel.background;
  }

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<bool> isNotificationPermissionGranted() async => true;

  @override
  Future<bool> requestNotificationPermission() async => true;

  @override
  bool get isNotificationPermissionRequired => false;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openNotificationSettings() async => true;

  @override
  bool get requiresBackgroundPermission => false;
}

class FakeLocationHistoryRepository implements LocationHistoryRepository {
  @override
  Stream<List<LatLngSample>> get historyStream => const Stream.empty();

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
    return samples;
  }

  @override
  Future<HistoryManualEditResult> applyManualEdits({
    required List<LatLngSample> insertSamples,
    required Set<String> deleteBaseCellIds,
  }) async {
    return HistoryManualEditResult(
      insertedSamples: insertSamples,
      deletedSamples: 0,
    );
  }

  @override
  Future<HistoryExportResult> exportHistory() async {
    return const HistoryExportResult.success(filePath: 'export.csv');
  }

  @override
  Future<HistoryExportResult> downloadHistory() async {
    return const HistoryExportResult.success(filePath: 'download.csv');
  }
}

class FakePermissionsRepository implements PermissionsRepository {
  @override
  Future<List<AppPermissionStatus>> fetchPermissions() async => const [];

  @override
  Future<void> requestPermission(AppPermissionType type) async {}

  @override
  Future<void> requestInitialPermissionsIfNeeded() async {}
}

class FakeVisitedGridRepository implements VisitedGridRepository {
  @override
  Stream<VisitedGridCellUpdate> get cellUpdates => const Stream.empty();

  @override
  Stream<VisitedGridStats> get statsUpdates => const Stream.empty();

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> ingestSamples(Iterable<LatLngSample> samples) async {}

  @override
  Future<void> rebuildFromHistory() async {}

  @override
  Future<VisitedGridStats> fetchStats() async {
    return const VisitedGridStats(
      totalAreaM2: 0,
      cellCount: 0,
      canonicalVersion: 0,
    );
  }

  @override
  Future<double> fetchExploredAreaKm2({
    DateTime? start,
    DateTime? end,
  }) async =>
      0;

  @override
  Future<void> logExploredAreaViewed() async {}

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

class FakeFogOfWarOverlayController implements FogOfWarOverlayController {
  FakeFogOfWarOverlayController();

  final StreamController<void> _resetController =
      StreamController<void>.broadcast();
  int _tileSize = 256;

  @override
  TileProvider get tileProvider => _EmptyTileProvider();

  @override
  Stream<void> get resetStream => _resetController.stream;

  @override
  int get tileSize => _tileSize;

  @override
  Future<void> setTileSize(int tileSize) async {
    _tileSize = tileSize;
  }

  @override
  Future<void> dispose() async {
    await _resetController.close();
  }
}

class _EmptyTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MemoryImage(_transparentImage);
  }
}

final Uint8List _transparentImage = Uint8List.fromList(
  <int>[
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
  ],
);

class FakeManualExploreRepository implements ManualExploreRepository {
  @override
  String cellIdForLatLng(LatLng location) => 'cell';

  @override
  bool isCellExplored(String cellId) => true;

  @override
  LatLng cellCenter(String cellId) => const LatLng(0, 0);

  @override
  List<LatLng> cellBoundary({
    required String cellId,
    required double zoom,
  }) =>
      const [
        LatLng(0, 0),
        LatLng(0, 1),
        LatLng(1, 1),
        LatLng(1, 0),
      ];

  @override
  Future<ManualExploreDeleteSummary> fetchDeleteSummary(
    Set<String> deleteCellIds,
  ) async {
    return const ManualExploreDeleteSummary(cellCount: 0, sampleCount: 0);
  }

  @override
  Future<ManualExploreSaveResult> applyEdits({
    required Set<String> addCellIds,
    required Set<String> deleteCellIds,
    required DateTime timestampUtc,
  }) async {
    return ManualExploreSaveResult(
      addedCells: addCellIds.length,
      deletedCells: deleteCellIds.length,
      deletedSamples: 0,
    );
  }
}

class FakeGpxImportRepository implements GpxImportRepository {
  @override
  Future<GpxImportPreparation> prepareImport() async {
    return const GpxImportPreparation(outcome: GpxImportOutcome.cancelled);
  }

  @override
  Future<GpxImportResult> processFile(GpxSelectedFile file) async {
    return const GpxImportResult(outcome: GpxImportOutcome.failure);
  }
}

void main() {
  testWidgets('opens manual explore screen from menu', (tester) async {
    await loadTestTranslations();

    final mapRepository = MapRepository(
      tileService: FakeMapTileService(),
      attributionService: FakeMapAttributionService(),
      overlaySettingsService: FakeOverlaySettingsService(),
    );
    final overlayController = FakeFogOfWarOverlayController();
    final mapViewModel = MapViewModel(
      mapRepository: mapRepository,
      locationUpdatesRepository: FakeLocationUpdatesRepository(),
      locationHistoryRepository: FakeLocationHistoryRepository(),
      permissionsRepository: FakePermissionsRepository(),
      visitedGridRepository: FakeVisitedGridRepository(),
      overlayController: overlayController,
    );
    final permissionsViewModel =
        PermissionsViewModel(repository: FakePermissionsRepository());
    final gpxImportViewModel =
        GpxImportViewModel(repository: FakeGpxImportRepository());
    final manualExploreViewModel = ManualExploreViewModel(
      repository: FakeManualExploreRepository(),
      mapRepository: mapRepository,
      overlayController: overlayController,
    );

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => MapView(
            viewModel: mapViewModel,
            permissionsViewModel: permissionsViewModel,
            gpxImportViewModel: gpxImportViewModel,
          ),
        ),
        GoRoute(
          path: '/manual-explore',
          builder: (_, __) => ManualExploreView(
            viewModel: manualExploreViewModel,
          ),
        ),
      ],
    );

    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Manual explore'));
    await tester.pumpAndSettle();

    expect(find.byType(ManualExploreView), findsOneWidget);
  });
}
