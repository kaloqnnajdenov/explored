import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart';
import 'package:h3_flutter/h3_flutter.dart';

import 'package:explored/constants.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_bounds.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_cell_bounds.dart';
import 'package:explored/features/visited_grid/data/models/visited_overlay_mode.dart';
import 'package:explored/features/visited_grid/data/models/visited_overlay_render_mode.dart';
import 'package:explored/features/visited_grid/data/repositories/visited_repo.dart';
import 'package:explored/features/visited_grid/data/services/visited_grid_database.dart';
import 'package:explored/features/visited_grid/data/services/visited_grid_h3_service.dart';

abstract class VisitedOverlayWorker {
  Future<H3OverlayResult> queryOverlay({
    required int requestId,
    required VisitedGridBounds bounds,
    required double zoom,
    required OverlayMode mode,
  });

  Future<void> dispose();
}

class H3OverlayWorker implements VisitedOverlayWorker {
  H3OverlayWorker({H3OverlayWorkerConfig config = const H3OverlayWorkerConfig()})
      : _config = config,
        _rootToken = RootIsolateToken.instance;

  final H3OverlayWorkerConfig _config;
  final RootIsolateToken? _rootToken;
  final ReceivePort _receivePort = ReceivePort();
  final Map<int, Completer<H3OverlayResult>> _pending = {};
  final Completer<void> _ready = Completer<void>();
  Isolate? _isolate;
  SendPort? _sendPort;
  bool _disposed = false;

  @override
  Future<H3OverlayResult> queryOverlay({
    required int requestId,
    required VisitedGridBounds bounds,
    required double zoom,
    required OverlayMode mode,
  }) async {
    if (_disposed) {
      throw StateError('H3OverlayWorker is disposed');
    }
    await _ensureStarted();

    final completer = Completer<H3OverlayResult>();
    _pending[requestId] = completer;
    _sendPort!.send({
      'requestId': requestId,
      'bounds': {
        'north': bounds.north,
        'south': bounds.south,
        'east': bounds.east,
        'west': bounds.west,
      },
      'zoom': zoom,
      'mode': mode.toMap(),
    });
    return completer.future;
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    for (final entry in _pending.entries) {
      entry.value.completeError(StateError('H3OverlayWorker disposed'));
    }
    _pending.clear();
    _receivePort.close();
    _isolate?.kill(priority: Isolate.immediate);
  }

  Future<void> _ensureStarted() async {
    if (_sendPort != null) {
      return;
    }

    _receivePort.listen(_handleMessage);
    _isolate = await Isolate.spawn(
      _overlayWorkerMain,
      {
        'replyPort': _receivePort.sendPort,
        'rootToken': _rootToken,
        'config': _config.toMap(),
      },
    );
    await _ready.future;
  }

  void _handleMessage(dynamic message) {
    if (message is SendPort) {
      if (!_ready.isCompleted) {
        _sendPort = message;
        _ready.complete();
      }
      return;
    }

    if (message is! Map) {
      return;
    }

    final requestId = message['requestId'];
    if (requestId is! int) {
      return;
    }

    final completer = _pending.remove(requestId);
    if (completer == null) {
      return;
    }

    if (message['error'] != null) {
      completer.completeError(StateError(message['error'] as String));
      return;
    }

    completer.complete(H3OverlayResult.fromMap(message));
  }

  static int desiredResForZoom({
    required double zoom,
    required int baseResolution,
    required int minResolution,
  }) {
    var resolution = baseResolution;
    if (zoom >= 16) {
      resolution = baseResolution;
    } else if (zoom >= 15) {
      resolution = baseResolution - 1;
    } else if (zoom >= 14) {
      resolution = baseResolution - 2;
    } else if (zoom >= 13) {
      resolution = baseResolution - 3;
    } else if (zoom >= 12) {
      resolution = baseResolution - 4;
    } else if (zoom >= 10.5) {
      resolution = baseResolution - 5;
    } else {
      resolution = baseResolution - 6;
    }

    if (resolution < minResolution) {
      return minResolution;
    }
    if (resolution > baseResolution) {
      return baseResolution;
    }
    return resolution;
  }
}

class H3OverlayWorkerConfig {
  const H3OverlayWorkerConfig({
    this.minResolution = 6,
    this.baseResolution = 12,
    this.mergeThreshold = 2000,
    this.paddingFactor = 1.25,
    this.databaseName = 'visited_grid',
  });

  final int minResolution;
  final int baseResolution;
  final int mergeThreshold;
  final double paddingFactor;
  final String databaseName;

  Map<String, Object?> toMap() => {
        'minResolution': minResolution,
        'baseResolution': baseResolution,
        'mergeThreshold': mergeThreshold,
        'paddingFactor': paddingFactor,
        'databaseName': databaseName,
      };

  static H3OverlayWorkerConfig fromMap(Map<String, Object?> map) {
    return H3OverlayWorkerConfig(
      minResolution: map['minResolution'] as int,
      baseResolution: map['baseResolution'] as int,
      mergeThreshold: map['mergeThreshold'] as int,
      paddingFactor: (map['paddingFactor'] as num).toDouble(),
      databaseName: map['databaseName'] as String,
    );
  }
}

class H3OverlayResult {
  const H3OverlayResult({
    required this.requestId,
    required this.resolution,
    required this.visitedCellIds,
    required this.renderMode,
    required this.mergedPolygons,
  });

  final int requestId;
  final int resolution;
  final Set<String> visitedCellIds;
  final VisitedOverlayRenderMode renderMode;
  final List<List<List<List<double>>>> mergedPolygons;

  static H3OverlayResult fromMap(Map<dynamic, dynamic> map) {
    return H3OverlayResult(
      requestId: map['requestId'] as int,
      resolution: map['resolution'] as int,
      visitedCellIds: Set<String>.from(
        (map['visitedIds'] as List).cast<String>(),
      ),
      renderMode: VisitedOverlayRenderMode.fromWire(
        map['renderMode'] as String,
      ),
      mergedPolygons: (map['mergedPolygons'] as List)
          .map(
            (polygon) => (polygon as List)
                .map(
                  (ring) => (ring as List)
                      .map(
                        (coord) => (coord as List)
                            .map((value) => (value as num).toDouble())
                            .toList(growable: false),
                      )
                      .toList(growable: false),
                )
                .toList(growable: false),
          )
          .toList(growable: false),
    );
  }
}

@pragma('vm:entry-point')
void _overlayWorkerMain(Map<String, Object?> message) {
  final replyPort = message['replyPort'] as SendPort;
  final rootToken = message['rootToken'] as RootIsolateToken?;
  if (rootToken != null) {
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
  }
  DartPluginRegistrant.ensureInitialized();
  final config =
      H3OverlayWorkerConfig.fromMap(message['config'] as Map<String, Object?>);

  final requestPort = ReceivePort();
  replyPort.send(requestPort.sendPort);

  final h3Service = VisitedGridH3Service();
  final database = VisitedGridDatabase(
    executor: driftDatabase(
      name: config.databaseName,
      native: const DriftNativeOptions(shareAcrossIsolates: true),
    ),
  );
  final repo = DriftVisitedRepo(
    visitedGridDao: database.visitedGridDao,
  );

  requestPort.listen((dynamic rawMessage) async {
    if (rawMessage is! Map) {
      return;
    }

    final requestId = rawMessage['requestId'];
    if (requestId is! int) {
      return;
    }

    try {
      final result = await _handleRequest(
        rawMessage,
        config,
        h3Service,
        repo,
      );
      replyPort.send(result);
    } catch (error) {
      replyPort.send({
        'requestId': requestId,
        'error': error.toString(),
      });
    }
  });
}

Future<Map<String, Object?>> _handleRequest(
  Map<dynamic, dynamic> message,
  H3OverlayWorkerConfig config,
  VisitedGridH3Service h3Service,
  VisitedRepo repo,
) async {
  final boundsMap = message['bounds'] as Map;
  final bounds = VisitedGridBounds(
    north: (boundsMap['north'] as num).toDouble(),
    south: (boundsMap['south'] as num).toDouble(),
    east: (boundsMap['east'] as num).toDouble(),
    west: (boundsMap['west'] as num).toDouble(),
  );
  final mode = OverlayMode.fromMap(
    (message['mode'] as Map).cast<String, Object?>(),
  );

  final paddedBounds = _padBounds(bounds, config.paddingFactor);
  final resolution = config.baseResolution;
  await _ensureBoundsForResolution(
    resolution: resolution,
    repo: repo,
    h3Service: h3Service,
  );

  Set<String> visitedIds;
  if (mode is OverlayModeAllTime) {
    visitedIds = await repo.fetchLifetimeVisitedInBounds(
      resolution: resolution,
      bounds: paddedBounds,
    );
  } else if (mode is OverlayModeDateRange) {
    visitedIds = await repo.fetchDailyVisitedInBounds(
      resolution: resolution,
      fromDay: mode.fromDay,
      toDay: mode.toDay,
      bounds: paddedBounds,
    );
  } else {
    visitedIds = <String>{};
  }

  final renderMode = visitedIds.length > config.mergeThreshold
      ? VisitedOverlayRenderMode.merged
      : VisitedOverlayRenderMode.perCell;

  List<List<List<List<double>>>> mergedPolygons = const [];
  if (renderMode == VisitedOverlayRenderMode.merged &&
      visitedIds.isNotEmpty) {
    final cells = visitedIds
        .map(h3Service.decodeCellId)
        .toList(growable: false);
    final multi = h3Service.cellsToMultiPolygon(cells);
    mergedPolygons = _serializeMultiPolygon(multi);
  }

  return {
    'requestId': message['requestId'] as int,
    'resolution': resolution,
    'visitedIds': visitedIds.toList(growable: false),
    'renderMode': renderMode.toWire(),
    'mergedPolygons': mergedPolygons,
  };
}

VisitedGridBounds _padBounds(VisitedGridBounds bounds, double factor) {
  if (factor <= 1) {
    return bounds;
  }

  final latSpan = (bounds.north - bounds.south).abs();
  final paddedLatSpan = latSpan * factor;
  final centerLat = (bounds.north + bounds.south) / 2;
  final halfLat = paddedLatSpan / 2;

  final west = bounds.west;
  final east = bounds.east;
  final lonSpan = east >= west
      ? (east - west)
      : (180 - west) + (east + 180);
  final paddedLonSpan = lonSpan * factor;
  final halfLon = paddedLonSpan / 2;
  var centerLon = west + lonSpan / 2;
  centerLon = _wrapLon(centerLon);

  return VisitedGridBounds(
    north: _clamp(centerLat + halfLat, -90, 90),
    south: _clamp(centerLat - halfLat, -90, 90),
    east: _wrapLon(centerLon + halfLon),
    west: _wrapLon(centerLon - halfLon),
  );
}

double _clamp(double value, double min, double max) {
  if (value < min) {
    return min;
  }
  if (value > max) {
    return max;
  }
  return value;
}

double _wrapLon(double lon) {
  var wrapped = lon;
  while (wrapped > 180) {
    wrapped -= 360;
  }
  while (wrapped < -180) {
    wrapped += 360;
  }
  return wrapped;
}

final Map<int, Future<void>> _boundsEnsureTasks = <int, Future<void>>{};

Future<void> _ensureBoundsForResolution({
  required int resolution,
  required VisitedRepo repo,
  required VisitedGridH3Service h3Service,
}) {
  final existing = _boundsEnsureTasks[resolution];
  if (existing != null) {
    return existing;
  }
  final task = _ensureBoundsForResolutionInternal(
    resolution: resolution,
    repo: repo,
    h3Service: h3Service,
  );
  _boundsEnsureTasks[resolution] = task;
  task.catchError((_) {
    _boundsEnsureTasks.remove(resolution);
  });
  return task;
}

Future<void> _ensureBoundsForResolutionInternal({
  required int resolution,
  required VisitedRepo repo,
  required VisitedGridH3Service h3Service,
}) async {
  final count = await repo.countBoundsForResolution(resolution: resolution);
  if (count > 0) {
    return;
  }

  final cellIds = await repo.fetchLifetimeCellIds(resolution: resolution);
  if (cellIds.isEmpty) {
    return;
  }

  for (var i = 0; i < cellIds.length; i += kH3OverlayWorkerBatchSize) {
    final end = i + kH3OverlayWorkerBatchSize > cellIds.length
        ? cellIds.length
        : i + kH3OverlayWorkerBatchSize;
    final batch = cellIds.sublist(i, end);
    final bounds = <VisitedGridCellBounds>[];
    for (final cellId in batch) {
      final cell = h3Service.decodeCellId(cellId);
      bounds.addAll(h3Service.cellBounds(cell));
    }
    await repo.upsertCellBounds(bounds: bounds);
  }
}

List<List<List<List<double>>>> _serializeMultiPolygon(
  List<List<List<GeoCoord>>> polygons,
) {
  return polygons
      .map(
        (polygon) => polygon
            .map(_serializeRing)
            .where((ring) => ring.isNotEmpty)
            .toList(growable: false),
      )
      .where((polygon) => polygon.isNotEmpty)
      .toList(growable: false);
}

List<List<double>> _serializeRing(List<GeoCoord> ring) {
  if (ring.isEmpty) {
    return const [];
  }
  final points = [
    for (final coord in ring) [coord.lat, coord.lon],
  ];
  return _unwrapRingCoordinates(points);
}

List<List<double>> _unwrapRingCoordinates(List<List<double>> ring) {
  if (ring.isEmpty) {
    return ring;
  }
  final unwrapped = <List<double>>[];
  var prevLon = ring.first[1];
  var offset = 0.0;
  unwrapped.add([ring.first[0], prevLon]);
  for (var i = 1; i < ring.length; i++) {
    var lon = ring[i][1] + offset;
    final delta = lon - prevLon;
    if (delta > 180) {
      offset -= 360;
      lon -= 360;
    } else if (delta < -180) {
      offset += 360;
      lon += 360;
    }
    unwrapped.add([ring[i][0], lon]);
    prevLon = lon;
  }
  return unwrapped;
}
