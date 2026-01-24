import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../location/data/models/location_permission_level.dart';
import '../../location/data/models/location_status.dart';
import '../../location/data/models/location_tracking_mode.dart';
import '../../location/data/models/lat_lng_sample.dart';
import '../../location/data/repositories/location_updates_repository.dart';
import '../../location/data/repositories/location_history_repository.dart';
import '../../location/data/models/history_export_result.dart';
import '../../permissions/data/repositories/permissions_repository.dart';
import '../../visited_grid/data/repositories/visited_grid_repository.dart';
import '../data/models/map_config.dart';
import '../data/models/map_view_state.dart';
import '../data/models/overlay_tile_size.dart';
import '../data/repositories/map_repository.dart';
import '../../visited_grid/view_model/fog_of_war_overlay_controller.dart';

/// Owns map UI state and listens to location updates for the map screen.
class MapViewModel extends ChangeNotifier {
  /// Builds the ViewModel with injected dependencies and seeded config.
  factory MapViewModel({
    required MapRepository mapRepository,
    required LocationUpdatesRepository locationUpdatesRepository,
    required LocationHistoryRepository locationHistoryRepository,
    required PermissionsRepository permissionsRepository,
    required VisitedGridRepository visitedGridRepository,
    required FogOfWarOverlayController overlayController,
  }) {
    final config = mapRepository.getMapConfig();
    return MapViewModel._(
      mapRepository: mapRepository,
      locationUpdatesRepository: locationUpdatesRepository,
      locationHistoryRepository: locationHistoryRepository,
      permissionsRepository: permissionsRepository,
      visitedGridRepository: visitedGridRepository,
      overlayController: overlayController,
      config: config,
    );
  }

  MapViewModel._({
    required MapRepository mapRepository,
    required LocationUpdatesRepository locationUpdatesRepository,
    required LocationHistoryRepository locationHistoryRepository,
    required PermissionsRepository permissionsRepository,
    required VisitedGridRepository visitedGridRepository,
    required FogOfWarOverlayController overlayController,
    required MapConfig config,
  })  : _mapRepository = mapRepository,
        _locationUpdatesRepository = locationUpdatesRepository,
        _locationHistoryRepository = locationHistoryRepository,
        _permissionsRepository = permissionsRepository,
        _visitedGridRepository = visitedGridRepository,
        _overlayController = overlayController,
        _config = config,
        _state = MapViewState.initial(config);

  final MapRepository _mapRepository;
  final LocationUpdatesRepository _locationUpdatesRepository;
  final LocationHistoryRepository _locationHistoryRepository;
  final PermissionsRepository _permissionsRepository;
  final VisitedGridRepository _visitedGridRepository;
  final FogOfWarOverlayController _overlayController;
  final MapConfig _config;
  MapViewState _state;
  bool _hasInitialized = false;
  StreamSubscription<LatLngSample>? _locationSubscription;
  StreamSubscription<List<LatLngSample>>? _historySubscription;
  int _exportFeedbackId = 0;
  bool _isExporting = false;
  bool _isDownloading = false;

  MapViewState get state => _state;
  TileProvider get overlayTileProvider => _overlayController.tileProvider;
  Stream<void> get overlayResetStream => _overlayController.resetStream;

  /// Finalizes initial map state and attaches the location stream.
  Future<void> initialize() async {
    if (_hasInitialized) {
      return;
    }

    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final overlayTileSize = await _mapRepository.fetchOverlayTileSize();
      await _overlayController.setTileSize(overlayTileSize.size);
      _state = _state.copyWith(
        center: _config.initialCenter,
        zoom: _config.initialZoom,
        tileSource: _config.tileSource,
        overlayTileSize: overlayTileSize,
        isLoading: false,
        clearError: true,
      );
      _hasInitialized = true;
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        error: error,
        clearError: false,
      );
    }

    notifyListeners();
    await _requestInitialPermissions();
    await _locationUpdatesRepository.startTracking();
    await _refreshTrackingState();
    _attachLocationUpdates();
    await _locationHistoryRepository.start();
    _attachHistoryUpdates();
    await _visitedGridRepository.start();
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

  /// Opens the map attribution link; errors are logged without altering state.
  Future<void> openAttribution() async {
    try {
      await _mapRepository.openAttribution();
    } catch (error) {
      debugPrint('Failed to open map attribution: $error');
    }
  }

  /// Updates the map overlay visibility based on user interaction.
  void setLocationPanelVisibility(bool visible) {
    if (_state.isLocationPanelVisible == visible) {
      return;
    }
    _state = _state.copyWith(isLocationPanelVisible: visible);
    notifyListeners();
  }

  /// Convenience helper used by the view to toggle the tracking panel.
  void toggleLocationPanelVisibility() {
    setLocationPanelVisibility(!_state.isLocationPanelVisible);
  }

  /// Updates the zoom level to use when recentering the map.
  void setRecenterZoom(double zoom) {
    if (_state.recenterZoom == zoom) {
      return;
    }
    _state = _state.copyWith(recenterZoom: zoom);
    notifyListeners();
  }

  Future<void> setOverlayTileSize(OverlayTileSize size) async {
    if (_state.overlayTileSize == size) {
      return;
    }
    _state = _state.copyWith(overlayTileSize: size);
    notifyListeners();
    try {
      await _mapRepository.setOverlayTileSize(size);
      await _overlayController.setTileSize(size.size);
    } catch (error) {
      debugPrint('Failed to update overlay tile size: $error');
    }
  }

  /// Exports the full location history as CSV and triggers native sharing.
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

  /// Saves the full location history CSV to device storage.
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
    _visitedGridRepository.dispose();
    unawaited(_overlayController.dispose());
    super.dispose();
  }

  void _attachLocationUpdates() {
    if (_locationSubscription != null) {
      return;
    }

    _locationSubscription = _locationUpdatesRepository.locationUpdates.listen(
      (location) {
        _updateLocationFromStream(location);
      },
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
    final importedSamples = [
      for (final sample in samples)
        if (sample.source == LatLngSampleSource.imported) sample,
    ];

    _state = _state.copyWith(importedSamples: importedSamples);
    notifyListeners();
  }

  void _emitHistoryFeedback(
    String messageKey, {
    bool isError = false,
  }) {
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

  Future<void> _performPermissionAction(
    Future<void> Function() action,
  ) async {
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
      final isServiceEnabled =
          await _locationUpdatesRepository.isLocationServiceEnabled();
      final permissionLevel =
          await _locationUpdatesRepository.checkPermissionLevel();
      final notificationRequired =
          _locationUpdatesRepository.isNotificationPermissionRequired;
      final notificationGranted =
          await _locationUpdatesRepository.isNotificationPermissionGranted();

      final status = _resolveStatus(
        isServiceEnabled: isServiceEnabled,
        permissionLevel: permissionLevel,
        notificationRequired: notificationRequired,
        notificationGranted: notificationGranted,
      );

      final trackingMode = _locationUpdatesRepository.isRunning
          ? LocationTrackingMode.background
          : LocationTrackingMode.none;

      _updateLocationState(
        permissionLevel: permissionLevel,
        isServiceEnabled: isServiceEnabled,
        isNotificationPermissionGranted: notificationGranted,
        status: status,
        trackingMode: trackingMode,
        isActionInProgress: false,
      );
    } catch (error) {
      debugPrint('Failed to refresh tracking state: $error');
      _updateLocationState(
        status: LocationStatus.error,
        isActionInProgress: false,
      );
    }
  }

  LocationStatus _resolveStatus({
    required bool isServiceEnabled,
    required LocationPermissionLevel permissionLevel,
    required bool notificationRequired,
    required bool notificationGranted,
  }) {
    if (!isServiceEnabled) {
      return LocationStatus.locationServicesDisabled;
    }

    if (permissionLevel == LocationPermissionLevel.deniedForever) {
      return LocationStatus.permissionDeniedForever;
    }

    if (permissionLevel == LocationPermissionLevel.restricted) {
      return LocationStatus.permissionRestricted;
    }

    if (_locationUpdatesRepository.requiresBackgroundPermission) {
      if (permissionLevel != LocationPermissionLevel.background) {
        return LocationStatus.backgroundPermissionDenied;
      }
    } else if (permissionLevel == LocationPermissionLevel.denied ||
        permissionLevel == LocationPermissionLevel.unknown) {
      return LocationStatus.permissionDenied;
    }

    if (notificationRequired && !notificationGranted) {
      return LocationStatus.notificationPermissionDenied;
    }

    if (_locationUpdatesRepository.isRunning) {
      return LocationStatus.trackingStartedBackground;
    }

    return LocationStatus.idle;
  }
}
