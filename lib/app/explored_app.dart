import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../features/app_state/view_model/app_state_view_model.dart';
import '../features/gpx_import/view_model/gpx_import_view_model.dart';
import '../features/map/view/map_view.dart';
import '../features/map/view_model/map_view_model.dart';
import '../features/onboarding/view/onboarding_view.dart';
import '../features/permission_gate/view/permissions_gate_view.dart';
import '../features/permissions/view_model/permissions_view_model.dart';
import '../features/permissions/view/permissions_management_view.dart';
import '../features/profile/view/profile_view.dart';
import '../features/progress_home/view/progress_home_view.dart';
import '../features/region_detail/view/region_detail_view.dart';
import '../features/settings/view/settings_view.dart';
import '../translations/locale_keys.g.dart';
import '../ui/core/app_theme.dart';

class ExploredApp extends StatelessWidget {
  ExploredApp({
    required this.appStateViewModel,
    required this.mapViewModel,
    required this.permissionsViewModel,
    required this.gpxImportViewModel,
    super.key,
  }) : _router = GoRouter(
         refreshListenable: appStateViewModel,
         redirect: (_, state) {
           final currentPath = state.uri.path;
           final allowWithoutOnboarding =
               currentPath == '/onboarding' || currentPath == '/permissions';

           if (!appStateViewModel.hasSeenOnboarding &&
               !allowWithoutOnboarding) {
             return '/onboarding';
           }

           return null;
         },
         routes: [
           GoRoute(
             path: '/',
             builder: (_, __) => ProgressHomeView(
               appStateViewModel: appStateViewModel,
               mapViewModel: mapViewModel,
             ),
           ),
           GoRoute(
             path: '/onboarding',
             builder: (_, __) => const OnboardingView(),
           ),
           GoRoute(
             path: '/permissions',
             builder: (_, __) =>
                 PermissionsGateView(appStateViewModel: appStateViewModel),
           ),
           GoRoute(
             path: '/region/:id',
             builder: (_, state) => RegionDetailView(
               appStateViewModel: appStateViewModel,
               regionId: state.pathParameters['id']!,
             ),
           ),
           GoRoute(
             path: '/map',
             builder: (context, __) => MapView(
               viewModel: mapViewModel,
               showBackButton: true,
               onBack: () {
                 if (context.canPop()) {
                   context.pop();
                   return;
                 }
                 context.go('/');
               },
             ),
           ),
           GoRoute(
             path: '/settings',
             builder: (_, __) => SettingsView(
               appStateViewModel: appStateViewModel,
               mapViewModel: mapViewModel,
               gpxImportViewModel: gpxImportViewModel,
             ),
           ),
           GoRoute(
             path: '/settings/permissions',
             builder: (_, __) =>
                 PermissionsManagementView(viewModel: permissionsViewModel),
           ),
           GoRoute(
             path: '/profile',
             builder: (_, __) =>
                 ProfileView(appStateViewModel: appStateViewModel),
           ),
         ],
       );

  final AppStateViewModel appStateViewModel;
  final MapViewModel mapViewModel;
  final PermissionsViewModel permissionsViewModel;
  final GpxImportViewModel gpxImportViewModel;
  final GoRouter _router;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppStateViewModel>.value(
          value: appStateViewModel,
        ),
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
        theme: buildAppTheme(),
        routerConfig: _router,
      ),
    );
  }
}
