import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:explored/features/location/data/models/location_update.dart';
import 'package:explored/features/location/data/models/permission_status.dart';
import 'package:explored/features/location/data/models/tracking_state.dart';
import 'package:explored/features/location/data/repositories/location_tracking_repository.dart';
import 'package:explored/features/location/data/services/location_services_gateway.dart';
import 'package:explored/features/location/data/services/logger.dart';
import 'package:explored/features/location/data/services/permission_gateway.dart';
import 'package:explored/features/location/data/services/platform_info.dart';
import 'package:explored/features/location/view_model/tracking_controller.dart';
import 'package:explored/translations/locale_keys.g.dart';

/// Captures log entries for assertions in tracking tests.
class FakeLogger implements Logger {
  final List<LogEntry> entries = [];

  @override
  void log(String eventName, Map<String, dynamic> fields) {
    entries.add(LogEntry(eventName, fields));
  }

  LogEntry? entryFor(String eventName) {
    for (final entry in entries) {
      if (entry.eventName == eventName) {
        return entry;
      }
    }
    return null;
  }
}

/// Stores a single structured log event for assertions.
class LogEntry {
  const LogEntry(this.eventName, this.fields);

  final String eventName;
  final Map<String, dynamic> fields;
}

/// Simulates platform info for permission logic in tests.
class FakePlatformInfo implements PlatformInfo {
  FakePlatformInfo({
    required this.isAndroid,
    required this.isIOS,
    required this.androidSdkInt,
  });

  @override
  final bool isAndroid;

  @override
  final bool isIOS;

  @override
  final int? androidSdkInt;
}

/// Fakes permission responses for foreground/background location access.
class FakePermissionGateway implements PermissionGateway {
  FakePermissionGateway({
    required this.foregroundStatus,
    required this.backgroundStatus,
    this.permanentlyDenied = false,
  });

  PermissionStatus foregroundStatus;
  PermissionStatus backgroundStatus;
  bool permanentlyDenied;

  int foregroundRequestCount = 0;
  int backgroundRequestCount = 0;

  final List<PermissionStatus> _foregroundRequestQueue = [];
  final List<PermissionStatus> _backgroundRequestQueue = [];

  void queueForegroundRequestResult(PermissionStatus status) {
    _foregroundRequestQueue.add(status);
  }

  void queueBackgroundRequestResult(PermissionStatus status) {
    _backgroundRequestQueue.add(status);
  }

  @override
  Future<PermissionStatus> getForegroundStatus() async {
    return foregroundStatus;
  }

  @override
  Future<PermissionStatus> requestForeground() async {
    foregroundRequestCount += 1;
    if (_foregroundRequestQueue.isNotEmpty) {
      foregroundStatus = _foregroundRequestQueue.removeAt(0);
    }
    return foregroundStatus;
  }

  @override
  Future<PermissionStatus> getBackgroundStatus() async {
    return backgroundStatus;
  }

  @override
  Future<PermissionStatus> requestBackground() async {
    backgroundRequestCount += 1;
    if (_backgroundRequestQueue.isNotEmpty) {
      backgroundStatus = _backgroundRequestQueue.removeAt(0);
    }
    return backgroundStatus;
  }

  @override
  Future<bool> isPermanentlyDenied() async {
    return permanentlyDenied;
  }
}

/// Fakes location services, streams, and background service IO.
class FakeLocationServicesGateway implements LocationServicesGateway {
  FakeLocationServicesGateway({
    required this.servicesEnabled,
    required this.notificationsAllowed,
  }) {
    _controller = StreamController.broadcast(
      onListen: () => activeListeners += 1,
      onCancel: () => activeListeners = activeListeners > 0
          ? activeListeners - 1
          : activeListeners,
    );
  }

  final bool servicesEnabled;
  final bool notificationsAllowed;

  int startBackgroundServiceCalls = 0;
  int stopBackgroundServiceCalls = 0;
  int activeListeners = 0;
  int openAppSettingsCalls = 0;
  int openNotificationSettingsCalls = 0;

  late final StreamController<LocationUpdate> _controller;

  @override
  Future<bool> isLocationServicesEnabled() async {
    return servicesEnabled;
  }

  @override
  Stream<LocationUpdate> locationStream() {
    return _controller.stream;
  }

  @override
  Future<void> startBackgroundService() async {
    startBackgroundServiceCalls += 1;
  }

  @override
  Future<void> stopBackgroundService() async {
    stopBackgroundServiceCalls += 1;
  }

  @override
  Future<bool> canPostNotifications() async {
    return notificationsAllowed;
  }

  @override
  Future<void> openAppSettings() async {
    openAppSettingsCalls += 1;
  }

  @override
  Future<void> openNotificationSettings() async {
    openNotificationSettingsCalls += 1;
  }
}

void main() {
  group('TrackingController', () {
    test('Foreground permission not granted', () async {
      // Arrange: prepare denied foreground permission and tracking dependencies.
      final permissionGateway = FakePermissionGateway(
        foregroundStatus: PermissionStatus.denied,
        backgroundStatus: PermissionStatus.denied,
      )..queueForegroundRequestResult(PermissionStatus.denied);
      final locationGateway = FakeLocationServicesGateway(
        servicesEnabled: true,
        notificationsAllowed: true,
      );
      final logger = FakeLogger();
      final repository = LocationTrackingRepository(
        permissionGateway: permissionGateway,
        locationServicesGateway: locationGateway,
        platformInfo: FakePlatformInfo(
          isAndroid: true,
          isIOS: false,
          androidSdkInt: 33,
        ),
        logger: logger,
      );
      final controller = TrackingController(repository: repository);

      // Act: attempt to start foreground tracking.
      final result = await controller.startForegroundTracking();

      // Assert: permission was requested, tracking did not start, and state/logs updated.
      expect(permissionGateway.foregroundRequestCount, 1);
      expect(locationGateway.activeListeners, 0);
      expect(controller.currentState, TrackingState.permissionRequiredForeground);
      expect(result, TrackingStartResult.permissionDeniedForeground);
      expect(
        controller.uiState.statusKey,
        LocaleKeys.location_status_permission_denied,
      );
      expect(
        controller.uiState.actionKey,
        LocaleKeys.location_action_request_foreground,
      );
      expect(controller.uiState.isTracking, false);
      final logEntry = logger.entryFor('permission_foreground_denied');
      expect(logEntry, isNotNull);
      expect(logEntry!.fields['tracking_active'], false);
      expect(logEntry.fields['next_action'], 'show_permission_rationale');
    });

    test('Foreground granted, background not granted', () async {
      // Arrange: prepare granted foreground but denied background permission.
      final permissionGateway = FakePermissionGateway(
        foregroundStatus: PermissionStatus.granted,
        backgroundStatus: PermissionStatus.denied,
      )..queueBackgroundRequestResult(PermissionStatus.denied);
      final locationGateway = FakeLocationServicesGateway(
        servicesEnabled: true,
        notificationsAllowed: true,
      );
      final logger = FakeLogger();
      final repository = LocationTrackingRepository(
        permissionGateway: permissionGateway,
        locationServicesGateway: locationGateway,
        platformInfo: FakePlatformInfo(
          isAndroid: true,
          isIOS: false,
          androidSdkInt: 33,
        ),
        logger: logger,
      );
      final controller = TrackingController(repository: repository);

      // Act: attempt to start background tracking.
      final result = await controller.startBackgroundTracking();

      // Assert: background permission was requested and background tracking did not start.
      expect(permissionGateway.backgroundRequestCount, 1);
      expect(locationGateway.startBackgroundServiceCalls, 0);
      expect(locationGateway.activeListeners, 0);
      expect(controller.currentState, TrackingState.permissionRequiredBackground);
      expect(result, TrackingStartResult.permissionDeniedBackground);
      expect(
        controller.uiState.statusKey,
        LocaleKeys.location_status_background_permission_denied,
      );
      expect(
        controller.uiState.actionKey,
        LocaleKeys.location_action_request_background,
      );
      expect(controller.uiState.isTracking, false);
      final logEntry = logger.entryFor('permission_background_denied');
      expect(logEntry, isNotNull);
      expect(logEntry!.fields['foreground_permission'], 'granted');
      expect(logEntry.fields['tracking_active_background'], false);
    });

    test('iOS When In Use granted, Always denied', () async {
      // Arrange: configure iOS with foreground granted and background denied.
      final permissionGateway = FakePermissionGateway(
        foregroundStatus: PermissionStatus.granted,
        backgroundStatus: PermissionStatus.denied,
      )..queueBackgroundRequestResult(PermissionStatus.denied);
      final locationGateway = FakeLocationServicesGateway(
        servicesEnabled: true,
        notificationsAllowed: true,
      );
      final logger = FakeLogger();
      final repository = LocationTrackingRepository(
        permissionGateway: permissionGateway,
        locationServicesGateway: locationGateway,
        platformInfo: FakePlatformInfo(
          isAndroid: false,
          isIOS: true,
          androidSdkInt: null,
        ),
        logger: logger,
      );
      final controller = TrackingController(repository: repository);

      // Act: attempt to start background tracking on iOS.
      final result = await controller.startBackgroundTracking();

      // Assert: background tracking stays off and logs instruct settings.
      expect(locationGateway.startBackgroundServiceCalls, 0);
      expect(locationGateway.activeListeners, 0);
      expect(controller.currentState, TrackingState.permissionRequiredBackground);
      expect(result, TrackingStartResult.permissionDeniedBackground);
      expect(
        controller.uiState.actionKey,
        LocaleKeys.location_action_open_settings,
      );
      expect(controller.uiState.isTracking, false);
      final logEntry = logger.entryFor('permission_background_denied');
      expect(logEntry, isNotNull);
      expect(logEntry!.fields['next_action'], 'open_settings');
    });

    test('Denied forever / do not ask again', () async {
      // Arrange: configure permanently denied foreground permission.
      final permissionGateway = FakePermissionGateway(
        foregroundStatus: PermissionStatus.denied,
        backgroundStatus: PermissionStatus.denied,
        permanentlyDenied: true,
      );
      final locationGateway = FakeLocationServicesGateway(
        servicesEnabled: true,
        notificationsAllowed: true,
      );
      final logger = FakeLogger();
      final repository = LocationTrackingRepository(
        permissionGateway: permissionGateway,
        locationServicesGateway: locationGateway,
        platformInfo: FakePlatformInfo(
          isAndroid: true,
          isIOS: false,
          androidSdkInt: 33,
        ),
        logger: logger,
      );
      final controller = TrackingController(repository: repository);

      // Act: request foreground tracking while permanently denied.
      final foregroundResult = await controller.startForegroundTracking();

      // Assert: no OS prompt was simulated and settings guidance is shown.
      expect(permissionGateway.foregroundRequestCount, 0);
      expect(foregroundResult, TrackingStartResult.permissionDeniedForever);
      expect(controller.uiState.actionKey, LocaleKeys.location_action_open_settings);
      expect(locationGateway.activeListeners, 0);
      final foregroundLog = logger.entryFor('permission_foreground_denied');
      expect(foregroundLog, isNotNull);
      expect(foregroundLog!.fields['reason'], 'permanently_denied');

      // Arrange: flip to foreground granted so background denial is evaluated.
      permissionGateway.foregroundStatus = PermissionStatus.granted;

      // Act: request background tracking while permanently denied.
      final backgroundResult = await controller.startBackgroundTracking();

      // Assert: background request was not issued and settings guidance remains.
      expect(permissionGateway.backgroundRequestCount, 0);
      expect(backgroundResult, TrackingStartResult.permissionDeniedForever);
      expect(controller.uiState.actionKey, LocaleKeys.location_action_open_settings);
      expect(locationGateway.activeListeners, 0);
      final backgroundLog = logger.entryFor('permission_background_denied');
      expect(backgroundLog, isNotNull);
      expect(backgroundLog!.fields['reason'], 'permanently_denied');
    });

    test('Permission revoked while tracking running', () async {
      // Arrange: start with foreground permission granted and services enabled.
      final permissionGateway = FakePermissionGateway(
        foregroundStatus: PermissionStatus.granted,
        backgroundStatus: PermissionStatus.denied,
      );
      final locationGateway = FakeLocationServicesGateway(
        servicesEnabled: true,
        notificationsAllowed: true,
      );
      final logger = FakeLogger();
      final repository = LocationTrackingRepository(
        permissionGateway: permissionGateway,
        locationServicesGateway: locationGateway,
        platformInfo: FakePlatformInfo(
          isAndroid: true,
          isIOS: false,
          androidSdkInt: 33,
        ),
        logger: logger,
      );
      final controller = TrackingController(repository: repository);

      // Act: start foreground tracking successfully.
      final startResult = await controller.startForegroundTracking();

      // Assert: tracking is active and a listener was attached.
      expect(startResult, TrackingStartResult.startedForeground);
      expect(controller.currentState, TrackingState.trackingActiveForeground);
      expect(locationGateway.activeListeners, 1);

      // Act: trigger a resume check without changing permissions.
      await controller.onAppResumed();

      // Assert: listeners are not duplicated on resume.
      expect(locationGateway.activeListeners, 1);

      // Arrange: simulate permission revocation while tracking is active.
      permissionGateway.foregroundStatus = PermissionStatus.denied;

      // Act: re-check permissions on resume.
      await controller.onAppResumed();

      // Assert: tracking stops and logs indicate permission revocation.
      expect(controller.currentState, TrackingState.trackingStoppedPermissionRevoked);
      expect(locationGateway.activeListeners, 0);
      expect(
        controller.uiState.statusKey,
        LocaleKeys.location_status_permission_denied,
      );
      final revokedLog = logger.entryFor('permission_revoked');
      expect(revokedLog, isNotNull);
      expect(revokedLog!.fields['scope'], 'foreground');
    });
  });
}
