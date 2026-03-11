import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';

const Map<String, dynamic> _enTranslations = {
  'common_coming_soon': 'Coming soon — this feature is not yet implemented.',
  'common_not_implemented': 'NOT IMPLEMENTED',
  'onboarding_action_skip': 'Skip',
  'onboarding_action_next': 'Next',
  'onboarding_action_get_started': 'Get Started',
  'onboarding_slide1_title': "Track where you've been",
  'onboarding_slide1_description':
      'Follow your route in the background and build your exploration history automatically.',
  'onboarding_slide2_title': 'See your completion',
  'onboarding_slide2_description':
      'Open each region and check progress for trails, peaks, and huts.',
  'onboarding_slide3_title': 'Works offline',
  'onboarding_slide3_description':
      'Download region packs and keep exploring without a network connection.',
  'permissions_required_label': 'REQUIRED',
  'permissions_optional_label': 'OPTIONAL',
  'permissions_precise_location': 'Precise Location',
  'permissions_background_location': 'Background Location',
  'permissions_motion_activity': 'Motion & Activity',
  'permissions_notifications': 'Notifications',
  'permissions_file_access': 'File Access',
  'permissions_action_grant_required': 'Grant required permissions',
  'permissions_action_continue_limited': 'Continue in limited mode',
  'permissions_title_enable_tracking': 'Enable Tracking',
  'permissions_subtitle':
      'Grant required permissions to record your exploration in the background.',
  'permissions_status_granted_caps': 'GRANTED',
  'permissions_status_not_granted_caps': 'NOT GRANTED',
  'menu_export': 'Export',
  'menu_download': 'Download',
  'map_action_recenter_location': 'Recenter',
  'map_attribution': 'Map data',
  'map_attribution_source': 'Source',
  'map_scale_meters': '{value} m',
  'map_scale_kilometers': '{value} km',
  'progress_total_explored_label': 'Total explored',
  'progress_last_7_days_placeholder': 'Last 7 days',
  'progress_feature_trails': 'Trails',
  'progress_feature_peaks': 'Peaks',
  'progress_feature_huts': 'Huts',
  'progress_tracking_active': 'Tracking active',
  'progress_tap_find_region': 'Find region',
  'progress_current_region_label': 'Current region',
  'progress_region_area_placeholder': 'Region area',
  'region_finder_title': 'Find region',
  'region_finder_search_hint': 'Search region',
  'region_finder_chip_near_me': 'Near me',
  'region_finder_chip_map_area': 'Map area',
  'region_finder_search_area': 'Search this area',
  'region_finder_results_count': '{count} results',
  'region_finder_empty_title': 'No regions',
  'region_finder_empty_subtitle': 'Try another search',
  'region_finder_current_badge': 'Current',
  'region_finder_area': '{area} km²',
  'region_finder_action_selected': 'Selected',
  'region_finder_action_select': 'Select',
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
  'settings_title': 'Settings',
  'settings_profile_name': 'Hex Explorer',
  'settings_profile_subtitle': 'Level 3',
  'settings_region_packs_title': 'Region Packs',
  'settings_data_storage_title': 'Data & Storage',
  'settings_manual_edit_mode': 'Manual Edit Mode',
  'settings_permissions': 'Permissions',
  'settings_import_gpx': 'Import GPX',
  'settings_export_csv': 'Export CSV',
  'settings_download_action': 'Download',
  'settings_version_text': 'Version 1.0.0',
  'permissions_helper_coming_soon': 'Coming soon.',
  'permissions_helper_not_required_on_device': 'Not required on this device.',
  'permissions_feedback_manage_in_settings':
      'Manage this permission in system settings.',
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
