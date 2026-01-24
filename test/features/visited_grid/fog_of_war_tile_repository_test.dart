import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:explored/features/visited_grid/data/models/fog_of_war_config.dart';
import 'package:explored/features/visited_grid/data/models/fog_of_war_style.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_cell.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_config.dart';
import 'package:explored/features/visited_grid/data/repositories/fog_of_war_tile_repository.dart';
import 'package:explored/features/visited_grid/data/services/fog_of_war_tile_cache_service.dart';
import 'package:explored/features/visited_grid/data/services/fog_of_war_tile_raster_service.dart';

import 'visited_grid_test_utils.dart';

class FakeRasterService extends FogOfWarTileRasterService {
  int calls = 0;
  final List<FogOfWarStyle> styles = [];

  @override
  Future<Uint8List> rasterizeTile({
    required List<List<ui.Offset>> polygons,
    required int tileSize,
    required FogOfWarStyle style,
  }) async {
    calls += 1;
    styles.add(style);
    return Uint8List.fromList([calls]);
  }
}

class FakeTileCachePathProvider implements TileCachePathProvider {
  FakeTileCachePathProvider(this.directory);

  final Directory directory;

  @override
  Future<Directory> getTemporaryDirectory() async => directory;
}

class _TileCoord {
  const _TileCoord(this.x, this.y);

  final int x;
  final int y;
}

_TileCoord _tileForLatLng({
  required double latitude,
  required double longitude,
  required int zoom,
  required int tileSize,
}) {
  final scale = 256.0 * math.pow(2, zoom).toDouble();
  final siny = math.sin(latitude * math.pi / 180.0).clamp(-0.9999, 0.9999);
  final x = (longitude + 180.0) / 360.0 * scale;
  final y = (0.5 - math.log((1 + siny) / (1 - siny)) / (4 * math.pi)) *
      scale;
  final tileX = (x / tileSize).floor();
  final tileY = (y / tileSize).floor();
  final tilesAtZoom = 1 << zoom;
  return _TileCoord(
    tileX % tilesAtZoom,
    tileY.clamp(0, tilesAtZoom - 1),
  );
}

void main() {
  test('Tiles are cached until invalidated', () async {
    final db = buildTestDb();
    final directory = Directory.systemTemp.createTempSync(
      'fog_of_war_repo_test',
    );
    addTearDown(() async {
      await db.close();
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    final h3 = FakeVisitedGridH3Service();
    final cell = h3.fakeCell(latitude: 0, longitude: 0, resolution: 3);
    h3.setBoundary(
      cell,
      const [
        LatLng(-0.001, -0.001),
        LatLng(-0.001, 0.001),
        LatLng(0.001, 0.001),
        LatLng(0.001, -0.001),
      ],
    );

    final rasterService = FakeRasterService();
    final cacheService = FogOfWarTileCacheService(
      pathProvider: FakeTileCachePathProvider(directory),
      maxEntries: 5,
    );
    const config = FogOfWarConfig(minZoom: 6, maxZoom: 6);
    final repository = FogOfWarTileRepository(
      visitedGridDao: db.visitedGridDao,
      h3Service: h3,
      rasterService: rasterService,
      cacheService: cacheService,
      visitedGridConfig: const VisitedGridConfig(
        baseResolution: 3,
        minRenderResolution: 3,
      ),
      config: config,
    );

    final tile = _tileForLatLng(
      latitude: 0,
      longitude: 0,
      zoom: 6,
      tileSize: repository.tileSize,
    );

    final first = await repository.loadTile(
      x: tile.x,
      y: tile.y,
      z: 6,
    );
    final second = await repository.loadTile(
      x: tile.x,
      y: tile.y,
      z: 6,
    );

    expect(rasterService.calls, 1);
    expect(first, second);

    repository.invalidateForCell(cell.toString());

    final third = await repository.loadTile(
      x: tile.x,
      y: tile.y,
      z: 6,
    );

    expect(rasterService.calls, 2);
    expect(third, isNot(first));
  });

  test('Low zoom uses coarse resolution; mid zoom bumps precision', () async {
    final db = buildTestDb();
    final directory = Directory.systemTemp.createTempSync(
      'fog_of_war_repo_zoom_test',
    );
    addTearDown(() async {
      await db.close();
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    final h3 = FakeVisitedGridH3Service();
    final coarseCell = h3.fakeCell(latitude: 0, longitude: 0, resolution: 6);
    final midCell = h3.fakeCell(latitude: 0, longitude: 0, resolution: 7);
    h3.setBoundary(
      coarseCell,
      const [
        LatLng(-0.01, -0.01),
        LatLng(-0.01, 0.01),
        LatLng(0.01, 0.01),
        LatLng(0.01, -0.01),
      ],
    );
    h3.setBoundary(
      midCell,
      const [
        LatLng(-0.005, -0.005),
        LatLng(-0.005, 0.005),
        LatLng(0.005, 0.005),
        LatLng(0.005, -0.005),
      ],
    );

    await db.visitedGridDao.upsertVisit(
      cells: [
        VisitedGridCell(resolution: 6, cellId: coarseCell.toString()),
        VisitedGridCell(resolution: 7, cellId: midCell.toString()),
      ],
      cellBounds: [
        ...h3.cellBounds(coarseCell),
        ...h3.cellBounds(midCell),
      ],
      day: 20250101,
      hourMask: 1,
      epochSeconds: 1,
      latE5: 0,
      lonE5: 0,
      baseResolution: 6,
      baseCellId: coarseCell.toString(),
      baseCellAreaM2: 1,
    );

    final rasterService = FakeRasterService();
    final cacheService = FogOfWarTileCacheService(
      pathProvider: FakeTileCachePathProvider(directory),
      maxEntries: 5,
    );
    final repository = FogOfWarTileRepository(
      visitedGridDao: db.visitedGridDao,
      h3Service: h3,
      rasterService: rasterService,
      cacheService: cacheService,
      visitedGridConfig: const VisitedGridConfig(),
    );

    final lowTile = _tileForLatLng(
      latitude: 0,
      longitude: 0,
      zoom: 8,
      tileSize: repository.tileSize,
    );
    h3.boundaryCallCells.clear();
    await repository.loadTile(
      x: lowTile.x,
      y: lowTile.y,
      z: 8,
    );
    expect(h3.boundaryCallCells.toSet(), {coarseCell});

    final midTile = _tileForLatLng(
      latitude: 0,
      longitude: 0,
      zoom: 9,
      tileSize: repository.tileSize,
    );
    h3.boundaryCallCells.clear();
    await repository.loadTile(
      x: midTile.x,
      y: midTile.y,
      z: 9,
    );
    expect(h3.boundaryCallCells.toSet(), {midCell});
  });

  test('Low zoom increases overlay opacity', () async {
    final db = buildTestDb();
    final directory = Directory.systemTemp.createTempSync(
      'fog_of_war_repo_opacity_test',
    );
    addTearDown(() async {
      await db.close();
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    final rasterService = FakeRasterService();
    final cacheService = FogOfWarTileCacheService(
      pathProvider: FakeTileCachePathProvider(directory),
      maxEntries: 5,
    );
    final repository = FogOfWarTileRepository(
      visitedGridDao: db.visitedGridDao,
      h3Service: FakeVisitedGridH3Service(),
      rasterService: rasterService,
      cacheService: cacheService,
      visitedGridConfig: const VisitedGridConfig(),
    );

    await repository.loadTile(x: 0, y: 0, z: 8);
    await repository.loadTile(x: 0, y: 0, z: 9);

    expect(rasterService.styles.length, 2);
    expect(
      rasterService.styles.first.highlightOpacity,
      greaterThan(rasterService.styles.last.highlightOpacity),
    );
  });
}
