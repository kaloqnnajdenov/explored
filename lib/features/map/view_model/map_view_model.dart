import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/entities/entity.dart';
import '../../../domain/objects/explorable_object.dart';
import '../../../domain/objects/object_category.dart';
import '../../../domain/objects/road_metric.dart';
import '../../../domain/objects/road_segment.dart';
import '../../../domain/shared/entity_boundary.dart';
import '../../exploration/data/repositories/entity_repository.dart';
import '../../exploration/data/repositories/object_repository.dart';
import '../../exploration/data/repositories/selection_repository.dart';
import '../../exploration/data/services/geojson_boundary_parser.dart';
import '../../location/data/models/history_export_result.dart';
import '../../location/data/models/lat_lng_sample.dart';
import '../../location/data/models/location_permission_level.dart';
import '../../location/data/models/location_status.dart';
import '../../location/data/models/location_tracking_mode.dart';
import '../../location/data/repositories/location_history_repository.dart';
import '../../location/data/repositories/location_updates_repository.dart';
import '../../permissions/data/repositories/permissions_repository.dart';
import '../data/models/map_config.dart';
import '../data/models/map_point_of_interest.dart';
import '../data/models/map_view_state.dart';
import '../data/repositories/map_repository.dart';

class MapViewModel extends ChangeNotifier {
  factory MapViewModel({
    required MapRepository mapRepository,
    required LocationUpdatesRepository locationUpdatesRepository,
    required LocationHistoryRepository locationHistoryRepository,
    required PermissionsRepository permissionsRepository,
    EntityRepository? entityRepository,
    ObjectRepository? objectRepository,
    SelectionRepository? selectionRepository,
    GeoJsonBoundaryParser? boundaryParser,
  }) {
    final config = mapRepository.getMapConfig();
    return MapViewModel._(
      mapRepository: mapRepository,
      locationUpdatesRepository: locationUpdatesRepository,
      locationHistoryRepository: locationHistoryRepository,
      permissionsRepository: permissionsRepository,
      entityRepository: entityRepository ?? _EmptyEntityRepository(),
      objectRepository: objectRepository ?? _EmptyObjectRepository(),
      selectionRepository: selectionRepository ?? _EmptySelectionRepository(),
      boundaryParser: boundaryParser ?? const GeoJsonBoundaryParser(),
      config: config,
    );
  }

  MapViewModel._({
    required MapRepository mapRepository,
    required LocationUpdatesRepository locationUpdatesRepository,
    required LocationHistoryRepository locationHistoryRepository,
    required PermissionsRepository permissionsRepository,
    required EntityRepository entityRepository,
    required ObjectRepository objectRepository,
    required SelectionRepository selectionRepository,
    required GeoJsonBoundaryParser boundaryParser,
    required MapConfig config,
  }) : _mapRepository = mapRepository,
       _locationUpdatesRepository = locationUpdatesRepository,
       _locationHistoryRepository = locationHistoryRepository,
       _permissionsRepository = permissionsRepository,
       _entityRepository = entityRepository,
       _objectRepository = objectRepository,
       _selectionRepository = selectionRepository,
       _boundaryParser = boundaryParser,
       _config = config,
       _state = MapViewState.initial(config);

  final MapRepository _mapRepository;
  final LocationUpdatesRepository _locationUpdatesRepository;
  final LocationHistoryRepository _locationHistoryRepository;
  final PermissionsRepository _permissionsRepository;
  final EntityRepository _entityRepository;
  final ObjectRepository _objectRepository;
  final SelectionRepository _selectionRepository;
  final GeoJsonBoundaryParser _boundaryParser;
  final MapConfig _config;

  MapViewState _state;
  bool _hasInitialized = false;
  StreamSubscription<LatLngSample>? _locationSubscription;
  StreamSubscription<List<LatLngSample>>? _historySubscription;
  int _exportFeedbackId = 0;
  bool _isExporting = false;
  bool _isDownloading = false;
  int _selectedEntityRequestId = 0;

  MapViewState get state => _state;

  Future<void> initialize() async {
    if (_hasInitialized) {
      return;
    }

    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      _state = _state.copyWith(
        center: _config.initialCenter,
        zoom: _config.initialZoom,
        tileSource: _config.tileSource,
        isLoading: false,
        clearError: true,
      );
      _hasInitialized = true;
    } catch (error) {
      _state = _state.copyWith(isLoading: false, error: error);
    }

    notifyListeners();
    await _requestInitialPermissions();
    await _locationUpdatesRepository.startTracking();
    await _refreshTrackingState();
    _attachLocationUpdates();
    await _locationHistoryRepository.start();
    _attachHistoryUpdates();
    await refreshSelectedEntity();
  }

  Future<void> refreshSelectedEntity() async {
    final requestId = ++_selectedEntityRequestId;
    final selected = await _selectionRepository.getSelectedEntityResolved();
    if (requestId != _selectedEntityRequestId) {
      return;
    }

    if (selected == null) {
      _state = _state.copyWith(
        clearSelectedEntity: true,
        selectedBoundary: EntityBoundary.empty,
        selectedParentBoundary: EntityBoundary.empty,
        pointsOfInterest: const <MapPointOfInterest>[],
        pointMarkers: const [],
      );
      notifyListeners();
      return;
    }

    final boundary = _boundaryParser.parseString(selected.geometryGeoJson);
    var parentBoundary = EntityBoundary.empty;
    final parentId = selected.parentEntityId;
    if (parentId != null) {
      final parent = await _entityRepository.getEntity(parentId);
      if (parent != null) {
        parentBoundary = _boundaryParser.parseString(parent.geometryGeoJson);
      }
    }
    final pointsOfInterest = await _loadPointsOfInterest(selected.entityId);
    final pointMarkers = _mapRepository.buildPointOfInterestMarkers(
      pointsOfInterest: pointsOfInterest,
      zoom: _state.zoom,
    );
    if (requestId != _selectedEntityRequestId) {
      return;
    }

    _state = _state.copyWith(
      selectedEntity: selected,
      selectedBoundary: boundary,
      selectedParentBoundary: parentBoundary,
      center: selected.centroid,
      pointsOfInterest: pointsOfInterest,
      pointMarkers: pointMarkers,
    );
    notifyListeners();
  }

  Future<void> requestForegroundPermission() async {
    await _performPermissionAction(
      () async => _locationUpdatesRepository.requestForegroundPermission(),
    );
  }

  Future<void> requestBackgroundPermission() async {
    await _performPermissionAction(
      () async => _locationUpdatesRepository.requestBackgroundPermission(),
    );
  }

  Future<void> requestNotificationPermission() async {
    await _performPermissionAction(
      () async => _locationUpdatesRepository.requestNotificationPermission(),
    );
  }

  Future<void> openAppSettings() async {
    final shouldOpenNotifications =
        !_state.locationTracking.isNotificationPermissionGranted;
    await _performPermissionAction(
      () async => shouldOpenNotifications
          ? _locationUpdatesRepository.openNotificationSettings()
          : _locationUpdatesRepository.openAppSettings(),
    );
  }

  Future<void> openAttribution() async {
    try {
      await _mapRepository.openAttribution();
    } catch (error) {
      debugPrint('Failed to open map attribution: $error');
    }
  }

  void setLocationPanelVisibility(bool visible) {
    if (_state.isLocationPanelVisible == visible) {
      return;
    }
    _state = _state.copyWith(isLocationPanelVisible: visible);
    notifyListeners();
  }

  void toggleLocationPanelVisibility() {
    setLocationPanelVisibility(!_state.isLocationPanelVisible);
  }

  void setRecenterZoom(double zoom) {
    if (_state.recenterZoom == zoom) {
      return;
    }
    _state = _state.copyWith(recenterZoom: zoom);
    notifyListeners();
  }

  void updateVisibleZoom(double zoom) {
    if (!zoom.isFinite || (_state.zoom - zoom).abs() < 0.05) {
      return;
    }

    _state = _state.copyWith(
      zoom: zoom,
      pointMarkers: _mapRepository.buildPointOfInterestMarkers(
        pointsOfInterest: _state.pointsOfInterest,
        zoom: zoom,
      ),
    );
    notifyListeners();
  }

  Future<void> exportHistory() async {
    if (_isExporting) {
      return;
    }
    _isExporting = true;
    _state = _state.copyWith(clearExportFeedback: true);
    notifyListeners();

    final result = await _locationHistoryRepository.exportHistory();
    _isExporting = false;
    if (result.outcome == HistoryExportOutcome.success) {
      _emitHistoryFeedback('export_ready');
    } else {
      _emitHistoryFeedback('export_failed', isError: true);
    }
  }

  Future<void> downloadHistory() async {
    if (_isDownloading) {
      return;
    }
    _isDownloading = true;
    _state = _state.copyWith(clearExportFeedback: true);
    notifyListeners();

    final result = await _locationHistoryRepository.downloadHistory();
    _isDownloading = false;
    if (result.outcome == HistoryExportOutcome.success) {
      _emitHistoryFeedback('download_ready');
    } else {
      _emitHistoryFeedback('download_failed', isError: true);
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _historySubscription?.cancel();
    _locationHistoryRepository.dispose();
    super.dispose();
  }

  void _attachLocationUpdates() {
    if (_locationSubscription != null) {
      return;
    }

    _locationSubscription = _locationUpdatesRepository.locationUpdates.listen(
      _updateLocationFromStream,
      onError: (error) {
        debugPrint('Location update error: $error');
        _updateLocationState(status: LocationStatus.error);
      },
    );
  }

  void _attachHistoryUpdates() {
    if (_historySubscription != null) {
      return;
    }

    _historySubscription = _locationHistoryRepository.historyStream.listen(
      _handleHistoryUpdate,
      onError: (error) {
        debugPrint('Location history error: $error');
      },
    );
    _handleHistoryUpdate(_locationHistoryRepository.currentSamples);
  }

  void _handleHistoryUpdate(List<LatLngSample> samples) {
    if (identical(_state.persistedSamples, samples)) {
      return;
    }
    _state = _state.copyWith(persistedSamples: samples);
    notifyListeners();
  }

  void _emitHistoryFeedback(String messageKey, {bool isError = false}) {
    _exportFeedbackId += 1;
    _state = _state.copyWith(
      exportFeedback: MapViewFeedback(
        id: _exportFeedbackId,
        messageKey: messageKey,
        isError: isError,
      ),
    );
    notifyListeners();
  }

  void _updateLocationState({
    LocationTrackingMode? trackingMode,
    LocationStatus? status,
    LatLngSample? lastLocation,
    LocationPermissionLevel? permissionLevel,
    bool? isActionInProgress,
    bool? isServiceEnabled,
    bool? isNotificationPermissionGranted,
  }) {
    _state = _state.copyWith(
      locationTracking: _state.locationTracking.copyWith(
        trackingMode: trackingMode,
        status: status,
        lastLocation: lastLocation,
        permissionLevel: permissionLevel,
        isActionInProgress: isActionInProgress,
        isServiceEnabled: isServiceEnabled,
        isNotificationPermissionGranted: isNotificationPermissionGranted,
      ),
    );
    notifyListeners();
  }

  void _updateLocationFromStream(LatLngSample location) {
    _updateLocationState(
      trackingMode: LocationTrackingMode.background,
      status: LocationStatus.trackingStartedBackground,
      lastLocation: location,
    );
  }

  Future<void> _requestInitialPermissions() async {
    try {
      await _permissionsRepository.requestInitialPermissionsIfNeeded();
    } catch (error) {
      debugPrint('Failed to request initial permissions: $error');
    }
  }

  Future<void> _performPermissionAction(Future<void> Function() action) async {
    if (_state.locationTracking.isActionInProgress) {
      return;
    }

    _updateLocationState(
      isActionInProgress: true,
      status: LocationStatus.requestingPermission,
    );

    try {
      await action();
      await _locationUpdatesRepository.startTracking();
    } catch (error) {
      debugPrint('Permission request failed: $error');
    }

    await _refreshTrackingState();
  }

  Future<void> _refreshTrackingState() async {
    try {
      final isServiceEnabled = await _locationUpdatesRepository
          .isLocationServiceEnabled();
      final permissionLevel = await _locationUpdatesRepository
          .checkPermissionLevel();
      final notificationRequired =
          _locationUpdatesRepository.isNotificationPermissionRequired;
      final notificationGranted = await _locationUpdatesRepository
          .isNotificationPermissionGranted();
      final trackingMode = _locationUpdatesRepository.isRunning
          ? LocationTrackingMode.background
          : LocationTrackingMode.none;
      _updateLocationState(
        trackingMode: trackingMode,
        status: _resolveStatus(
          isServiceEnabled: isServiceEnabled,
          permissionLevel: permissionLevel,
          isNotificationRequired: notificationRequired,
          isNotificationGranted: notificationGranted,
        ),
        permissionLevel: permissionLevel,
        isActionInProgress: false,
        isServiceEnabled: isServiceEnabled,
        isNotificationPermissionGranted: notificationGranted,
      );
    } catch (error) {
      _updateLocationState(
        status: LocationStatus.error,
        isActionInProgress: false,
      );
      debugPrint('Failed to refresh tracking state: $error');
    }
  }

  LocationStatus _resolveStatus({
    required bool isServiceEnabled,
    required LocationPermissionLevel permissionLevel,
    required bool isNotificationRequired,
    required bool isNotificationGranted,
  }) {
    if (!isServiceEnabled) {
      return LocationStatus.locationServicesDisabled;
    }

    if (permissionLevel == LocationPermissionLevel.deniedForever) {
      return LocationStatus.permissionDeniedForever;
    }
    if (permissionLevel == LocationPermissionLevel.denied) {
      return LocationStatus.permissionDenied;
    }
    if (permissionLevel == LocationPermissionLevel.restricted) {
      return LocationStatus.permissionRestricted;
    }

    if (_locationUpdatesRepository.requiresBackgroundPermission) {
      if (permissionLevel != LocationPermissionLevel.background) {
        return LocationStatus.backgroundPermissionDenied;
      }
    }

    if (isNotificationRequired && !isNotificationGranted) {
      return LocationStatus.notificationPermissionDenied;
    }

    if (_locationUpdatesRepository.isRunning) {
      return LocationStatus.trackingStartedBackground;
    }

    return LocationStatus.idle;
  }

  Future<List<MapPointOfInterest>> _loadPointsOfInterest(
    String entityId,
  ) async {
    final objects = await _objectRepository.getObjectsForEntity(entityId);
    return objects
        .map(_toPointOfInterest)
        .whereType<MapPointOfInterest>()
        .toList(growable: false);
  }

  MapPointOfInterest? _toPointOfInterest(ExplorableObject object) {
    try {
      switch (object.category) {
        case ObjectCategory.peak:
        case ObjectCategory.hut:
        case ObjectCategory.monument:
          break;
        case ObjectCategory.roadSegment:
          return null;
      }

      final decoded = jsonDecode(object.geometryGeoJson);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      if (decoded['type'] != 'Point') {
        return null;
      }

      final coordinates = decoded['coordinates'];
      if (coordinates is! List || coordinates.length < 2) {
        return null;
      }
      final longitude = coordinates[0];
      final latitude = coordinates[1];
      if (longitude is! num || latitude is! num) {
        return null;
      }

      return MapPointOfInterest(
        id: object.objectId,
        category: object.category,
        position: LatLng(latitude.toDouble(), longitude.toDouble()),
        name: object.name,
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}

class _EmptyEntityRepository implements EntityRepository {
  @override
  Future<void> importCountryPack(String countrySlug) async {}

  @override
  Future<List<Entity>> getCountries() async {
    return const <Entity>[];
  }

  @override
  Future<Entity?> getEntity(String entityId) async {
    return null;
  }

  @override
  Future<List<Entity>> getChildren(String entityId) async {
    return const <Entity>[];
  }

  @override
  Future<List<Entity>> getCities({
    required String countryEntityId,
    String? regionEntityId,
  }) async {
    return const <Entity>[];
  }

  @override
  Future<List<Entity>> getCityCenters(String cityEntityId) async {
    return const <Entity>[];
  }

  @override
  Future<List<Entity>> getRegions(String countryEntityId) async {
    return const <Entity>[];
  }

  @override
  Future<List<Entity>> searchEntities(
    String query, {
    String? countryId,
    String? type,
  }) async {
    return const <Entity>[];
  }
}

class _EmptySelectionRepository implements SelectionRepository {
  @override
  Future<String?> getSelectedCountrySlug() async => null;

  @override
  Future<String?> getSelectedEntityId() async => null;

  @override
  Future<Entity?> getSelectedEntityResolved() async {
    return null;
  }

  @override
  Future<void> setSelectedEntityId(String entityId) async {}
}

class _EmptyObjectRepository implements ObjectRepository {
  @override
  Future<int> countObjectsForEntity(
    String entityId,
    ObjectCategory category,
  ) async {
    return 0;
  }

  @override
  Future<List<ExplorableObject>> getObjectsForEntity(
    String entityId, {
    ObjectCategory? category,
  }) async {
    return const <ExplorableObject>[];
  }

  @override
  Future<List<RoadSegment>> getRoadsForEntity(
    String entityId, {
    RoadMetric? metric,
  }) async {
    return const <RoadSegment>[];
  }

  @override
  Future<double> sumRoadLengthForEntity(
    String entityId,
    RoadMetric metric,
  ) async {
    return 0;
  }
}
