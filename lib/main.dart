import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/explored_app.dart';
import 'constants.dart';
import 'features/explored_area/view_model/explored_area_view_model.dart';
import 'features/gpx_import/data/repositories/gpx_import_repository.dart';
import 'features/gpx_import/data/services/gpx_file_picker_service.dart';
import 'features/gpx_import/data/services/gpx_parser_service.dart';
import 'features/gpx_import/view_model/gpx_import_view_model.dart';
import 'features/location/data/location_tracking_config.dart';
import 'features/location/data/repositories/location_updates_repository.dart';
import 'features/location/data/repositories/location_history_repository.dart';
import 'features/location/data/services/background_location_client.dart';
import 'features/location/data/services/location_history_database.dart';
import 'features/location/data/services/location_history_export_service.dart';
import 'features/location/data/services/location_permission_service.dart';
import 'features/location/data/services/location_tracking_service_factory.dart';
import 'features/location/data/services/platform_info.dart';
import 'features/map/data/repositories/map_repository.dart';
import 'features/map/data/services/map_attribution_service.dart';
import 'features/map/data/services/map_overlay_settings_service.dart';
import 'features/map/data/services/map_tile_service.dart';
import 'features/map/view_model/map_view_model.dart';
import 'features/permissions/data/repositories/permissions_repository.dart';
import 'features/permissions/data/services/file_access_permission_service.dart';
import 'features/permissions/data/services/permission_request_store.dart';
import 'features/permissions/view_model/permissions_view_model.dart';
import 'features/visited_grid/data/models/fog_of_war_config.dart';
import 'features/visited_grid/data/models/visited_grid_config.dart';
import 'features/visited_grid/data/repositories/fog_of_war_tile_repository.dart';
import 'features/visited_grid/data/repositories/visited_grid_repository.dart';
import 'features/visited_grid/data/services/explored_area_logger.dart';
import 'features/visited_grid/data/services/fog_of_war_tile_cache_service.dart';
import 'features/visited_grid/data/services/fog_of_war_tile_raster_service.dart';
import 'features/visited_grid/data/services/visited_grid_database.dart';
import 'features/visited_grid/data/services/visited_grid_h3_service.dart';
import 'features/visited_grid/view_model/fog_of_war_overlay_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

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
  final overlaySettingsService = SharedPreferencesMapOverlaySettingsService(
    preferences: sharedPreferences,
  );
  final mapRepository = MapRepository(
    tileService: OpenStreetMapTileService(),
    attributionService: UrlLauncherMapAttributionService(),
    overlaySettingsService: overlaySettingsService,
  );
  final permissionRequestStore = SharedPreferencesPermissionRequestStore(
    preferences: sharedPreferences,
  );
  final fileAccessPermissionService = PermissionHandlerFileAccessPermissionService(
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
    config: locationTrackingConfig,
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
  final locationHistoryRepository = DefaultLocationHistoryRepository(
    locationUpdatesRepository: locationUpdatesRepository,
    historyDao: locationHistoryDatabase.locationHistoryDao,
    exportService: locationHistoryExportService,
  );
  const visitedGridConfig = VisitedGridConfig();
  final visitedGridDatabase = VisitedGridDatabase(shareAcrossIsolates: true);
  final visitedGridH3Service = VisitedGridH3Service();
  final exploredAreaLogger = ConsoleExploredAreaLogger();
  final visitedGridRepository = DefaultVisitedGridRepository(
    locationUpdatesRepository: locationUpdatesRepository,
    visitedGridDao: visitedGridDatabase.visitedGridDao,
    h3Service: visitedGridH3Service,
    exploredAreaLogger: exploredAreaLogger,
    appVersion: kAppVersion,
    schemaVersion: visitedGridDatabase.schemaVersion,
    config: visitedGridConfig,
  );
  const fogConfig = FogOfWarConfig();
  final fogCacheService = FogOfWarTileCacheService(
    pathProvider: PathProviderTileCachePathProvider(),
    maxEntries: fogConfig.cacheMaxEntries,
  );
  final fogRasterService = FogOfWarTileRasterService();
  final fogTileRepository = FogOfWarTileRepository(
    visitedGridDao: visitedGridDatabase.visitedGridDao,
    h3Service: visitedGridH3Service,
    rasterService: fogRasterService,
    cacheService: fogCacheService,
    visitedGridConfig: visitedGridConfig,
    config: fogConfig,
  );
  final fogOverlayController = DefaultFogOfWarOverlayController(
    visitedGridRepository: visitedGridRepository,
    tileRepository: fogTileRepository,
  );
  final mapViewModel = MapViewModel(
    mapRepository: mapRepository,
    locationUpdatesRepository: locationUpdatesRepository,
    locationHistoryRepository: locationHistoryRepository,
    permissionsRepository: permissionsRepository,
    visitedGridRepository: visitedGridRepository,
    overlayController: fogOverlayController,
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
      visitedGridRepository: visitedGridRepository,
      config: locationTrackingConfig,
    ),
  );
  final exploredAreaViewModel = ExploredAreaViewModel(
    visitedGridRepository: visitedGridRepository,
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: ExploredApp(
        mapViewModel: mapViewModel,
        permissionsViewModel: permissionsViewModel,
        gpxImportViewModel: gpxImportViewModel,
        exploredAreaViewModel: exploredAreaViewModel,
      ),
    ),
  );
}
