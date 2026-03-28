import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/explored_app.dart';
import 'features/app_state/data/repositories/app_state_repository.dart';
import 'features/app_state/data/services/app_state_prefs_service.dart';
import 'features/app_state/view_model/app_state_view_model.dart';
import 'features/exploration/data/repositories/entity_repository.dart';
import 'features/exploration/data/repositories/object_repository.dart';
import 'features/exploration/data/repositories/pack_management_repository.dart';
import 'features/exploration/data/repositories/progress_repository.dart';
import 'features/exploration/data/repositories/selection_repository.dart';
import 'features/exploration/data/repositories/totals_repository.dart';
import 'features/exploration/data/services/bundled_pack_asset_service.dart';
import 'features/exploration/data/services/exploration_database.dart';
import 'features/exploration/data/services/legacy_selection_service.dart';
import 'features/exploration/data/services/local_user_prefs_service.dart';
import 'features/exploration/data/services/pack_import_service.dart';
import 'features/gpx_import/data/repositories/gpx_import_repository.dart';
import 'features/gpx_import/data/services/gpx_file_picker_service.dart';
import 'features/gpx_import/data/services/gpx_parser_service.dart';
import 'features/gpx_import/view_model/gpx_import_view_model.dart';
import 'features/location/data/location_tracking_config.dart';
import 'features/location/data/repositories/location_history_repository.dart';
import 'features/location/data/repositories/location_updates_repository.dart';
import 'features/location/data/services/background_location_client.dart';
import 'features/location/data/services/location_history_database.dart';
import 'features/location/data/services/location_history_export_service.dart';
import 'features/location/data/services/location_history_h3_service.dart';
import 'features/location/data/services/location_permission_service.dart';
import 'features/location/data/services/location_tracking_service_factory.dart';
import 'features/location/data/services/platform_info.dart';
import 'features/map/data/repositories/map_repository.dart';
import 'features/map/data/services/map_attribution_service.dart';
import 'features/map/data/services/map_provider_selection_service.dart';
import 'features/map/view_model/map_view_model.dart';
import 'features/permissions/data/repositories/permissions_repository.dart';
import 'features/permissions/data/services/file_access_permission_service.dart';
import 'features/permissions/data/services/permission_request_store.dart';
import 'features/permissions/view_model/permissions_view_model.dart';
import 'features/progress_home/view_model/progress_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (error) {
    debugPrint(
      'Unable to load .env. Falling back to OSM if MapTiler key is unavailable. Error: $error',
    );
  }

  final platformInfo = DevicePlatformInfo();
  final locationTrackingConfig = LocationTrackingConfig();
  final permissionHandlerClient = PermissionHandlerClientImpl();
  final geolocatorClient = GeolocatorPermissionClientImpl();
  final locationPermissionService = PermissionHandlerLocationPermissionService(
    client: permissionHandlerClient,
    geolocatorClient: geolocatorClient,
    platformInfo: platformInfo,
  );
  final sharedPreferences = await SharedPreferences.getInstance();
  final mapProviderSelectionService = HttpMapProviderSelectionService();
  final resolvedMapProvider = await mapProviderSelectionService
      .resolveForSession(mapTilerKey: dotenv.env['MAPTILER_KEY'] ?? '');
  final mapRepository = MapRepository(
    tileService: resolvedMapProvider.tileService,
    attributionService: UrlLauncherMapAttributionService(
      attributionUri: resolvedMapProvider.attributionUri,
    ),
  );
  final permissionRequestStore = SharedPreferencesPermissionRequestStore(
    preferences: sharedPreferences,
  );
  final fileAccessPermissionService =
      PermissionHandlerFileAccessPermissionService(
        client: permissionHandlerClient,
        platformInfo: platformInfo,
      );
  final permissionsRepository = DefaultPermissionsRepository(
    locationPermissionService: locationPermissionService,
    fileAccessPermissionService: fileAccessPermissionService,
    requestStore: permissionRequestStore,
    platformInfo: platformInfo,
  );
  final trackingService = LocationTrackingServiceFactory.create(
    client: BackgroundLocationPluginClient(),
    config: locationTrackingConfig,
  );
  final locationUpdatesRepository = DefaultLocationUpdatesRepository(
    trackingService: trackingService,
    permissionService: locationPermissionService,
    platformInfo: platformInfo,
  );
  final locationHistoryDatabase = LocationHistoryDatabase(
    shareAcrossIsolates: true,
  );
  final locationHistoryExportService = LocationHistoryExportService(
    historyDao: locationHistoryDatabase.locationHistoryDao,
    pathProvider: PathProviderClientImpl(),
    shareClient: SharePlusClient(),
    fileSaveClient: FilePickerSaveClient(),
  );
  final locationHistoryH3Service = LocationHistoryH3Service();
  final locationHistoryRepository = DefaultLocationHistoryRepository(
    locationUpdatesRepository: locationUpdatesRepository,
    historyDao: locationHistoryDatabase.locationHistoryDao,
    exportService: locationHistoryExportService,
    h3Service: locationHistoryH3Service,
  );

  final explorationDatabase = ExplorationDatabase(shareAcrossIsolates: true);
  final bundledPackAssetService = BundleBundledPackAssetService();
  final packImportService = PackImportService(
    assetService: bundledPackAssetService,
    explorationDao: explorationDatabase.explorationDao,
  );
  final localUserPrefsService = LocalUserPrefsService(
    preferences: sharedPreferences,
  );
  final entityRepository = DefaultEntityRepository(
    packImportService: packImportService,
    explorationDao: explorationDatabase.explorationDao,
  );
  final selectionRepository = DefaultSelectionRepository(
    explorationDao: explorationDatabase.explorationDao,
    entityRepository: entityRepository,
    localUserPrefsService: localUserPrefsService,
  );
  final objectRepository = DefaultObjectRepository(
    entityRepository: entityRepository,
    explorationDao: explorationDatabase.explorationDao,
  );
  final totalsRepository = DefaultTotalsRepository(
    explorationDao: explorationDatabase.explorationDao,
  );
  final progressRepository = DefaultProgressRepository(
    entityRepository: entityRepository,
    totalsRepository: totalsRepository,
    explorationDao: explorationDatabase.explorationDao,
    localUserPrefsService: localUserPrefsService,
  );
  final legacySelectionService = LegacySelectionService(
    preferences: sharedPreferences,
  );
  final packManagementRepository = DefaultPackManagementRepository(
    packImportService: packImportService,
    explorationDao: explorationDatabase.explorationDao,
    legacySelectionService: legacySelectionService,
    localUserPrefsService: localUserPrefsService,
  );
  await packManagementRepository.bootstrapBundledCountryPacks();

  final mapViewModel = MapViewModel(
    mapRepository: mapRepository,
    locationUpdatesRepository: locationUpdatesRepository,
    locationHistoryRepository: locationHistoryRepository,
    permissionsRepository: permissionsRepository,
    entityRepository: entityRepository,
    objectRepository: objectRepository,
    selectionRepository: selectionRepository,
  );
  final permissionsViewModel = PermissionsViewModel(
    repository: permissionsRepository,
  );
  final gpxImportViewModel = GpxImportViewModel(
    repository: DefaultGpxImportRepository(
      fileAccessPermissionService: fileAccessPermissionService,
      filePickerService: GpxFilePickerService(
        client: FilePickerClientImpl(),
        platformInfo: platformInfo,
      ),
      parserService: XmlGpxParserService(),
      locationHistoryRepository: locationHistoryRepository,
    ),
  );
  final appStateRepository = DefaultAppStateRepository(
    prefsService: AppStatePrefsService(preferences: sharedPreferences),
  );
  final appStateViewModel = AppStateViewModel(
    repository: appStateRepository,
    initialState: appStateRepository.createInitialState(),
  );
  final progressViewModel = ProgressViewModel(
    entityRepository: entityRepository,
    progressRepository: progressRepository,
    selectionRepository: selectionRepository,
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: ExploredApp(
        appStateViewModel: appStateViewModel,
        mapViewModel: mapViewModel,
        permissionsViewModel: permissionsViewModel,
        gpxImportViewModel: gpxImportViewModel,
        progressViewModel: progressViewModel,
        entityRepository: entityRepository,
        selectionRepository: selectionRepository,
        progressRepository: progressRepository,
      ),
    ),
  );
  unawaited(appStateViewModel.bootstrap());
}
