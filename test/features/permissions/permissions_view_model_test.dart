import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/permissions/data/models/app_permission.dart';
import 'package:explored/features/permissions/data/repositories/permissions_repository.dart';
import 'package:explored/features/permissions/view_model/permissions_view_model.dart';

class FakePermissionsRepository implements PermissionsRepository {
  List<AppPermissionStatus> permissions = const [];
  int fetchCalls = 0;
  int requestCalls = 0;

  @override
  Future<List<AppPermissionStatus>> fetchPermissions() async {
    fetchCalls += 1;
    return permissions;
  }

  @override
  Future<void> requestPermission(AppPermissionType type) async {
    requestCalls += 1;
  }

  @override
  Future<void> requestInitialPermissionsIfNeeded() async {}
}

void main() {
  test('refresh loads permission statuses', () async {
    final repository = FakePermissionsRepository()
      ..permissions = const [
        AppPermissionStatus(
          type: AppPermissionType.locationForeground,
          isGranted: true,
        ),
      ];
    final viewModel = PermissionsViewModel(repository: repository);

    await viewModel.refresh();

    expect(viewModel.state.permissions.length, 1);
    expect(viewModel.state.permissions.first.isGranted, isTrue);
    expect(repository.fetchCalls, 1);
  });

  test('requestPermission triggers repository and refresh', () async {
    final repository = FakePermissionsRepository()
      ..permissions = const [
        AppPermissionStatus(
          type: AppPermissionType.locationForeground,
          isGranted: false,
        ),
      ];
    final viewModel = PermissionsViewModel(repository: repository);

    await viewModel.requestPermission(AppPermissionType.locationForeground);

    expect(repository.requestCalls, 1);
    expect(repository.fetchCalls, 1);
  });
}
