import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:h3_flutter/h3_flutter.dart';
import 'package:latlong2/latlong.dart';

import 'package:explored/features/location/data/models/lat_lng_sample.dart';
import 'package:explored/features/location/data/models/location_permission_level.dart';
import 'package:explored/features/location/data/repositories/location_updates_repository.dart';
import 'package:explored/features/location/data/services/location_history_database.dart';
import 'package:explored/features/location/data/services/location_history_h3_service.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_bounds.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_cell.dart';
import 'package:explored/features/visited_grid/data/models/visited_grid_cell_bounds.dart';
import 'package:explored/features/visited_grid/data/services/visited_grid_database.dart';
import 'package:explored/features/visited_grid/data/services/visited_grid_h3_service.dart';

VisitedGridDatabase buildTestDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return VisitedGridDatabase(executor: NativeDatabase.memory());
}

LocationHistoryDatabase buildHistoryTestDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return LocationHistoryDatabase(
    executor: NativeDatabase.memory(),
    h3Service: LocationHistoryH3Service(
      cellIdResolver: (lat, lon) =>
          '${(lat * 100000).round()}_${(lon * 100000).round()}',
    ),
  );
}

class TestVisitedGridDao extends VisitedGridDao {
  TestVisitedGridDao(super.db);

  int upsertCalls = 0;
  int deleteDailyCalls = 0;
  int setCleanupCalls = 0;
  final List<int> deleteCutoffs = [];
  final List<int> cleanupValues = [];
  Completer<void>? upsertGate;

  @override
  Future<VisitedGridUpsertResult> upsertVisit({
    required List<VisitedGridCell> cells,
    required List<VisitedGridCellBounds> cellBounds,
    required int day,
    required int hourMask,
    required int epochSeconds,
    required int latE5,
    required int lonE5,
    required int baseResolution,
    required String baseCellId,
    required double baseCellAreaM2,
  }) async {
    upsertCalls += 1;
    final gate = upsertGate;
    if (gate != null) {
      await gate.future;
    }
    return super.upsertVisit(
      cells: cells,
      cellBounds: cellBounds,
      day: day,
      hourMask: hourMask,
      epochSeconds: epochSeconds,
      latE5: latE5,
      lonE5: lonE5,
      baseResolution: baseResolution,
      baseCellId: baseCellId,
      baseCellAreaM2: baseCellAreaM2,
    );
  }

  @override
  Future<int> deleteDailyOlderThan(int cutoffDay) {
    deleteDailyCalls += 1;
    deleteCutoffs.add(cutoffDay);
    return super.deleteDailyOlderThan(cutoffDay);
  }

  @override
  Future<void> setLastCleanupTs(int epochSeconds) {
    setCleanupCalls += 1;
    cleanupValues.add(epochSeconds);
    return super.setLastCleanupTs(epochSeconds);
  }
}

class FakeVisitedGridH3Service implements VisitedGridH3Service {
  final Map<int, List<H3Index>> polygonCellsByResolution = {};
  final Map<H3Index, _CellData> _cells = {};
  final Map<H3Index, List<LatLng>> _boundaries = {};
  final List<int> polygonResolutions = [];
  int polygonCalls = 0;
  int cellForLatLngCalls = 0;
  int parentCellCalls = 0;
  int cellBoundaryCalls = 0;
  final List<H3Index> boundaryCallCells = [];
  int cellsToMultiPolygonCalls = 0;
  int compactCellsCalls = 0;
  int cellBoundsCalls = 0;
  int gridDiskCalls = 0;

  @override
  H3Index cellForLatLng({
    required double latitude,
    required double longitude,
    required int resolution,
  }) {
    cellForLatLngCalls += 1;
    final cell = _cellId(latitude, longitude, resolution);
    _cells[cell] = _CellData(
      latitude: latitude,
      longitude: longitude,
      resolution: resolution,
    );
    return cell;
  }

  @override
  H3Index parentCell({
    required H3Index cell,
    required int resolution,
  }) {
    parentCellCalls += 1;
    final data = _cells[cell] ??
        _CellData(latitude: 0, longitude: 0, resolution: resolution);
    final parent = _cellId(data.latitude, data.longitude, resolution);
    _cells[parent] = _CellData(
      latitude: data.latitude,
      longitude: data.longitude,
      resolution: resolution,
    );
    return parent;
  }

  @override
  GeoCoord cellToGeo(H3Index cell) {
    final data = _cells[cell] ??
        _CellData(latitude: 0, longitude: 0, resolution: 0);
    return GeoCoord(lat: data.latitude, lon: data.longitude);
  }

  @override
  List<H3Index> polygonToCells({
    required VisitedGridBounds bounds,
    required int resolution,
  }) {
    polygonCalls += 1;
    polygonResolutions.add(resolution);
    return polygonCellsByResolution[resolution] ?? const <H3Index>[];
  }

  @override
  List<List<List<GeoCoord>>> cellsToMultiPolygon(List<H3Index> cells) {
    cellsToMultiPolygonCalls += 1;
    return [
      for (final cell in cells)
        [
          [
            for (final point in cellBoundary(cell))
              GeoCoord(lat: point.latitude, lon: point.longitude),
          ],
        ],
    ];
  }

  @override
  List<H3Index> compactCells(List<H3Index> cells) {
    compactCellsCalls += 1;
    return cells;
  }

  @override
  List<H3Index> gridDisk(H3Index cell, int ringSize) {
    gridDiskCalls += 1;
    return [cell];
  }

  @override
  double cellArea(H3Index cell, H3Units unit) {
    return 50.0;
  }

  @override
  List<LatLng> cellBoundary(H3Index cell) {
    cellBoundaryCalls += 1;
    boundaryCallCells.add(cell);
    final cached = _boundaries[cell];
    if (cached != null) {
      return cached;
    }
    final data = _cells[cell] ??
        _CellData(latitude: 0, longitude: 0, resolution: 0);
    final boundary = <LatLng>[
      LatLng(data.latitude, data.longitude),
      LatLng(data.latitude, data.longitude + 0.001),
      LatLng(data.latitude + 0.001, data.longitude + 0.001),
      LatLng(data.latitude + 0.001, data.longitude),
    ];
    _boundaries[cell] = boundary;
    return boundary;
  }

  @override
  String encodeCellId(H3Index cell) => cell.toString();

  @override
  H3Index decodeCellId(String cellId) => BigInt.parse(cellId);

  @override
  List<VisitedGridCellBounds> cellBounds(H3Index cell) {
    cellBoundsCalls += 1;
    final boundary = cellBoundary(cell);
    if (boundary.isEmpty) {
      return const [];
    }
    var minLat = boundary.first.latitude;
    var maxLat = boundary.first.latitude;
    var minLon = boundary.first.longitude;
    var maxLon = boundary.first.longitude;
    for (final point in boundary.skip(1)) {
      if (point.latitude < minLat) {
        minLat = point.latitude;
      }
      if (point.latitude > maxLat) {
        maxLat = point.latitude;
      }
      if (point.longitude < minLon) {
        minLon = point.longitude;
      }
      if (point.longitude > maxLon) {
        maxLon = point.longitude;
      }
    }
    final data = _cells[cell] ??
        _CellData(latitude: 0, longitude: 0, resolution: 0);
    return [
      VisitedGridCellBounds(
        resolution: data.resolution,
        cellId: encodeCellId(cell),
        segment: 0,
        minLatE5: (minLat * 100000).floor(),
        maxLatE5: (maxLat * 100000).ceil(),
        minLonE5: (minLon * 100000).floor(),
        maxLonE5: (maxLon * 100000).ceil(),
      ),
    ];
  }

  H3Index fakeCell({
    required double latitude,
    required double longitude,
    required int resolution,
  }) {
    final cell = _cellId(latitude, longitude, resolution);
    _cells[cell] = _CellData(
      latitude: latitude,
      longitude: longitude,
      resolution: resolution,
    );
    return cell;
  }

  void setBoundary(H3Index cell, List<LatLng> boundary) {
    _boundaries[cell] = boundary;
  }

  H3Index _cellId(double latitude, double longitude, int resolution) {
    final latOffset = (latitude * 100000).round() + 9000000;
    final lonOffset = (longitude * 100000).round() + 18000000;
    const resMultiplier = 100000000000000;
    const latMultiplier = 10000000;
    return BigInt.from(resolution) * BigInt.from(resMultiplier) +
        BigInt.from(latOffset) * BigInt.from(latMultiplier) +
        BigInt.from(lonOffset);
  }
}

class _CellData {
  _CellData({
    required this.latitude,
    required this.longitude,
    required this.resolution,
  });

  final double latitude;
  final double longitude;
  final int resolution;
}

class TestLocationUpdatesRepository implements LocationUpdatesRepository {
  TestLocationUpdatesRepository({
    this.permissionLevel = LocationPermissionLevel.foreground,
  });

  final StreamController<LatLngSample> _controller =
      StreamController<LatLngSample>.broadcast(sync: true);
  LocationPermissionLevel permissionLevel;
  bool _isRunning = false;

  @override
  Stream<LatLngSample> get locationUpdates => _controller.stream;

  @override
  bool get isRunning => _isRunning;

  @override
  Future<void> startTracking() async {
    _isRunning = true;
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
    return permissionLevel;
  }

  @override
  Future<LocationPermissionLevel> requestBackgroundPermission() async {
    return permissionLevel;
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

  void emit(LatLngSample sample) {
    _controller.add(sample);
  }

  Future<void> close() async {
    await _controller.close();
  }
}
