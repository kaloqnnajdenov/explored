import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../location/data/models/location_permission_level.dart';
import '../../../location/data/models/location_status.dart';
import '../../../location/data/models/location_tracking_mode.dart';
import '../../../location/data/models/location_tracking_state.dart';
import '../../../location/data/models/location_update.dart';
import '../../../../translations/locale_keys.g.dart';

/// Compact control surface for managing location tracking on the map screen.
class LocationTrackingPanel extends StatelessWidget {
  const LocationTrackingPanel({
    required this.state,
    required this.onRequestForegroundPermission,
    required this.onRequestBackgroundPermission,
    required this.onRequestNotificationPermission,
    required this.onOpenSettings,
    super.key,
  });

  final LocationTrackingState state;
  final VoidCallback onRequestForegroundPermission;
  final VoidCallback onRequestBackgroundPermission;
  final VoidCallback onRequestNotificationPermission;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
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
              LocaleKeys.location_permission_foreground_label.tr(
                namedArgs: {
                  'status': _grantedText(
                    _isForegroundGranted(state.permissionLevel),
                  ),
                },
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              LocaleKeys.location_permission_background_label.tr(
                namedArgs: {
                  'status': _grantedText(
                    _isBackgroundGranted(state.permissionLevel),
                  ),
                },
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              LocaleKeys.location_permission_notification_label.tr(
                namedArgs: {
                  'status': _grantedText(state.isNotificationPermissionGranted),
                },
              ),
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
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed:
                      state.isActionInProgress ? null : onRequestForegroundPermission,
                  child: Text(LocaleKeys.location_action_request_foreground.tr()),
                ),
                ElevatedButton(
                  onPressed:
                      state.isActionInProgress ? null : onRequestBackgroundPermission,
                  child: Text(LocaleKeys.location_action_request_background.tr()),
                ),
                OutlinedButton(
                  onPressed:
                      state.isActionInProgress ? null : onRequestNotificationPermission,
                  child: Text(LocaleKeys.location_action_request_notifications.tr()),
                ),
                if (state.shouldShowOpenSettings)
                  TextButton(
                    onPressed: state.isActionInProgress ? null : onOpenSettings,
                    child: Text(LocaleKeys.location_action_open_settings.tr()),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isForegroundGranted(LocationPermissionLevel level) {
    return level == LocationPermissionLevel.foreground ||
        level == LocationPermissionLevel.background;
  }

  bool _isBackgroundGranted(LocationPermissionLevel level) {
    return level == LocationPermissionLevel.background;
  }

  String _grantedText(bool granted) {
    return granted
        ? LocaleKeys.location_permission_status_granted.tr()
        : LocaleKeys.location_permission_status_not_granted.tr();
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

  String _lastLocationText(LocationUpdate? location) {
    if (location == null) {
      return LocaleKeys.location_last_location_empty.tr();
    }
    final latitude = location.latitude.toStringAsFixed(5);
    final longitude = location.longitude.toStringAsFixed(5);
    final accuracy = location.accuracy.toStringAsFixed(1);
    return LocaleKeys.location_last_location_value.tr(
      namedArgs: {
        'lat': latitude,
        'lng': longitude,
        'accuracy': accuracy,
      },
    );
  }
}
