import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../translations/locale_keys.g.dart';
import '../../../../ui/core/app_colors.dart';
import '../../data/models/app_permission.dart';

class PermissionStatusTile extends StatelessWidget {
  const PermissionStatusTile({
    required this.permission,
    required this.onChanged,
    required this.isBusy,
    super.key,
  });

  final AppPermissionStatus permission;
  final ValueChanged<bool>? onChanged;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final canToggle = !isBusy && permission.isInteractive && onChanged != null;
    final isFileAccess = permission.type == AppPermissionType.fileAccess;
    final activeThumbColor = isFileAccess
        ? AppColors.slate400
        : AppColors.emerald500;
    final activeTrackColor = isFileAccess
        ? AppColors.slate200
        : AppColors.emerald100;
    final inactiveThumbColor = isFileAccess
        ? AppColors.slate400
        : AppColors.rose500;
    final inactiveTrackColor = isFileAccess
        ? AppColors.slate200
        : AppColors.rose50;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _labelFor(permission.type),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.slate900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    LocaleKeys.permissions_status_label.tr(
                      namedArgs: {
                        'status': permission.isGranted
                            ? LocaleKeys.permissions_status_granted.tr()
                            : LocaleKeys.permissions_status_denied.tr(),
                      },
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.slate600),
                  ),
                  if (permission.helperMessageKey != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      permission.helperMessageKey!.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              value: permission.isGranted,
              onChanged: canToggle ? onChanged : null,
              activeThumbColor: activeThumbColor,
              activeTrackColor: activeTrackColor,
              inactiveThumbColor: inactiveThumbColor,
              inactiveTrackColor: inactiveTrackColor,
            ),
          ],
        ),
      ),
    );
  }

  String _labelFor(AppPermissionType type) {
    switch (type) {
      case AppPermissionType.locationForeground:
        return LocaleKeys.permissions_item_location_foreground.tr();
      case AppPermissionType.locationBackground:
        return LocaleKeys.permissions_item_location_background.tr();
      case AppPermissionType.motionActivity:
        return LocaleKeys.permissions_motion_activity.tr();
      case AppPermissionType.notifications:
        return LocaleKeys.permissions_item_notifications.tr();
      case AppPermissionType.fileAccess:
        return LocaleKeys.permissions_item_file_access.tr();
    }
  }
}
