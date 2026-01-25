import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:explored/features/manual_explore/data/models/manual_explore_delete_summary.dart';
import 'package:explored/features/manual_explore/data/models/manual_explore_mode.dart';
import 'package:explored/features/manual_explore/data/repositories/manual_explore_repository.dart';
import 'package:explored/features/manual_explore/view/manual_explore_view.dart';
import 'package:explored/features/manual_explore/view_model/manual_explore_view_model.dart';
import 'package:explored/features/map/data/models/map_tile_source.dart';
import 'package:explored/features/map/data/repositories/map_repository.dart';
import 'package:explored/features/map/data/services/map_attribution_service.dart';
import 'package:explored/features/map/data/services/map_overlay_settings_service.dart';
import 'package:explored/features/map/data/services/map_tile_service.dart';
import 'package:explored/features/visited_grid/view_model/fog_of_war_overlay_controller.dart';

import '../../test_utils/localization_test_utils.dart';

class FakeManualExploreRepository implements ManualExploreRepository {
  ManualExploreDeleteSummary summary =
      const ManualExploreDeleteSummary(cellCount: 0, sampleCount: 0);
  int applyCalls = 0;

  @override
  String cellIdForLatLng(LatLng location) {
    return '${location.latitude.toStringAsFixed(3)}_'
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
    return summary;
  }

  @override
  Future<ManualExploreSaveResult> applyEdits({
    required Set<String> addCellIds,
    required Set<String> deleteCellIds,
    required DateTime timestampUtc,
  }) async {
    applyCalls += 1;
    return ManualExploreSaveResult(
      addedCells: addCellIds.length,
      deletedCells: deleteCellIds.length,
      deletedSamples: deleteCellIds.length,
    );
  }
}

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

Future<void> _pumpView(
  WidgetTester tester,
  ManualExploreViewModel viewModel,
) async {
  final app = await buildLocalizedTestApp(
    ManualExploreView(viewModel: viewModel),
  );
  tester.view.physicalSize = const Size(390, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(app);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  testWidgets('save disabled when no changes and text fits', (tester) async {
    final repo = FakeManualExploreRepository();
    final viewModel = _buildViewModel(repo);
    await _pumpView(tester, viewModel);

    final saveButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save'),
    );
    expect(saveButton.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('discard confirmation respects user choice', (tester) async {
    final repo = FakeManualExploreRepository();
    final viewModel = _buildViewModel(repo);
    await _pumpView(tester, viewModel);

    viewModel.setMode(ManualExploreMode.add);
    _tapCell(viewModel, const LatLng(0, 0));
    await tester.pump();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Discard'));
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(viewModel.state.hasChanges, isTrue);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Discard'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Discard'));
    await tester.pumpAndSettle();

    expect(viewModel.state.hasChanges, isFalse);
  });

  testWidgets('delete confirmation shows correct counts', (tester) async {
    final repo = FakeManualExploreRepository();
    repo.summary =
        const ManualExploreDeleteSummary(cellCount: 2, sampleCount: 5);
    final viewModel = _buildViewModel(repo);
    await _pumpView(tester, viewModel);

    viewModel.setMode(ManualExploreMode.delete);
    _tapCell(viewModel, const LatLng(0, 0));
    await tester.pump();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.text('Delete 2 cells and 5 points?'),
      findsOneWidget,
    );
  });

  testWidgets('gestures do not conflict between two-finger navigation and edit',
      (tester) async {
    final repo = FakeManualExploreRepository();
    final viewModel = _buildViewModel(repo);
    await _pumpView(tester, viewModel);

    final mapFinder = find.byType(FlutterMap);
    final center = tester.getCenter(mapFinder);

    viewModel.setMode(ManualExploreMode.add);
    await tester.pump();

    final g1 = await tester.startGesture(center, pointer: 1);
    final g2 = await tester.startGesture(center + const Offset(30, 0),
        pointer: 2);
    await g1.moveBy(const Offset(10, 0));
    await g2.moveBy(const Offset(10, 0));
    await g1.up();
    await g2.up();
    await tester.pump();

    expect(viewModel.state.hasChanges, isFalse);

    final g3 = await tester.startGesture(center, pointer: 3);
    await g3.moveBy(const Offset(15, 0));
    await g3.up();
    await tester.pump();

    expect(viewModel.state.hasChanges, isTrue);
  });
}
