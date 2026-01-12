import 'dart:async';

import 'package:flutter/material.dart';

import '../../location/data/models/location_permission_level.dart';
import '../../location/data/models/location_status.dart';
import '../../location/data/models/location_tracking_mode.dart';
import '../../location/data/models/lat_lng_sample.dart';
import '../../location/data/repositories/location_updates_repository.dart';
import '../data/models/map_config.dart';
import '../data/models/map_view_state.dart';
import '../data/repositories/map_repository.dart';

/// Owns map UI state and listens to location updates for the map screen.
class MapViewModel extends ChangeNotifier {
  /// Builds the ViewModel with injected dependencies and seeded config.
  factory MapViewModel({
    required MapRepository mapRepository,
    required LocationUpdatesRepository locationUpdatesRepository,
  }) {
    final config = mapRepository.getMapConfig();
    return MapViewModel._(
      mapRepository: mapRepository,
      locationUpdatesRepository: locationUpdatesRepository,
      config: config,
    );
  }

  MapViewModel._({
    required MapRepository mapRepository,
    required LocationUpdatesRepository locationUpdatesRepository,
    required MapConfig config,
  })  : _mapRepository = mapRepository,
        _locationUpdatesRepository = locationUpdatesRepository,
        _config = config,
        _state = MapViewState.initial(config);

  final MapRepository _mapRepository;
  final LocationUpdatesRepository _locationUpdatesRepository;
  final MapConfig _config;

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
    await _refreshTrackingState();
    _attachLocationUpdates();
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
