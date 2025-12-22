import 'package:flutter/foundation.dart';

import '../../../translations/locale_keys.g.dart';
import '../data/models/location_tracking_mode.dart';
import '../data/models/tracking_state.dart';
import '../data/repositories/location_tracking_repository.dart';

/// Exposes tracking state and commands for the UI layer.
class TrackingController extends ChangeNotifier {
  /// Builds the controller with injected tracking repository.
  TrackingController({
    required LocationTrackingRepository repository,
  })  : _repository = repository,
        _uiState = TrackingUiState.initial();

  final LocationTrackingRepository _repository;

  TrackingUiState _uiState;

  TrackingUiState get uiState => _uiState;

  TrackingState get currentState => _uiState.state;

  /// Starts foreground tracking and updates UI state with the result.
  Future<TrackingStartResult> startForegroundTracking() async {
    final decision = await _repository.startForegroundTracking();
    _applySnapshot(decision.snapshot);
    return decision.result;
  }

  /// Starts background tracking and updates UI state with the result.
  Future<TrackingStartResult> startBackgroundTracking() async {
    final decision = await _repository.startBackgroundTracking();
    _applySnapshot(decision.snapshot);
    return decision.result;
  }

  /// Stops any active tracking session and updates UI state.
  Future<void> stopTracking() async {
    final snapshot = await _repository.stopTracking();
    _applySnapshot(snapshot);
  }

  /// Re-checks permissions/services on resume without duplicating listeners.
  Future<void> onAppResumed() async {
    final snapshot = await _repository.refreshTrackingState();
    _applySnapshot(snapshot);
  }

  void _applySnapshot(TrackingStateSnapshot snapshot) {
    _uiState = _uiState.copyWith(
      state: snapshot.state,
      trackingMode: snapshot.trackingMode,
      statusKey: _statusKeyFor(snapshot.state),
      actionKey: _actionKeyFor(snapshot.action),
    );
    notifyListeners();
  }

  String _statusKeyFor(TrackingState state) {
    switch (state) {
      case TrackingState.idle:
        return LocaleKeys.location_status_idle;
      case TrackingState.permissionRequiredForeground:
        return LocaleKeys.location_status_permission_denied;
      case TrackingState.permissionRequiredBackground:
        return LocaleKeys.location_status_background_permission_denied;
      case TrackingState.trackingActiveForeground:
        return LocaleKeys.location_status_tracking_started_foreground;
      case TrackingState.trackingActiveBackground:
        return LocaleKeys.location_status_tracking_started_background;
      case TrackingState.trackingPausedLocationServicesOff:
        return LocaleKeys.location_status_location_services_disabled;
      case TrackingState.trackingStoppedPermissionRevoked:
        return LocaleKeys.location_status_permission_denied;
      case TrackingState.trackingStoppedNotificationsBlocked:
        return LocaleKeys.location_status_notification_permission_denied;
      case TrackingState.trackingStopped:
        return LocaleKeys.location_status_tracking_stopped;
    }
  }

  String? _actionKeyFor(TrackingAction? action) {
    switch (action) {
      case TrackingAction.requestForegroundPermission:
        return LocaleKeys.location_action_request_foreground;
      case TrackingAction.requestBackgroundPermission:
        return LocaleKeys.location_action_request_background;
      case TrackingAction.openSettings:
        return LocaleKeys.location_action_open_settings;
      case TrackingAction.requestNotifications:
        return LocaleKeys.location_action_request_notifications;
      case TrackingAction.stopTracking:
        return LocaleKeys.location_action_stop_tracking;
      case null:
        return null;
    }
  }
}

/// Holds UI-facing tracking state along with localization keys.
class TrackingUiState {
  /// Builds an immutable UI state snapshot for tracking screens.
  const TrackingUiState({
    required this.state,
    required this.statusKey,
    required this.actionKey,
    required this.trackingMode,
  });

  final TrackingState state;
  final String statusKey;
  final String? actionKey;
  final LocationTrackingMode trackingMode;

  bool get isTracking => trackingMode != LocationTrackingMode.none;

  /// Seeds the default UI state before any tracking command runs.
  factory TrackingUiState.initial() {
    return const TrackingUiState(
      state: TrackingState.idle,
      statusKey: LocaleKeys.location_status_idle,
      actionKey: null,
      trackingMode: LocationTrackingMode.none,
    );
  }

  TrackingUiState copyWith({
    TrackingState? state,
    String? statusKey,
    String? actionKey,
    bool clearActionKey = false,
    LocationTrackingMode? trackingMode,
  }) {
    return TrackingUiState(
      state: state ?? this.state,
      statusKey: statusKey ?? this.statusKey,
      actionKey: clearActionKey ? null : actionKey ?? this.actionKey,
      trackingMode: trackingMode ?? this.trackingMode,
    );
  }
}
