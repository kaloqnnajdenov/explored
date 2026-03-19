import 'dart:async';

import 'package:explored/features/app_state/data/models/app_permission.dart';
import 'package:explored/features/app_state/data/models/app_state_snapshot.dart';
import 'package:explored/features/app_state/data/models/gps_quality.dart';
import 'package:explored/features/app_state/data/models/region.dart' as legacy;
import 'package:explored/features/app_state/data/models/user_point.dart';
import 'package:explored/features/app_state/data/repositories/app_state_repository.dart';
import 'package:explored/features/gpx_import/data/repositories/gpx_import_repository.dart';
import 'package:explored/features/gpx_import/data/services/gpx_file_picker_service.dart';
import 'package:explored/features/location/data/models/history_export_result.dart';
import 'package:explored/features/location/data/models/lat_lng_sample.dart';
import 'package:explored/features/location/data/models/location_permission_level.dart';
import 'package:explored/features/location/data/repositories/location_history_repository.dart';
import 'package:explored/features/location/data/repositories/location_updates_repository.dart';
import 'package:explored/features/map/data/models/map_tile_source.dart';
import 'package:explored/features/map/data/repositories/map_repository.dart';
import 'package:explored/features/map/data/services/map_attribution_service.dart';
import 'package:explored/features/map/data/services/map_tile_service.dart';
import 'package:explored/features/permissions/data/models/app_permission.dart';
import 'package:explored/features/permissions/data/repositories/permissions_repository.dart';
import 'package:explored/features/region_catalog/data/models/region_boundary.dart';
import 'package:explored/features/region_catalog/data/models/region_catalog.dart';
import 'package:explored/features/region_catalog/data/models/region_features.dart';
import 'package:explored/features/region_catalog/data/models/region_pack_bounds.dart';
import 'package:explored/features/region_catalog/data/models/region_pack_kind.dart';
import 'package:explored/features/region_catalog/data/models/region_pack_node.dart';
import 'package:explored/features/region_catalog/data/models/selected_pack_ref.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TestTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MemoryImage(TileProvider.transparentImage);
  }
}

class FakeMapTileService implements MapTileService {
  @override
  MapTileSource getTileSource() {
    return MapTileSource(
      urlTemplate: 'https://example.com/{z}/{x}/{y}.png',
      subdomains: ['a'],
      userAgentPackageName: 'com.explored.test',
      tileProvider: TestTileProvider(),
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
    return true;
  }

  @override
  Future<bool> openNotificationSettings() async {
    return true;
  }

  @override
  bool get requiresBackgroundPermission => requiresBackgroundPermissionFlag;

  void emit(LatLngSample sample) {
    _controller.add(sample);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

class FakeLocationHistoryRepository implements LocationHistoryRepository {
  final StreamController<List<LatLngSample>> _controller =
      StreamController<List<LatLngSample>>.broadcast();
  final List<LatLngSample> _samples = <LatLngSample>[];
  HistoryExportResult exportResult = const HistoryExportResult.success(
    filePath: 'export.csv',
  );
  HistoryExportResult downloadResult = const HistoryExportResult.success(
    filePath: 'download.csv',
  );

  @override
  Stream<List<LatLngSample>> get historyStream => _controller.stream;

  @override
  List<LatLngSample> get currentSamples => List.unmodifiable(_samples);

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {
    await _controller.close();
  }

  @override
  Future<List<LatLngSample>> addImportedSamples(
    List<LatLngSample> samples,
  ) async {
    _samples.addAll(samples);
    _controller.add(List.unmodifiable(_samples));
    return samples;
  }

  @override
  Future<HistoryManualEditResult> applyManualEdits({
    required List<LatLngSample> insertSamples,
    required Set<String> deleteBaseCellIds,
  }) async {
    _samples.addAll(insertSamples);
    _controller.add(List.unmodifiable(_samples));
    return HistoryManualEditResult(
      insertedSamples: insertSamples,
      deletedSamples: deleteBaseCellIds.length,
    );
  }

  @override
  Future<HistoryExportResult> exportHistory() async {
    return exportResult;
  }

  @override
  Future<HistoryExportResult> downloadHistory() async {
    return downloadResult;
  }
}

class FakePermissionsRepository implements PermissionsRepository {
  @override
  Future<List<AppPermissionStatus>> fetchPermissions() async {
    return const [];
  }

  @override
  Future<void> openPermissionSettings(AppPermissionType type) async {}

  @override
  Future<void> requestInitialPermissionsIfNeeded() async {}

  @override
  Future<void> requestPermission(AppPermissionType type) async {}
}

class FakeGpxImportRepository implements GpxImportRepository {
  @override
  Future<GpxImportPreparation> prepareImport() async {
    return const GpxImportPreparation(outcome: GpxImportOutcome.cancelled);
  }

  @override
  Future<GpxImportResult> processFile(GpxSelectedFile file) async {
    return const GpxImportResult(outcome: GpxImportOutcome.cancelled);
  }
}

class FakeAppStateRepository implements AppStateRepository {
  FakeAppStateRepository(this.snapshot);

  AppStateSnapshot snapshot;

  @override
  AppStateSnapshot createInitialState() {
    return snapshot;
  }

  @override
  Future<List<RegionPackNode>> loadRootPacks() async {
    return snapshot.regionCatalog.rootNodes;
  }

  @override
  Future<List<RegionPackNode>> restoreSelectedPack() async {
    final selectedPack = snapshot.regionCatalog.maybeNodeById(
      snapshot.selectedPackId,
    );
    if (selectedPack == null) {
      return const <RegionPackNode>[];
    }
    return [
      ...snapshot.regionCatalog.ancestorsOf(selectedPack.id),
      selectedPack,
    ];
  }

  @override
  Future<List<RegionPackNode>> loadChildren(String parentId) async {
    return snapshot.regionCatalog.childrenOf(parentId);
  }

  @override
  Future<List<RegionPackNode>> loadDownloadedPacks() async {
    return snapshot.regions.where((region) => region.isDownloaded).toList();
  }

  @override
  Future<void> setSelectedPack(SelectedPackRef ref) async {
    snapshot = snapshot.copyWith(selectedPackId: ref.id, selectedPackRef: ref);
  }

  @override
  Future<void> setDownloadedPacks(List<SelectedPackRef> refs) async {
    final ids = refs.map((ref) => ref.id).toSet();
    snapshot = snapshot.copyWith(
      regions: snapshot.regions
          .map(
            (region) => region.copyWith(isDownloaded: ids.contains(region.id)),
          )
          .toList(growable: false),
      downloadedPackRefs: refs,
    );
  }

  @override
  Future<void> setHasSeenOnboarding(bool value) async {
    snapshot = snapshot.copyWith(hasSeenOnboarding: value);
  }

  @override
  Future<void> setPermissions(
    Map<TrackingPermissionType, PermissionGrantState> permissions,
  ) async {
    snapshot = snapshot.copyWith(permissions: permissions);
  }

  @override
  Future<void> setUserPoints(List<UserPoint> points) async {
    snapshot = snapshot.copyWith(userPoints: points);
  }

  @override
  Future<RegionBoundary> loadBoundary(String packId) async {
    final pack = snapshot.regionCatalog.nodeById(packId);
    final bounds = pack.bounds;
    return RegionBoundary(
      polygons: [
        RegionBoundaryPolygon(
          outerRing: [
            LatLng(bounds.north, bounds.west),
            LatLng(bounds.north, bounds.east),
            LatLng(bounds.south, bounds.east),
            LatLng(bounds.south, bounds.west),
          ],
        ),
      ],
    );
  }
}

MapRepository buildMapRepository() {
  return MapRepository(
    tileService: FakeMapTileService(),
    attributionService: FakeMapAttributionService(),
  );
}

AppStateSnapshot buildAppStateSnapshot({
  required List<legacy.Region> regions,
  required String currentRegionId,
}) {
  final packNodes = regions
      .map(
        (region) => RegionPackNode(
          id: region.id,
          kind: RegionPackKind.region,
          name: region.name,
          parentId: null,
          hasChildren: false,
          childIds: const <String>[],
          center: region.center,
          bounds: _boundsFromPoints(region.bounds),
          areaKm2: region.totalArea,
          isDownloaded: region.isDownloaded,
          geometryAssetPath: region.id,
          displayPath: region.name,
          features: RegionFeatures(
            trails: RegionFeatureProgress(
              total: region.features.trails.total,
              completed: region.features.trails.completed,
            ),
            peaks: RegionFeatureProgress(
              total: region.features.peaks.total,
              completed: region.features.peaks.completed,
            ),
            huts: RegionFeatureProgress(
              total: region.features.huts.total,
              completed: region.features.huts.completed,
            ),
          ),
        ),
      )
      .toList(growable: false);

  return AppStateSnapshot(
    hasSeenOnboarding: true,
    permissions: const {},
    isTracking: true,
    gpsQuality: GpsQuality.good,
    regionCatalog: RegionCatalog(
      rootIds: packNodes.map((pack) => pack.id).toList(growable: false),
      nodesById: {for (final pack in packNodes) pack.id: pack},
    ),
    selectedPackId: currentRegionId,
    selectedPackRef: null,
    userPoints: const [],
  );
}

AppStateSnapshot buildPackAppStateSnapshot({
  required List<RegionPackNode> packs,
  required String selectedPackId,
}) {
  return AppStateSnapshot(
    hasSeenOnboarding: true,
    permissions: const {},
    isTracking: true,
    gpsQuality: GpsQuality.good,
    regionCatalog: RegionCatalog(
      rootIds: [
        for (final pack in packs)
          if (pack.parentId == null ||
              !packs.any((candidate) => candidate.id == pack.parentId))
            pack.id,
      ],
      nodesById: {for (final pack in packs) pack.id: pack},
    ),
    selectedPackId: selectedPackId,
    selectedPackRef: null,
    userPoints: const [],
  );
}

RegionPackNode buildTestPackNode({
  required String id,
  required String name,
  RegionPackKind kind = RegionPackKind.region,
  String? parentId,
  List<String> childIds = const <String>[],
  bool? hasChildren,
  bool isDownloaded = false,
  LatLng center = const LatLng(0, 0),
  RegionPackBounds bounds = const RegionPackBounds(
    west: 0,
    south: 0,
    east: 1,
    north: 1,
  ),
  RegionFeatures features = RegionFeatures.empty,
  String? displayPath,
}) {
  return RegionPackNode(
    id: id,
    kind: kind,
    name: name,
    parentId: parentId,
    hasChildren: hasChildren ?? childIds.isNotEmpty,
    childIds: childIds,
    center: center,
    bounds: bounds,
    areaKm2: null,
    isDownloaded: isDownloaded,
    geometryAssetPath: id,
    displayPath: displayPath ?? name,
    features: features,
  );
}

RegionPackBounds _boundsFromPoints(List<LatLng> points) {
  var west = points.first.longitude;
  var south = points.first.latitude;
  var east = west;
  var north = south;

  for (final point in points.skip(1)) {
    if (point.longitude < west) {
      west = point.longitude;
    }
    if (point.longitude > east) {
      east = point.longitude;
    }
    if (point.latitude < south) {
      south = point.latitude;
    }
    if (point.latitude > north) {
      north = point.latitude;
    }
  }

  return RegionPackBounds(west: west, south: south, east: east, north: north);
}

LatLngSample buildSample({
  required double latitude,
  required double longitude,
  DateTime? timestamp,
  LatLngSampleSource source = LatLngSampleSource.live,
}) {
  return LatLngSample(
    latitude: latitude,
    longitude: longitude,
    timestamp: timestamp ?? DateTime(2024, 1, 1),
    source: source,
  );
}
