import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:h3_flutter/h3_flutter.dart';
import 'package:latlong2/latlong.dart';

import '../models/fog_of_war_config.dart';
import '../models/fog_of_war_style.dart';
import '../models/fog_of_war_tile_key.dart';
import '../models/visited_grid_bounds.dart';
import '../models/visited_grid_config.dart';
import '../services/fog_of_war_tile_cache_service.dart';
import '../services/fog_of_war_tile_raster_service.dart';
import '../services/visited_grid_database.dart';
import '../services/visited_grid_h3_service.dart';

class FogOfWarTileRepository {
  FogOfWarTileRepository({
    required VisitedGridDao visitedGridDao,
    required VisitedGridH3Service h3Service,
    required FogOfWarTileRasterService rasterService,
    required FogOfWarTileCacheService cacheService,
    required VisitedGridConfig visitedGridConfig,
    FogOfWarConfig config = const FogOfWarConfig(),
    int? initialTileSize,
  })  : _visitedGridDao = visitedGridDao,
        _h3Service = h3Service,
        _rasterService = rasterService,
        _cacheService = cacheService,
        _visitedGridConfig = visitedGridConfig,
        _config = config,
        _tileSize = initialTileSize ?? config.defaultTileSize;

  final VisitedGridDao _visitedGridDao;
  final VisitedGridH3Service _h3Service;
  final FogOfWarTileRasterService _rasterService;
  final FogOfWarTileCacheService _cacheService;
  final VisitedGridConfig _visitedGridConfig;
  final FogOfWarConfig _config;
  int _tileSize;

  final Set<FogOfWarTileKey> _invalidated = <FogOfWarTileKey>{};
  static const int _minResolutionBoost = 1;

  int get tileSize => _tileSize;
  FogOfWarStyle get style => _config.style;
  String get cacheId =>
      '${style.id}_${_policyId()}_r${_visitedGridConfig.baseResolution}';

  Future<void> setTileSize(int tileSize) async {
    if (_tileSize == tileSize) {
      return;
    }
    _tileSize = tileSize;
    _invalidated.clear();
    await _cacheService.clear();
  }

  void invalidateForCell(String cellId) {
    final cell = _h3Service.decodeCellId(cellId);

    for (var zoom = _config.minZoom; zoom <= _config.maxZoom; zoom++) {
      final padding = _styleForZoom(zoom).blurSigma > 0 ? 1 : 0;
      final boundary = _boundaryForZoom(cell, zoom);
      if (boundary.isEmpty) {
        continue;
      }
      var minX = 1 << 30;
      var minY = 1 << 30;
      var maxX = -1;
      var maxY = -1;
      for (final point in boundary) {
        final tile = _tileForLatLng(
          latitude: point.latitude,
          longitude: point.longitude,
          zoom: zoom,
        );
        minX = math.min(minX, tile.x);
        minY = math.min(minY, tile.y);
        maxX = math.max(maxX, tile.x);
        maxY = math.max(maxY, tile.y);
      }

      final tilesAtZoom = 1 << zoom;
      if (maxX < 0 || maxY < 0) {
        continue;
      }

      for (var x = minX - padding; x <= maxX + padding; x++) {
        final wrappedX = _wrapTile(x, tilesAtZoom);
        for (var y = minY - padding; y <= maxY + padding; y++) {
          final clampedY = y.clamp(0, tilesAtZoom - 1);
          _invalidated.add(
            FogOfWarTileKey(
              x: wrappedX,
              y: clampedY,
              z: zoom,
              tileSize: _tileSize,
              styleId: cacheId,
            ),
          );
        }
      }
    }
  }

  Future<Uint8List> loadTile({
    required int x,
    required int y,
    required int z,
  }) async {
    final key = FogOfWarTileKey(
      x: x,
      y: y,
      z: z,
      tileSize: _tileSize,
      styleId: cacheId,
    );

    if (!_invalidated.contains(key)) {
      final memory = _cacheService.readFromMemory(key);
      if (memory != null) {
        return memory;
      }
      final disk = await _cacheService.readFromDisk(key);
      if (disk != null) {
        _cacheService.writeToMemory(key, disk);
        return disk;
      }
    }

    _invalidated.remove(key);
    final bytes = await _renderTile(key);
    _cacheService.writeToMemory(key, bytes);
    await _cacheService.writeToDisk(key, bytes);
    return bytes;
  }

  Future<Uint8List> _renderTile(FogOfWarTileKey key) async {
    final bounds = _boundsForTile(
      x: key.x,
      y: key.y,
      z: key.z,
      tileSize: key.tileSize,
    );
    final resolution = _effectiveResolutionForZoom(key.z);
    final renderStyle = _styleForZoom(key.z);
    final visitedIds = await _visitedGridDao.fetchVisitedLifetimeInBounds(
      resolution: resolution,
      southLatE5: (bounds.south * 100000).floor(),
      northLatE5: (bounds.north * 100000).ceil(),
      westLonE5: (bounds.west * 100000).floor(),
      eastLonE5: (bounds.east * 100000).ceil(),
    );
    if (visitedIds.isEmpty) {
      return _rasterService.rasterizeTile(
        polygons: const [],
        tileSize: key.tileSize,
        style: renderStyle,
      );
    }

    final polygons = <List<ui.Offset>>[];
    for (final cellId in visitedIds) {
      final cell = _h3Service.decodeCellId(cellId);
      final boundary = _unwrapBoundary(
        _h3Service.cellBoundary(cell),
        _h3Service.cellToGeo(cell).lon,
      );
      if (boundary.isEmpty) {
        continue;
      }
      polygons.add(
        boundary
            .map(
              (point) => _projectPoint(
                latitude: point.latitude,
                longitude: point.longitude,
                tileX: key.x,
                tileY: key.y,
                zoom: key.z,
                tileSize: key.tileSize,
              ),
            )
            .toList(growable: false),
      );
    }

    return _rasterService.rasterizeTile(
      polygons: polygons,
      tileSize: key.tileSize,
      style: renderStyle,
    );
  }

  VisitedGridBounds _boundsForTile({
    required int x,
    required int y,
    required int z,
    required int tileSize,
  }) {
    final scale = _worldScale(z);
    final west = (x * tileSize) / scale * 360.0 - 180.0;
    final east = ((x + 1) * tileSize) / scale * 360.0 - 180.0;
    final north = _latFromPixel(y * tileSize.toDouble(), scale);
    final south = _latFromPixel((y + 1) * tileSize.toDouble(), scale);
    return VisitedGridBounds(
      north: north,
      south: south,
      east: east,
      west: west,
    );
  }

  _TileCoord _tileForLatLng({
    required double latitude,
    required double longitude,
    required int zoom,
  }) {
    final scale = _worldScale(zoom);
    final siny = math.sin(latitude * math.pi / 180.0).clamp(-0.9999, 0.9999);
    final x = (longitude + 180.0) / 360.0 * scale;
    final y =
        (0.5 - math.log((1 + siny) / (1 - siny)) / (4 * math.pi)) * scale;
    final tileX = (x / _tileSize).floor();
    final tileY = (y / _tileSize).floor();
    final tilesAtZoom = 1 << zoom;
    return _TileCoord(
      x: _wrapTile(tileX, tilesAtZoom),
      y: tileY.clamp(0, tilesAtZoom - 1),
    );
  }

  ui.Offset _projectPoint({
    required double latitude,
    required double longitude,
    required int tileX,
    required int tileY,
    required int zoom,
    required int tileSize,
  }) {
    final scale = _worldScale(zoom);
    final siny = math.sin(latitude * math.pi / 180.0).clamp(-0.9999, 0.9999);
    final x = (longitude + 180.0) / 360.0 * scale;
    final y =
        (0.5 - math.log((1 + siny) / (1 - siny)) / (4 * math.pi)) * scale;
    final localX = x - tileX * tileSize;
    final localY = y - tileY * tileSize;
    return ui.Offset(localX, localY);
  }

  double _worldScale(int zoom) => 256.0 * math.pow(2, zoom).toDouble();

  double _latFromPixel(double y, double scale) {
    final n = math.pi - 2.0 * math.pi * y / scale;
    return 180.0 / math.pi * math.atan(_sinh(n));
  }

  double _sinh(double value) {
    return (math.exp(value) - math.exp(-value)) / 2;
  }

  int _wrapTile(int x, int tilesAtZoom) {
    var value = x % tilesAtZoom;
    if (value < 0) {
      value += tilesAtZoom;
    }
    return value;
  }

  int _effectiveResolutionForZoom(int zoom) {
    final mapped = _visitedGridConfig.resolutionForZoom(zoom.toDouble());
    if (zoom <= _config.specialModeMaxZoom) {
      return _visitedGridConfig.minRenderResolution;
    }
    if (mapped == _visitedGridConfig.minRenderResolution) {
      final bumped = mapped + _minResolutionBoost;
      return bumped > _visitedGridConfig.baseResolution
          ? _visitedGridConfig.baseResolution
          : bumped;
    }
    return mapped;
  }

  List<LatLng> _boundaryForZoom(H3Index cell, int zoom) {
    final resolution = _effectiveResolutionForZoom(zoom);
    final renderCell = _h3Service.parentCell(
      cell: cell,
      resolution: resolution,
    );
    final centerLon = _h3Service.cellToGeo(renderCell).lon;
    return _unwrapBoundary(
      _h3Service.cellBoundary(renderCell),
      centerLon,
    );
  }

  FogOfWarStyle _styleForZoom(int zoom) {
    if (zoom > _config.specialModeMaxZoom) {
      return style;
    }
    final boostedOpacity = (style.highlightOpacity *
            _config.lowZoomOpacityMultiplier)
        .clamp(style.highlightOpacity, 1.0)
        .toDouble();
    if (boostedOpacity == style.highlightOpacity) {
      return style;
    }
    return FogOfWarStyle(
      highlightColor: style.highlightColor,
      highlightOpacity: boostedOpacity,
      blurSigma: style.blurSigma,
    );
  }

  String _policyId() {
    final opacityTag =
        _config.lowZoomOpacityMultiplier.toStringAsFixed(2);
    return 'z${_config.specialModeMaxZoom}_boost$_minResolutionBoost'
        '_op$opacityTag';
  }

  List<LatLng> _unwrapBoundary(List<LatLng> boundary, double centerLon) {
    return boundary
        .map(
          (point) => LatLng(
            point.latitude,
            _unwrapLon(point.longitude, centerLon),
          ),
        )
        .toList(growable: false);
  }

  double _unwrapLon(double lon, double centerLon) {
    var adjusted = lon;
    while (adjusted - centerLon > 180) {
      adjusted -= 360;
    }
    while (adjusted - centerLon < -180) {
      adjusted += 360;
    }
    return adjusted;
  }
}

class _TileCoord {
  const _TileCoord({required this.x, required this.y});

  final int x;
  final int y;
}
