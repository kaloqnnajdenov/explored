import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'app/explored_app.dart';
import 'features/map/data/repositories/map_repository.dart';
import 'features/map/data/services/map_attribution_service.dart';
import 'features/map/data/services/map_tile_service.dart';
import 'features/map/view_model/map_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final mapRepository = MapRepository(
    tileService: OpenStreetMapTileService(),
    attributionService: UrlLauncherMapAttributionService(),
  );
  final mapViewModel = MapViewModel(mapRepository: mapRepository);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: ExploredApp(mapViewModel: mapViewModel),
    ),
  );
}
