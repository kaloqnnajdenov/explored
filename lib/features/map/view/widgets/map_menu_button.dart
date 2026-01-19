import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../translations/locale_keys.g.dart';

enum MapMenuAction { permissions, importGpx }

class MapMenuButton extends StatelessWidget {
  const MapMenuButton({
    required this.onActionSelected,
    super.key,
  });

  final void Function(MapMenuAction action) onActionSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: const CircleBorder(),
      elevation: 2,
      child: PopupMenuButton<MapMenuAction>(
        tooltip: LocaleKeys.menu_open_tooltip.tr(),
        icon: const Icon(Icons.menu),
        onSelected: onActionSelected,
        itemBuilder: (context) => [
          PopupMenuItem(
            value: MapMenuAction.permissions,
            child: Text(LocaleKeys.menu_permissions_management.tr()),
          ),
          PopupMenuItem(
            value: MapMenuAction.importGpx,
            child: Text(LocaleKeys.menu_import_gpx.tr()),
          ),
        ],
      ),
    );
  }
}
