import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/usecases/h3_overlay_worker.dart';
import '../../location/data/models/location_permission_level.dart';
import '../../location/data/models/location_status.dart';
import '../../location/data/models/location_tracking_mode.dart';
import '../../location/data/models/lat_lng_sample.dart';
import '../../location/data/repositories/location_updates_repository.dart';
import '../../visited_grid/data/models/visited_grid_bounds.dart';
import '../../visited_grid/data/models/visited_overlay_mode.dart';
import '../../visited_grid/data/models/visited_time_filter.dart';
import '../../visited_grid/data/repositories/visited_grid_repository.dart';
import '../../visited_grid/view_model/h3_boundary_cache.dart';
import '../../visited_grid/view_model/visited_overlay_controller.dart';
import '../data/models/map_config.dart';
import '../data/models/map_view_state.dart';
import '../data/repositories/map_repository.dart';

/// Owns map UI state and listens to location updates for the map screen.
class MapViewModel extends ChangeNotifier {
  /// Builds the ViewModel with injected dependencies and seeded config.
  factory MapViewModel({
    required MapRepository mapRepository,
    required LocationUpdatesRepository locationUpdatesRepository,
    required VisitedGridRepository visitedGridRepository,
    required VisitedOverlayWorker overlayWorker,
    required CellBoundaryResolver boundaryResolver,
    H3BoundaryCache? boundaryCache,
    Duration overlayDebounce = const Duration(milliseconds: 200),
    DateTime Function()? nowProvider,
  }) {
    final config = mapRepository.getMapConfig();
    return MapViewModel._(
      mapRepository: mapRepository,
      locationUpdatesRepository: locationUpdatesRepository,
      visitedGridRepository: visitedGridRepository,
      overlayWorker: overlayWorker,
      boundaryResolver: boundaryResolver,
      boundaryCache: boundaryCache ?? H3BoundaryCache(),
      overlayDebounce: overlayDebounce,
      config: config,
      nowProvider: nowProvider,
    );
  }

  MapViewModel._({
    required MapRepository mapRepository,
    required LocationUpdatesRepository locationUpdatesRepository,
    required VisitedGridRepository visitedGridRepository,
    required VisitedOverlayWorker overlayWorker,
    required CellBoundaryResolver boundaryResolver,
    required H3BoundaryCache boundaryCache,
    required Duration overlayDebounce,
    required MapConfig config,
    DateTime Function()? nowProvider,
  })  : _mapRepository = mapRepository,
        _locationUpdatesRepository = locationUpdatesRepository,
        _visitedGridRepository = visitedGridRepository,
        _config = config,
        _now = nowProvider ?? DateTime.now,
        _state = MapViewState.initial(config) {
    _overlayController = VisitedOverlayController(
      worker: overlayWorker,
      boundaryResolver: boundaryResolver,
      boundaryCache: boundaryCache,
      debounceDuration: overlayDebounce,
      initialMode: _overlayModeForFilter(_state.visitedTimeFilter),
      onOverlayUpdated: _handleOverlayUpdate,
      onOverlayError: _handleOverlayError,
      onLoadingChanged: _handleOverlayLoadingChanged,
    );
  }

  final MapRepository _mapRepository;
  final LocationUpdatesRepository _locationUpdatesRepository;
  final VisitedGridRepository _visitedGridRepository;
  final MapConfig _config;
  final DateTime Function() _now;
  late final VisitedOverlayController _overlayController;

  MapViewState _state;
  bool _hasInitialized = false;
  StreamSubscription<LatLngSample>? _locationSubscription;

  MapViewState get state => _state;

  /// Finalizes initial map state and attaches the location stream.
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
      _state = _state.copyWith(
        isLoading: false,
        error: error,
        clearError: false,
      );
    }

    notifyListeners();
    _overlayController.setMode(_overlayModeForFilter(_state.visitedTimeFilter));
    await _refreshTrackingState();
    _attachLocationUpdates();
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

  @override
  void dispose() {
    _locationSubscription?.cancel();
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

  void onCameraChanged({
    required VisitedGridBounds bounds,
    required double zoom,
  }) {
    _overlayController.onCameraChanged(
      CameraState(bounds: bounds, zoom: zoom),
    );
  }

  void onCameraIdle({
    required VisitedGridBounds bounds,
    required double zoom,
  }) {
    _overlayController.onCameraIdle(
      CameraState(bounds: bounds, zoom: zoom),
    );
  }

  void patchVisitedCell({
    required String cellId,
    required int resolution,
  }) {
    _overlayController.patchVisitedCell(
      cellId: cellId,
      resolution: resolution,
    );
  }

  void setVisitedTimeFilter(VisitedTimeFilter filter) {
    if (_state.visitedTimeFilter == filter) {
      return;
    }

    _state = _state.copyWith(visitedTimeFilter: filter);
    notifyListeners();
    _overlayController.setMode(_overlayModeForFilter(filter));
  }

  void _handleOverlayUpdate(VisitedOverlayUpdate update) {
    _state = _state.copyWith(
      visitedOverlayPolygons: update.polygons,
      overlayResolution: update.resolution,
      clearOverlayError: true,
    );
    notifyListeners();
  }

  void _handleOverlayError(Object error) {
    _state = _state.copyWith(
      isOverlayLoading: false,
      overlayError: error,
      clearOverlayError: false,
    );
    notifyListeners();
  }

  void _handleOverlayLoadingChanged(bool isLoading) {
    if (_state.isOverlayLoading == isLoading) {
      return;
    }
    _state = _state.copyWith(
      isOverlayLoading: isLoading,
      clearOverlayError: isLoading,
    );
    notifyListeners();
  }

  OverlayMode _overlayModeForFilter(VisitedTimeFilter filter) {
    if (filter == VisitedTimeFilter.allTime) {
      return const OverlayModeAllTime();
    }

    final now = _now().toLocal();
    final endDay = _dayKey(now);
    final window = filter.dayWindow ?? 0;
    final startDay = _dayKey(now.subtract(Duration(days: window)));
    return OverlayMode.dateRange(fromDay: startDay, toDay: endDay);
  }

  int _dayKey(DateTime timestamp) {
    final local = timestamp.toLocal();
    return local.year * 10000 + local.month * 100 + local.day;
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
