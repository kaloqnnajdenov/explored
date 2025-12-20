import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/map/view/map_view.dart';
import '../features/map/view_model/map_view_model.dart';
import '../translations/locale_keys.g.dart';

/// Root app wiring dependencies and theming; hosts the map as the entry screen.
class ExploredApp extends StatelessWidget {
  const ExploredApp({
    required this.mapViewModel,
    super.key,
  });

  final MapViewModel mapViewModel;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MapViewModel>.value(value: mapViewModel),
      ],
      child: MaterialApp(
        onGenerateTitle: (_) => LocaleKeys.app_title.tr(),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade700),
          useMaterial3: true,
        ),
        home: MapView(viewModel: mapViewModel),
      ),
    );
  }
}
