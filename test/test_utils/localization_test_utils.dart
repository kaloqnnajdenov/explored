import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';

const Map<String, dynamic> _enTranslations = {
  'menu_open_tooltip': 'Open menu',
  'menu_permissions_management': 'Permissions management',
  'menu_import_gpx': 'Import GPX file',
  'menu_export': 'Export',
  'menu_download': 'Download',
  'menu_explored_area': 'Explored area',
  'menu_overlay_tile_size': 'Overlay tile size',
  'overlay_tile_size_title': 'Overlay tile size',
  'overlay_tile_size_256': '256 px (lower detail)',
  'overlay_tile_size_512': '512 px (higher detail)',
  'explored_area_title': 'Explored area',
  'explored_area_value': 'Explored: {value} km2',
  'explored_area_filter_label': 'Date range',
  'explored_area_filter_all_time': 'All time',
  'explored_area_filter_last_7_days': 'Last 7 days',
  'explored_area_filter_last_30_days': 'Last 30 days',
  'explored_area_filter_this_month': 'This month',
  'explored_area_filter_custom': 'Custom range',
  'explored_area_filter_select_start': 'Start date',
  'explored_area_filter_select_end': 'End date',
  'map_scale_meters': '{value} m',
  'map_scale_kilometers': '{value} km',
  'permissions_title': 'Permissions',
  'permissions_status_label': 'Status: {status}',
  'permissions_status_granted': 'Granted',
  'permissions_status_denied': 'Denied',
  'permissions_action_request': 'Request',
  'permissions_action_close': 'Close',
  'permissions_item_location_foreground': 'Location (foreground)',
  'permissions_item_location_background': 'Location (background)',
  'permissions_item_notifications': 'Notifications',
  'permissions_item_file_access': 'File access',
  'permissions_error_generic': 'Could not update permissions. Try again.',
  'gpx_import_processing': 'Processing GPX data...',
  'gpx_import_success': 'Imported {count} points.',
  'export_ready': 'Export ready',
  'export_failed': 'Export failed. Try again.',
  'download_ready': 'Download ready',
  'download_failed': 'Download failed. Try again.',
};

Future<void> loadTestTranslations() async {
  Localization.load(
    const Locale('en'),
    translations: Translations(_enTranslations),
    fallbackTranslations: Translations(_enTranslations),
  );
}

Future<Widget> buildLocalizedTestApp(Widget child) async {
  await loadTestTranslations();
  return MaterialApp(home: child);
}
