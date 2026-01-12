import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../location/data/models/lat_lng_sample.dart';
import '../../../location/data/models/location_permission_level.dart';
import '../../../location/data/models/location_status.dart';
import '../../../location/data/models/location_tracking_mode.dart';
import '../../../location/data/models/location_tracking_state.dart';
import '../../../../translations/locale_keys.g.dart';

/// Compact status surface for location tracking on the map screen.
class LocationTrackingPanel extends StatelessWidget {
  const LocationTrackingPanel({
    required this.state,
    this.onRequestForegroundPermission,
    this.onRequestBackgroundPermission,
    this.onRequestNotificationPermission,
    this.onOpenSettings,
    super.key,
  });

  final LocationTrackingState state;
  final VoidCallback? onRequestForegroundPermission;
  final VoidCallback? onRequestBackgroundPermission;
  final VoidCallback? onRequestNotificationPermission;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final actions = _buildActions(context);
    final showSettingsButton =
        _shouldShowOpenSettings && onOpenSettings != null;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.location_panel_title.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  LocaleKeys.location_status_label
                      .tr(namedArgs: {'status': _statusText(state.status)}),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  LocaleKeys.location_tracking_label.tr(
                    namedArgs: {
                      'status': _trackingText(state.trackingMode),
                    },
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  LocaleKeys.location_permission_foreground_label.tr(
                    namedArgs: {
                      'status': _foregroundPermissionText(state.permissionLevel),
                    },
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  LocaleKeys.location_permission_background_label.tr(
                    namedArgs: {
                      'status': _backgroundPermissionText(state.permissionLevel),
                    },
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  LocaleKeys.location_permission_notification_label.tr(
                    namedArgs: {
                      'status': _notificationPermissionText(
                        state.isNotificationPermissionGranted,
                      ),
                    },
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _lastLocationText(state.lastLocation),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (state.trackingMode == LocationTrackingMode.background)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      LocaleKeys.location_battery_optimization_hint.tr(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (state.isActionInProgress)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(),
                  ),
                if (actions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: actions,
                    ),
                  ),
                if (showSettingsButton) const SizedBox(height: 32),
              ],
            ),
            if (showSettingsButton)
              Positioned(
                right: 0,
                bottom: 0,
                child: _buildSettingsButton(context),
              ),
          ],
        ),
      ),
    );
  }

  String _trackingText(LocationTrackingMode mode) {
    switch (mode) {
      case LocationTrackingMode.none:
        return LocaleKeys.location_tracking_off.tr();
      case LocationTrackingMode.foreground:
        return LocaleKeys.location_tracking_foreground.tr();
      case LocationTrackingMode.background:
        return LocaleKeys.location_tracking_background.tr();
    }
  }

  String _foregroundPermissionText(LocationPermissionLevel level) {
    switch (level) {
      case LocationPermissionLevel.foreground:
      case LocationPermissionLevel.background:
        return LocaleKeys.location_permission_foreground.tr();
      case LocationPermissionLevel.denied:
        return LocaleKeys.location_permission_denied.tr();
      case LocationPermissionLevel.deniedForever:
        return LocaleKeys.location_permission_denied_forever.tr();
      case LocationPermissionLevel.restricted:
        return LocaleKeys.location_permission_restricted.tr();
      case LocationPermissionLevel.unknown:
        return LocaleKeys.location_permission_unknown.tr();
    }
  }

  String _backgroundPermissionText(LocationPermissionLevel level) {
    switch (level) {
      case LocationPermissionLevel.background:
        return LocaleKeys.location_permission_background.tr();
      case LocationPermissionLevel.foreground:
        return LocaleKeys.location_permission_status_not_granted.tr();
      case LocationPermissionLevel.denied:
        return LocaleKeys.location_permission_denied.tr();
      case LocationPermissionLevel.deniedForever:
        return LocaleKeys.location_permission_denied_forever.tr();
      case LocationPermissionLevel.restricted:
        return LocaleKeys.location_permission_restricted.tr();
      case LocationPermissionLevel.unknown:
        return LocaleKeys.location_permission_unknown.tr();
    }
  }

  String _notificationPermissionText(bool granted) {
    return granted
        ? LocaleKeys.location_permission_status_granted.tr()
        : LocaleKeys.location_permission_status_not_granted.tr();
  }

  String _statusText(LocationStatus status) {
    switch (status) {
      case LocationStatus.idle:
        return LocaleKeys.location_status_idle.tr();
      case LocationStatus.requestingPermission:
        return LocaleKeys.location_status_requesting_permission.tr();
      case LocationStatus.permissionDenied:
        return LocaleKeys.location_status_permission_denied.tr();
      case LocationStatus.backgroundPermissionDenied:
        return LocaleKeys.location_status_background_permission_denied.tr();
      case LocationStatus.permissionDeniedForever:
        return LocaleKeys.location_status_permission_denied_forever.tr();
      case LocationStatus.permissionRestricted:
        return LocaleKeys.location_status_permission_restricted.tr();
      case LocationStatus.notificationPermissionDenied:
        return LocaleKeys.location_status_notification_permission_denied.tr();
      case LocationStatus.locationServicesDisabled:
        return LocaleKeys.location_status_location_services_disabled.tr();
      case LocationStatus.trackingStartedForeground:
        return LocaleKeys.location_status_tracking_started_foreground.tr();
      case LocationStatus.trackingStartedBackground:
        return LocaleKeys.location_status_tracking_started_background.tr();
      case LocationStatus.trackingStopped:
        return LocaleKeys.location_status_tracking_stopped.tr();
      case LocationStatus.error:
        return LocaleKeys.location_status_error.tr();
    }
  }

  String _lastLocationText(LatLngSample? location) {
    if (location == null) {
      return LocaleKeys.location_last_location_empty.tr();
    }
    final latitude = location.latitude.toStringAsFixed(5);
    final longitude = location.longitude.toStringAsFixed(5);
    return LocaleKeys.location_last_location_value.tr(
      namedArgs: {
        'lat': latitude,
        'lng': longitude,
      },
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final isBusy = state.isActionInProgress;
    final actions = <Widget>[];

    if (onRequestForegroundPermission != null) {
      actions.add(
        _buildActionButton(
          context,
          label: LocaleKeys.location_action_request_foreground.tr(),
          onPressed: isBusy ? null : onRequestForegroundPermission,
        ),
      );
    }

    if (onRequestBackgroundPermission != null) {
      actions.add(
        _buildActionButton(
          context,
          label: LocaleKeys.location_action_request_background.tr(),
          onPressed: isBusy ? null : onRequestBackgroundPermission,
        ),
      );
    }

    if (onRequestNotificationPermission != null) {
      actions.add(
        _buildActionButton(
          context,
          label: LocaleKeys.location_action_request_notifications.tr(),
          onPressed: isBusy ? null : onRequestNotificationPermission,
        ),
      );
    }

    return actions;
  }

  bool get _shouldShowOpenSettings {
    return state.shouldShowOpenSettings ||
        state.status == LocationStatus.locationServicesDisabled;
  }

  Widget _buildSettingsButton(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      style: TextButton.styleFrom(
        textStyle: theme.textTheme.labelSmall,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: const Size(0, 32),
        visualDensity: VisualDensity.compact,
      ),
      onPressed: state.isActionInProgress ? null : onOpenSettings,
      child: Text(LocaleKeys.location_action_open_settings.tr()),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required VoidCallback? onPressed,
  }) {
    final theme = Theme.of(context);
    return FilledButton.tonal(
      style: FilledButton.styleFrom(
        textStyle: theme.textTheme.labelLarge,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
