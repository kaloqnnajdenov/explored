import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../features/gpx_import/view_model/gpx_import_view_model.dart';
import '../features/map/view/map_view.dart';
import '../features/map/view_model/map_view_model.dart';
import '../features/permissions/view_model/permissions_view_model.dart';
import '../translations/locale_keys.g.dart';

/// Root app wiring dependencies and theming; hosts the map as the entry screen.
class ExploredApp extends StatelessWidget {
  ExploredApp({
    required this.mapViewModel,
    required this.permissionsViewModel,
    required this.gpxImportViewModel,
    super.key,
  }) : _router = GoRouter(
         routes: [
           GoRoute(
             path: '/',
             builder: (_, __) => MapView(
               viewModel: mapViewModel,
               permissionsViewModel: permissionsViewModel,
               gpxImportViewModel: gpxImportViewModel,
             ),
           ),
         ],
       );

  final MapViewModel mapViewModel;
  final PermissionsViewModel permissionsViewModel;
  final GpxImportViewModel gpxImportViewModel;
  final GoRouter _router;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MapViewModel>.value(value: mapViewModel),
        ChangeNotifierProvider<PermissionsViewModel>.value(
          value: permissionsViewModel,
        ),
        ChangeNotifierProvider<GpxImportViewModel>.value(
          value: gpxImportViewModel,
        ),
      ],
      child: MaterialApp.router(
        onGenerateTitle: (_) => LocaleKeys.app_title.tr(),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade700),
          useMaterial3: true,
        ),
        routerConfig: _router,
      ),
    );
  }
}
