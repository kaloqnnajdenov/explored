import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/permissions/data/models/app_permission.dart';
import 'package:explored/features/permissions/data/repositories/permissions_repository.dart';
import 'package:explored/features/permissions/view/permissions_management_view.dart';
import 'package:explored/features/permissions/view_model/permissions_view_model.dart';
import '../../test_utils/localization_test_utils.dart';

class FakePermissionsRepository implements PermissionsRepository {
  FakePermissionsRepository({
    this.permissions = const <AppPermissionStatus>[
      AppPermissionStatus(
        type: AppPermissionType.locationForeground,
        isGranted: true,
      ),
      AppPermissionStatus(
        type: AppPermissionType.locationBackground,
        isGranted: false,
      ),
      AppPermissionStatus(
        type: AppPermissionType.motionActivity,
        isGranted: false,
        isInteractive: false,
        helperMessageKey: 'permissions_helper_coming_soon',
      ),
      AppPermissionStatus(
        type: AppPermissionType.notifications,
        isGranted: false,
      ),
      AppPermissionStatus(
        type: AppPermissionType.fileAccess,
        isGranted: true,
        isInteractive: false,
        helperMessageKey: 'permissions_helper_not_required_on_device',
      ),
    ],
  });

  List<AppPermissionStatus> permissions;
  int requestCalls = 0;
  int openSettingsCalls = 0;

  @override
  Future<List<AppPermissionStatus>> fetchPermissions() async {
    return permissions;
  }

  @override
  Future<void> requestPermission(AppPermissionType type) async {
    requestCalls += 1;
  }

  @override
  Future<void> requestInitialPermissionsIfNeeded() async {}

  @override
  Future<void> openPermissionSettings(AppPermissionType type) async {
    openSettingsCalls += 1;
  }
}

void main() {
  testWidgets('permissions management text fits without overflow', (
    tester,
  ) async {
    final viewModel = PermissionsViewModel(
      repository: FakePermissionsRepository(),
    );

    final app = await buildLocalizedTestApp(
      Scaffold(body: PermissionsManagementView(viewModel: viewModel)),
    );
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(Switch), findsNWidgets(5));
    expect(find.text('Coming soon.'), findsOneWidget);
    expect(find.text('Not required on this device.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('toggle off opens settings flow', (tester) async {
    final repository = FakePermissionsRepository();
    final viewModel = PermissionsViewModel(repository: repository);
    final app = await buildLocalizedTestApp(
      Scaffold(body: PermissionsManagementView(viewModel: viewModel)),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    await tester.tap(find.byWidget(switches.first));
    await tester.pumpAndSettle();

    expect(repository.openSettingsCalls, 1);
    expect(repository.requestCalls, 0);
  });

  testWidgets('refreshes permission state when app resumes', (tester) async {
    final repository = FakePermissionsRepository(
      permissions: const [
        AppPermissionStatus(
          type: AppPermissionType.locationForeground,
          isGranted: true,
        ),
        AppPermissionStatus(
          type: AppPermissionType.locationBackground,
          isGranted: false,
        ),
        AppPermissionStatus(
          type: AppPermissionType.motionActivity,
          isGranted: false,
          isInteractive: false,
          helperMessageKey: 'permissions_helper_coming_soon',
        ),
        AppPermissionStatus(
          type: AppPermissionType.notifications,
          isGranted: false,
        ),
        AppPermissionStatus(
          type: AppPermissionType.fileAccess,
          isGranted: true,
          isInteractive: false,
          helperMessageKey: 'permissions_helper_not_required_on_device',
        ),
      ],
    );
    final viewModel = PermissionsViewModel(repository: repository);
    final app = await buildLocalizedTestApp(
      Scaffold(body: PermissionsManagementView(viewModel: viewModel)),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch).first).value, isTrue);

    repository.permissions = const [
      AppPermissionStatus(
        type: AppPermissionType.locationForeground,
        isGranted: false,
      ),
      AppPermissionStatus(
        type: AppPermissionType.locationBackground,
        isGranted: false,
      ),
      AppPermissionStatus(
        type: AppPermissionType.motionActivity,
        isGranted: false,
        isInteractive: false,
        helperMessageKey: 'permissions_helper_coming_soon',
      ),
      AppPermissionStatus(
        type: AppPermissionType.notifications,
        isGranted: false,
      ),
      AppPermissionStatus(
        type: AppPermissionType.fileAccess,
        isGranted: true,
        isInteractive: false,
        helperMessageKey: 'permissions_helper_not_required_on_device',
      ),
    ];

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(find.byType(Switch).first).value, isFalse);
  });
}
