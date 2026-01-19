import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../translations/locale_keys.g.dart';
import '../../data/models/app_permission.dart';

class PermissionStatusTile extends StatelessWidget {
  const PermissionStatusTile({
    required this.permission,
    required this.onRequest,
    required this.isBusy,
    super.key,
  });

  final AppPermissionStatus permission;
  final VoidCallback? onRequest;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final canRequest = !permission.isGranted && !isBusy && onRequest != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _labelFor(permission.type),
                    style: Theme.of(context).textTheme.titleSmall,
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
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.tonal(
              onPressed: canRequest ? onRequest : null,
              child: Text(LocaleKeys.permissions_action_request.tr()),
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
      case AppPermissionType.notifications:
        return LocaleKeys.permissions_item_notifications.tr();
      case AppPermissionType.fileAccess:
        return LocaleKeys.permissions_item_file_access.tr();
    }
  }
}
