import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'app/explored_app.dart';
import 'domain/usecases/h3_overlay_worker.dart';
import 'features/location/data/location_tracking_config.dart';
import 'features/location/data/repositories/location_updates_repository.dart';
import 'features/location/data/services/background_location_client.dart';
import 'features/location/data/services/location_permission_service.dart';
import 'features/location/data/services/location_tracking_service_factory.dart';
import 'features/location/data/services/platform_info.dart';
import 'features/map/data/repositories/map_repository.dart';
import 'features/map/data/services/map_attribution_service.dart';
import 'features/map/data/services/map_tile_service.dart';
import 'features/map/view_model/map_view_model.dart';
import 'features/visited_grid/data/models/visited_grid_config.dart';
import 'features/visited_grid/data/repositories/visited_grid_repository.dart';
import 'features/visited_grid/data/services/visited_grid_database.dart';
import 'features/visited_grid/data/services/visited_grid_h3_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final mapRepository = MapRepository(
    tileService: OpenStreetMapTileService(),
    attributionService: UrlLauncherMapAttributionService(),
  );
  final platformInfo = DevicePlatformInfo();
  final locationTrackingConfig = LocationTrackingConfig();
  final trackingService = LocationTrackingServiceFactory.create(
    client: BackgroundLocationPluginClient(),
    config: locationTrackingConfig,
  );
  final locationUpdatesRepository = DefaultLocationUpdatesRepository(
    trackingService: trackingService,
    permissionService: PermissionHandlerLocationPermissionService(
      client: PermissionHandlerClientImpl(),
      geolocatorClient: GeolocatorPermissionClientImpl(),
      platformInfo: platformInfo,
    ),
    platformInfo: platformInfo,
    config: locationTrackingConfig,
  );
  await locationUpdatesRepository.startTracking();
  const visitedGridConfig = VisitedGridConfig();
  final visitedGridDatabase = VisitedGridDatabase(shareAcrossIsolates: true);
  final visitedGridH3Service = VisitedGridH3Service();
  final visitedGridRepository = DefaultVisitedGridRepository(
    locationUpdatesRepository: locationUpdatesRepository,
    visitedGridDao: visitedGridDatabase.visitedGridDao,
    h3Service: visitedGridH3Service,
    config: visitedGridConfig,
  );
  final overlayWorker = H3OverlayWorker(
    config: H3OverlayWorkerConfig(
      baseResolution: visitedGridConfig.baseResolution,
      minResolution: visitedGridConfig.minRenderResolution,
      mergeThreshold: visitedGridConfig.maxCandidateCells,
    ),
  );
  final boundaryResolver = (String cellId) {
    final cell = visitedGridH3Service.decodeCellId(cellId);
    return visitedGridH3Service.cellBoundary(cell);
  };
  final mapViewModel = MapViewModel(
    mapRepository: mapRepository,
    locationUpdatesRepository: locationUpdatesRepository,
    visitedGridRepository: visitedGridRepository,
    overlayWorker: overlayWorker,
    boundaryResolver: boundaryResolver,
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: ExploredApp(mapViewModel: mapViewModel),
    ),
  );
}
