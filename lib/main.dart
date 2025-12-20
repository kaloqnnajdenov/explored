import 'package:flutter/material.dart';

import 'app/explored_app.dart';
import 'core/text/data/repositories/text_repository.dart';
import 'core/text/data/services/text_service.dart';
import 'features/map/data/repositories/map_repository.dart';
import 'features/map/data/services/map_attribution_service.dart';
import 'features/map/data/services/map_tile_service.dart';
import 'features/map/view_model/map_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const localeCode = 'en';
  final textRepository = TextRepository(textService: AssetTextService());
  final appTitle = await textRepository.getText(
    key: 'app_title',
    locale: localeCode,
  );

  final mapRepository = MapRepository(
    tileService: OpenStreetMapTileService(),
    attributionService: UrlLauncherMapAttributionService(),
  );
  final mapViewModel = MapViewModel(
    mapRepository: mapRepository,
    textRepository: textRepository,
    locale: const Locale(localeCode),
  );

  runApp(ExploredApp(mapViewModel: mapViewModel, appTitle: appTitle));
}
