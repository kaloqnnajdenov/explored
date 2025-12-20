import 'dart:async';

import 'package:flutter/material.dart';

import '../../location/data/models/location_notification.dart';
import '../../location/data/models/location_permission_level.dart';
import '../../location/data/models/location_status.dart';
import '../../location/data/models/location_tracking_mode.dart';
import '../../location/data/models/location_update.dart';
import '../../location/data/repositories/location_repository.dart';
import '../data/models/map_config.dart';
import '../data/models/map_view_state.dart';
import '../data/repositories/map_repository.dart';

/// Owns map UI state and coordinates location tracking for the map screen.
class MapViewModel extends ChangeNotifier {
  /// Builds the ViewModel with injected dependencies and seeded config.
  factory MapViewModel({
    required MapRepository mapRepository,
    required LocationRepository locationRepository,
  }) {
    final config = mapRepository.getMapConfig();
    return MapViewModel._(
      mapRepository: mapRepository,
      locationRepository: locationRepository,
      config: config,
    );
  }

  MapViewModel._({
    required MapRepository mapRepository,
    required LocationRepository locationRepository,
    required MapConfig config,
  })  : _mapRepository = mapRepository,
        _locationRepository = locationRepository,
        _config = config,
        _state = MapViewState.initial(config);

  static const int _androidUpdateIntervalMs = 1000;
  static const Duration _permissionCheckInterval = Duration(seconds: 5);

  final MapRepository _mapRepository;
  final LocationRepository _locationRepository;
  final MapConfig _config;

  MapViewState _state;
  bool _hasInitialized = false;
  StreamSubscription<LocationUpdate>? _locationSubscription;
  Timer? _permissionWatchdog;
  bool _appInForeground = true;
  LocationNotification? _backgroundNotification;

  MapViewState get state => _state;

  /// Finalizes initial map state and loads the last known location snapshot.
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
    await _syncTrackingWithLifecycle(includeLastLocation: true);
  }

  /// Opens the map attribution link; errors are logged without altering state.
  Future<void> openAttribution() async {
    try {
      await _mapRepository.openAttribution();
    } catch (error) {
      debugPrint('Failed to open map attribution: $error');
    }
  }

  /// Stores the Android notification metadata used for background tracking.
  void setBackgroundNotification(LocationNotification notification) {
    _backgroundNotification = notification;
  }

  /// Requests foreground-only location permission from the OS.
  Future<void> requestForegroundPermission() async {
    await _requestPermission(() async {
      debugPrint('Requesting foreground location permission');
      return _locationRepository.requestForegroundPermission();
    });
  }

  /// Requests Always/Background location permission from the OS.
  Future<void> requestBackgroundPermission() async {
    await _requestPermission(() async {
      debugPrint('Requesting background location permission');
      return _locationRepository.requestBackgroundPermission();
    });
  }

  /// Requests notification permission on Android 13+ for background tracking.
  Future<void> requestNotificationPermission() async {
    if (_state.locationTracking.isActionInProgress) {
      return;
    }
    _updateLocationState(
      isActionInProgress: true,
      status: LocationStatus.requestingPermission,
    );
    debugPrint('Requesting notification permission');
    try {
      final notificationGranted =
          await _locationRepository.requestNotificationPermission();
      _updateLocationState(
        isNotificationPermissionGranted: notificationGranted,
        isActionInProgress: false,
      );
      await _syncTrackingWithLifecycle();
    } catch (error) {
      debugPrint('Failed to request notification permission: $error');
      _updateLocationState(
        status: LocationStatus.error,
        isActionInProgress: false,
      );
    }
  }

  /// Opens the platform settings screen for the app.
  Future<void> openAppSettings() async {
    final opened = await _locationRepository.openAppSettings();
    debugPrint('Open app settings requested: $opened');
  }

  /// Reacts to app lifecycle transitions to keep tracking in sync.
  void handleAppLifecycleState(AppLifecycleState state) {
    debugPrint('App lifecycle state changed: $state');
    if (state == AppLifecycleState.resumed) {
      _appInForeground = true;
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _appInForeground = false;
    }
    unawaited(_syncTrackingWithLifecycle());
  }

  @override
  void dispose() {
    _permissionWatchdog?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _attachLocationUpdates() {
    if (_locationSubscription != null) {
      return;
    }

    _locationSubscription = _locationRepository.locationUpdates.listen(
      (location) {
        final modeLabel = _trackingModeLabel(
          _state.locationTracking.trackingMode,
        );
        debugPrint(
          'Location update ($modeLabel): ${location.latitude}, '
          '${location.longitude} accuracy=${location.accuracy}',
        );
        _updateLocationState(lastLocation: location);
      },
      onError: (error) {
        debugPrint('Location update error: $error');
        _updateLocationState(status: LocationStatus.error);
      },
    );
  }

  Future<void> _syncTrackingWithLifecycle({
    bool includeLastLocation = false,
  }) async {
    if (_state.locationTracking.isActionInProgress) {
      return;
    }
    try {
      final permissionLevel = await _locationRepository.checkPermissionLevel();
      final serviceEnabled = await _locationRepository.isLocationServiceEnabled();
      final notificationGranted =
          await _locationRepository.isNotificationPermissionGranted();
      final lastLocation = includeLastLocation
          ? await _locationRepository.loadLastLocation()
          : null;

      _updateLocationState(
        permissionLevel: permissionLevel,
        isServiceEnabled: serviceEnabled,
        isNotificationPermissionGranted: notificationGranted,
        lastLocation: lastLocation,
      );
      debugPrint(
        'Permission=$permissionLevel serviceEnabled=$serviceEnabled '
        'notificationGranted=$notificationGranted',
      );

      final desiredMode = _desiredTrackingMode(
        permissionLevel: permissionLevel,
        serviceEnabled: serviceEnabled,
        notificationGranted: notificationGranted,
      );

      if (desiredMode == _state.locationTracking.trackingMode &&
          desiredMode != LocationTrackingMode.none) {
        return;
      }

      if (desiredMode == LocationTrackingMode.foreground) {
        await _startForegroundTrackingInternal();
        return;
      }

      if (desiredMode == LocationTrackingMode.background) {
        if (_backgroundNotification == null) {
          debugPrint(
            'Background notification not configured; cannot start tracking.',
          );
          await _stopTrackingInternal(LocationStatus.error);
          return;
        }
        await _startBackgroundTrackingInternal(_backgroundNotification!);
        return;
      }

      final status = _statusForNoTracking(
        permissionLevel: permissionLevel,
        serviceEnabled: serviceEnabled,
        notificationGranted: notificationGranted,
      );
      if (_state.locationTracking.isTracking) {
        await _stopTrackingInternal(status);
      } else {
        _updateLocationState(status: status);
      }
    } catch (error) {
      debugPrint('Failed to sync location tracking: $error');
    }
  }

  void _startPermissionWatchdog() {
    _permissionWatchdog?.cancel();
    _permissionWatchdog =
        Timer.periodic(_permissionCheckInterval, (timer) {
      unawaited(_syncTrackingWithLifecycle());
    });
  }

  void _updateLocationState({
    LocationPermissionLevel? permissionLevel,
    LocationTrackingMode? trackingMode,
    LocationStatus? status,
    bool? isActionInProgress,
    bool? isServiceEnabled,
    bool? isNotificationPermissionGranted,
    LocationUpdate? lastLocation,
  }) {
    _state = _state.copyWith(
      locationTracking: _state.locationTracking.copyWith(
        permissionLevel: permissionLevel,
        trackingMode: trackingMode,
        status: status,
        isActionInProgress: isActionInProgress,
        isServiceEnabled: isServiceEnabled,
        isNotificationPermissionGranted: isNotificationPermissionGranted,
        lastLocation: lastLocation,
      ),
    );
    notifyListeners();
  }

  Future<void> _stopTrackingInternal(LocationStatus status) async {
    if (_state.locationTracking.isActionInProgress) {
      return;
    }

    _updateLocationState(isActionInProgress: true);

    try {
      await _locationRepository.stopTracking();
    } catch (error) {
      debugPrint('Failed to stop tracking: $error');
    }

    await _locationSubscription?.cancel();
    _locationSubscription = null;
    _permissionWatchdog?.cancel();

    _updateLocationState(
      trackingMode: LocationTrackingMode.none,
      status: status,
      isActionInProgress: false,
    );
  }

  Future<void> _requestPermission(
    Future<LocationPermissionLevel> Function() request,
  ) async {
    if (_state.locationTracking.isActionInProgress) {
      return;
    }
    _updateLocationState(
      isActionInProgress: true,
      status: LocationStatus.requestingPermission,
    );
    try {
      final permissionLevel = await request();
      _updateLocationState(
        permissionLevel: permissionLevel,
        isActionInProgress: false,
      );
      await _syncTrackingWithLifecycle();
    } catch (error) {
      debugPrint('Failed to request permission: $error');
      _updateLocationState(
        status: LocationStatus.error,
        isActionInProgress: false,
      );
    }
  }

  Future<void> _startForegroundTrackingInternal() async {
    if (_state.locationTracking.isActionInProgress) {
      return;
    }
    _updateLocationState(isActionInProgress: true);
    try {
      await _locationRepository.startForegroundTracking();
      _attachLocationUpdates();
      _startPermissionWatchdog();
      _updateLocationState(
        trackingMode: LocationTrackingMode.foreground,
        status: LocationStatus.trackingStartedForeground,
        isActionInProgress: false,
      );
      debugPrint('Foreground tracking started');
    } catch (error) {
      debugPrint('Failed to start foreground tracking: $error');
      _updateLocationState(
        status: LocationStatus.error,
        isActionInProgress: false,
      );
    }
  }

  Future<void> _startBackgroundTrackingInternal(
    LocationNotification notification,
  ) async {
    if (_state.locationTracking.isActionInProgress) {
      return;
    }
    _updateLocationState(isActionInProgress: true);
    try {
      await _locationRepository.startBackgroundTracking(
        notification: notification,
        androidIntervalMs: _androidUpdateIntervalMs,
      );
      _attachLocationUpdates();
      _startPermissionWatchdog();
      _updateLocationState(
        trackingMode: LocationTrackingMode.background,
        status: LocationStatus.trackingStartedBackground,
        isActionInProgress: false,
      );
      debugPrint(
        'Background tracking started; battery optimizations may affect updates.',
      );
    } catch (error) {
      debugPrint('Failed to start background tracking: $error');
      _updateLocationState(
        status: LocationStatus.error,
        isActionInProgress: false,
      );
    }
  }

  bool _isForegroundPermissionAllowed(LocationPermissionLevel level) {
    return level == LocationPermissionLevel.foreground ||
        level == LocationPermissionLevel.background;
  }

  bool _isBackgroundPermissionAllowed(LocationPermissionLevel level) {
    return level == LocationPermissionLevel.background;
  }

  LocationStatus _statusForPermissionFailure(LocationPermissionLevel level) {
    switch (level) {
      case LocationPermissionLevel.deniedForever:
        return LocationStatus.permissionDeniedForever;
      case LocationPermissionLevel.restricted:
        return LocationStatus.permissionRestricted;
      case LocationPermissionLevel.denied:
      case LocationPermissionLevel.unknown:
      case LocationPermissionLevel.foreground:
      case LocationPermissionLevel.background:
        return LocationStatus.permissionDenied;
    }
  }

  LocationStatus _statusForBackgroundPermissionFailure(
    LocationPermissionLevel level,
  ) {
    if (level == LocationPermissionLevel.foreground) {
      return LocationStatus.backgroundPermissionDenied;
    }
    return _statusForPermissionFailure(level);
  }

  LocationTrackingMode _desiredTrackingMode({
    required LocationPermissionLevel permissionLevel,
    required bool serviceEnabled,
    required bool notificationGranted,
  }) {
    if (!serviceEnabled) {
      return LocationTrackingMode.none;
    }
    if (_appInForeground) {
      return _isForegroundPermissionAllowed(permissionLevel)
          ? LocationTrackingMode.foreground
          : LocationTrackingMode.none;
    }
    if (!_isBackgroundPermissionAllowed(permissionLevel)) {
      return LocationTrackingMode.none;
    }
    if (!notificationGranted) {
      return LocationTrackingMode.none;
    }
    return LocationTrackingMode.background;
  }

  LocationStatus _statusForNoTracking({
    required LocationPermissionLevel permissionLevel,
    required bool serviceEnabled,
    required bool notificationGranted,
  }) {
    if (!serviceEnabled) {
      return LocationStatus.locationServicesDisabled;
    }
    if (_appInForeground) {
      return _statusForPermissionFailure(permissionLevel);
    }
    if (!_isBackgroundPermissionAllowed(permissionLevel)) {
      return _statusForBackgroundPermissionFailure(permissionLevel);
    }
    if (!notificationGranted) {
      return LocationStatus.notificationPermissionDenied;
    }
    return LocationStatus.trackingStopped;
  }

  String _trackingModeLabel(LocationTrackingMode mode) {
    switch (mode) {
      case LocationTrackingMode.none:
        return 'none';
      case LocationTrackingMode.foreground:
        return 'foreground';
      case LocationTrackingMode.background:
        return 'background';
    }
  }
}
