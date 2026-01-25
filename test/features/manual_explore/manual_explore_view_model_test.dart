import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:explored/features/manual_explore/data/models/manual_explore_delete_summary.dart';
import 'package:explored/features/manual_explore/data/models/manual_explore_mode.dart';
import 'package:explored/features/manual_explore/data/repositories/manual_explore_repository.dart';
import 'package:explored/features/manual_explore/view_model/manual_explore_view_model.dart';
import 'package:explored/features/map/data/models/map_tile_source.dart';
import 'package:explored/features/map/data/repositories/map_repository.dart';
import 'package:explored/features/map/data/services/map_attribution_service.dart';
import 'package:explored/features/map/data/services/map_overlay_settings_service.dart';
import 'package:explored/features/map/data/services/map_tile_service.dart';
import 'package:explored/features/visited_grid/view_model/fog_of_war_overlay_controller.dart';

class FakeManualExploreRepository implements ManualExploreRepository {
  Set<String> lastAddCells = <String>{};
  Set<String> lastDeleteCells = <String>{};

  @override
  String cellIdForLatLng(LatLng location) {
    return '${location.latitude.toStringAsFixed(3)},'
        '${location.longitude.toStringAsFixed(3)}';
  }

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
    return ManualExploreDeleteSummary(
      cellCount: deleteCellIds.length,
      sampleCount: deleteCellIds.length * 2,
    );
  }

  @override
  Future<ManualExploreSaveResult> applyEdits({
    required Set<String> addCellIds,
    required Set<String> deleteCellIds,
    required DateTime timestampUtc,
  }) async {
    lastAddCells = Set<String>.from(addCellIds);
    lastDeleteCells = Set<String>.from(deleteCellIds);
    return ManualExploreSaveResult(
      addedCells: addCellIds.length,
      deletedCells: deleteCellIds.length,
      deletedSamples: deleteCellIds.length * 2,
    );
  }
}

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
  @override
  Future<void> openAttribution() async {}
}

class FakeOverlaySettingsService implements MapOverlaySettingsService {
  @override
  Future<int?> loadTileSize() async => 256;

  @override
  Future<void> saveTileSize(int size) async {}
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

ManualExploreViewModel _buildViewModel(FakeManualExploreRepository repo) {
  final mapRepository = MapRepository(
    tileService: FakeMapTileService(),
    attributionService: FakeMapAttributionService(),
    overlaySettingsService: FakeOverlaySettingsService(),
  );
  final overlayController = FakeFogOfWarOverlayController();
  return ManualExploreViewModel(
    repository: repo,
    mapRepository: mapRepository,
    overlayController: overlayController,
    nowProvider: () => DateTime(2024, 1, 1, 12),
  );
}

void _tapCell(ManualExploreViewModel viewModel, LatLng point) {
  viewModel.beginPaintStroke();
  viewModel.addPaintSample(point);
  viewModel.endPaintStroke();
}

void main() {
  test('add then delete keeps only delete staged', () async {
    final repo = FakeManualExploreRepository();
    final viewModel = _buildViewModel(repo);
    await viewModel.initialize();

    final point = const LatLng(1, 1);
    viewModel.setMode(ManualExploreMode.add);
    _tapCell(viewModel, point);
    viewModel.setMode(ManualExploreMode.delete);
    _tapCell(viewModel, point);

    expect(viewModel.state.stagedAddCount, 0);
    expect(viewModel.state.stagedDeleteCount, 1);
  });

  test('delete then add keeps only add staged', () async {
    final repo = FakeManualExploreRepository();
    final viewModel = _buildViewModel(repo);
    await viewModel.initialize();

    final point = const LatLng(2, 2);
    viewModel.setMode(ManualExploreMode.delete);
    _tapCell(viewModel, point);
    viewModel.setMode(ManualExploreMode.add);
    _tapCell(viewModel, point);

    expect(viewModel.state.stagedAddCount, 1);
    expect(viewModel.state.stagedDeleteCount, 0);
  });

  test('undo/redo restores staged sets', () async {
    final repo = FakeManualExploreRepository();
    final viewModel = _buildViewModel(repo);
    await viewModel.initialize();

    final point = const LatLng(3, 3);
    viewModel.setMode(ManualExploreMode.add);
    _tapCell(viewModel, point);
    viewModel.setMode(ManualExploreMode.delete);
    _tapCell(viewModel, point);

    expect(viewModel.state.stagedDeleteCount, 1);
    viewModel.undo();
    expect(viewModel.state.stagedAddCount, 1);
    expect(viewModel.state.stagedDeleteCount, 0);
    viewModel.redo();
    expect(viewModel.state.stagedAddCount, 0);
    expect(viewModel.state.stagedDeleteCount, 1);
  });

  test('paint dedups within stroke', () async {
    final repo = FakeManualExploreRepository();
    final viewModel = _buildViewModel(repo);
    await viewModel.initialize();

    viewModel.setMode(ManualExploreMode.add);
    viewModel.beginPaintStroke();
    viewModel.addPaintSample(const LatLng(1, 1));
    viewModel.addPaintSample(const LatLng(1, 1));
    viewModel.endPaintStroke();

    expect(viewModel.state.stagedAddCount, 1);

    await viewModel.saveEdits();
    expect(repo.lastAddCells.length, 1);
  });

  test('save uses resolved staged sets', () async {
    final repo = FakeManualExploreRepository();
    final viewModel = _buildViewModel(repo);
    await viewModel.initialize();

    final point = const LatLng(4, 4);
    viewModel.setMode(ManualExploreMode.add);
    _tapCell(viewModel, point);
    viewModel.setMode(ManualExploreMode.delete);
    _tapCell(viewModel, point);

    final success = await viewModel.saveEdits();
    expect(success, isTrue);
    expect(repo.lastAddCells, isEmpty);
    expect(repo.lastDeleteCells.length, 1);
  });
}
