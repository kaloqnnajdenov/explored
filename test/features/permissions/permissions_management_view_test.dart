import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/permissions/data/models/app_permission.dart';
import 'package:explored/features/permissions/data/repositories/permissions_repository.dart';
import 'package:explored/features/permissions/view/permissions_management_view.dart';
import 'package:explored/features/permissions/view_model/permissions_view_model.dart';
import '../../test_utils/localization_test_utils.dart';

class FakePermissionsRepository implements PermissionsRepository {
  @override
  Future<List<AppPermissionStatus>> fetchPermissions() async {
    return const [
      AppPermissionStatus(
        type: AppPermissionType.locationForeground,
        isGranted: true,
      ),
      AppPermissionStatus(
        type: AppPermissionType.locationBackground,
        isGranted: false,
      ),
      AppPermissionStatus(
        type: AppPermissionType.notifications,
        isGranted: false,
      ),
      AppPermissionStatus(
        type: AppPermissionType.fileAccess,
        isGranted: true,
      ),
    ];
  }

  @override
  Future<void> requestPermission(AppPermissionType type) async {}

  @override
  Future<void> requestInitialPermissionsIfNeeded() async {}
}

void main() {
  testWidgets('permissions management text fits without overflow',
      (tester) async {
    final viewModel =
        PermissionsViewModel(repository: FakePermissionsRepository());

    final app = await buildLocalizedTestApp(
      PermissionsManagementView(viewModel: viewModel),
    );
    tester.binding.window.physicalSizeTestValue = const Size(320, 640);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);

    await tester.pumpWidget(app);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
  });
}
