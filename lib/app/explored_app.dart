import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../features/app_state/view_model/app_state_view_model.dart';
import '../features/entity_detail/view/entity_detail_view.dart';
import '../features/entity_detail/view_model/entity_details_view_model.dart';
import '../features/exploration/data/repositories/entity_repository.dart';
import '../features/exploration/data/repositories/progress_repository.dart';
import '../features/exploration/data/repositories/selection_repository.dart';
import '../features/gpx_import/view_model/gpx_import_view_model.dart';
import '../features/map/view/map_view.dart';
import '../features/map/view_model/map_view_model.dart';
import '../features/onboarding/view/onboarding_view.dart';
import '../features/permission_gate/view/permissions_gate_view.dart';
import '../features/permissions/view/permissions_management_view.dart';
import '../features/permissions/view_model/permissions_view_model.dart';
import '../features/profile/view/profile_view.dart';
import '../features/progress_home/view/progress_home_view.dart';
import '../features/progress_home/view_model/progress_view_model.dart';
import '../features/settings/view/settings_view.dart';
import '../translations/locale_keys.g.dart';
import '../ui/core/app_theme.dart';

class ExploredApp extends StatelessWidget {
  ExploredApp({
    required this.appStateViewModel,
    required this.mapViewModel,
    required this.permissionsViewModel,
    required this.gpxImportViewModel,
    required this.progressViewModel,
    required this.entityRepository,
    required this.selectionRepository,
    required this.progressRepository,
    this.initialLocation,
    super.key,
  }) : _router = GoRouter(
         initialLocation: initialLocation,
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
               progressViewModel: progressViewModel,
               mapViewModel: mapViewModel,
               entityRepository: entityRepository,
               selectionRepository: selectionRepository,
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
             path: '/entity/:id',
             builder: (_, state) => EntityDetailView(
               entityId: state.pathParameters['id']!,
               mapViewModel: mapViewModel,
               viewModel: EntityDetailsViewModel(
                 entityRepository: entityRepository,
                 progressRepository: progressRepository,
               ),
             ),
           ),
           GoRoute(
             path: '/pack/:id',
             redirect: (_, state) => '/entity/${state.pathParameters['id']!}',
           ),
           GoRoute(
             path: '/region/:id',
             redirect: (_, state) => '/entity/${state.pathParameters['id']!}',
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
  final ProgressViewModel progressViewModel;
  final EntityRepository entityRepository;
  final SelectionRepository selectionRepository;
  final ProgressRepository progressRepository;
  final String? initialLocation;
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
        ChangeNotifierProvider<ProgressViewModel>.value(
          value: progressViewModel,
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
