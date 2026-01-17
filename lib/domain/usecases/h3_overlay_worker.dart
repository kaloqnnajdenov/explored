import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart';

import 'package:explored/features/visited_grid/data/models/visited_grid_bounds.dart';
import 'package:explored/features/visited_grid/data/models/visited_overlay_mode.dart';
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
    this.maxCandidate = 2500,
    this.minResolution = 6,
    this.baseResolution = 12,
    this.maxQueryChunkSize = 800,
    this.paddingFactor = 1.25,
    this.databaseName = 'visited_grid',
  });

  final int maxCandidate;
  final int minResolution;
  final int baseResolution;
  final int maxQueryChunkSize;
  final double paddingFactor;
  final String databaseName;

  Map<String, Object?> toMap() => {
        'maxCandidate': maxCandidate,
        'minResolution': minResolution,
        'baseResolution': baseResolution,
        'maxQueryChunkSize': maxQueryChunkSize,
        'paddingFactor': paddingFactor,
        'databaseName': databaseName,
      };

  static H3OverlayWorkerConfig fromMap(Map<String, Object?> map) {
    return H3OverlayWorkerConfig(
      maxCandidate: map['maxCandidate'] as int,
      minResolution: map['minResolution'] as int,
      baseResolution: map['baseResolution'] as int,
      maxQueryChunkSize: map['maxQueryChunkSize'] as int,
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
    required this.candidateCellIds,
  });

  final int requestId;
  final int resolution;
  final Set<String> visitedCellIds;
  final Set<String> candidateCellIds;

  static H3OverlayResult fromMap(Map<dynamic, dynamic> map) {
    return H3OverlayResult(
      requestId: map['requestId'] as int,
      resolution: map['resolution'] as int,
      visitedCellIds: Set<String>.from(
        (map['visitedIds'] as List).cast<String>(),
      ),
      candidateCellIds: Set<String>.from(
        (map['candidateIds'] as List).cast<String>(),
      ),
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
    maxChunkSize: config.maxQueryChunkSize,
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
  final zoom = (message['zoom'] as num).toDouble();
  final mode = OverlayMode.fromMap(
    (message['mode'] as Map).cast<String, Object?>(),
  );

  final paddedBounds = _padBounds(bounds, config.paddingFactor);
  var resolution = H3OverlayWorker.desiredResForZoom(
    zoom: zoom,
    baseResolution: config.baseResolution,
    minResolution: config.minResolution,
  );

  var candidates = h3Service.polygonToCells(
    bounds: paddedBounds,
    resolution: resolution,
  );

  while (candidates.length > config.maxCandidate &&
      resolution > config.minResolution) {
    resolution -= 1;
    candidates = h3Service.polygonToCells(
      bounds: paddedBounds,
      resolution: resolution,
    );
  }

  if (candidates.length > config.maxCandidate) {
    candidates = candidates.sublist(0, config.maxCandidate);
  }

  final candidateIds =
      candidates.map(h3Service.encodeCellId).toList(growable: false);
  Set<String> visitedIds;
  if (candidateIds.isEmpty) {
    visitedIds = <String>{};
  } else if (mode is OverlayModeAllTime) {
    visitedIds = await repo.fetchLifetimeVisited(
      resolution: resolution,
      candidateIds: candidateIds,
    );
  } else if (mode is OverlayModeDateRange) {
    visitedIds = await repo.fetchDailyVisited(
      resolution: resolution,
      fromDay: mode.fromDay,
      toDay: mode.toDay,
      candidateIds: candidateIds,
    );
  } else {
    visitedIds = <String>{};
  }

  return {
    'requestId': message['requestId'] as int,
    'resolution': resolution,
    'visitedIds': visitedIds.toList(growable: false),
    'candidateIds': candidateIds,
  };
}

VisitedGridBounds _padBounds(VisitedGridBounds bounds, double factor) {
  final latSpan = (bounds.north - bounds.south).abs();
  final lonSpan = (bounds.east - bounds.west).abs();
  final paddedLatSpan = latSpan * factor;
  final paddedLonSpan = lonSpan * factor;
  final centerLat = (bounds.north + bounds.south) / 2;
  final centerLon = (bounds.east + bounds.west) / 2;
  final halfLat = paddedLatSpan / 2;
  final halfLon = paddedLonSpan / 2;

  return VisitedGridBounds(
    north: _clamp(centerLat + halfLat, -90, 90),
    south: _clamp(centerLat - halfLat, -90, 90),
    east: _clamp(centerLon + halfLon, -180, 180),
    west: _clamp(centerLon - halfLon, -180, 180),
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
