import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/permissions/data/models/app_permission.dart';
import 'package:explored/features/permissions/data/repositories/permissions_repository.dart';
import 'package:explored/features/permissions/view_model/permissions_view_model.dart';

class FakePermissionsRepository implements PermissionsRepository {
  List<AppPermissionStatus> permissions = const [];
  int fetchCalls = 0;
  int requestCalls = 0;
  int openSettingsCalls = 0;
  bool throwsOnRequest = false;

  @override
  Future<List<AppPermissionStatus>> fetchPermissions() async {
    fetchCalls += 1;
    return permissions;
  }

  @override
  Future<void> requestPermission(AppPermissionType type) async {
    if (throwsOnRequest) {
      throw Exception('request failed');
    }
    requestCalls += 1;
  }

  @override
  Future<void> openPermissionSettings(AppPermissionType type) async {
    openSettingsCalls += 1;
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

  test(
    'setPermissionEnabled true triggers repository request and refresh',
    () async {
      final repository = FakePermissionsRepository()
        ..permissions = const [
          AppPermissionStatus(
            type: AppPermissionType.locationForeground,
            isGranted: false,
          ),
        ];
      final viewModel = PermissionsViewModel(repository: repository);

      await viewModel.setPermissionEnabled(
        AppPermissionType.locationForeground,
        true,
      );

      expect(repository.requestCalls, 1);
      expect(repository.fetchCalls, 1);
    },
  );

  test(
    'setPermissionEnabled false opens settings without immediate refresh',
    () async {
      final repository = FakePermissionsRepository()
        ..permissions = const [
          AppPermissionStatus(
            type: AppPermissionType.locationForeground,
            isGranted: true,
          ),
        ];
      final viewModel = PermissionsViewModel(repository: repository);

      await viewModel.setPermissionEnabled(
        AppPermissionType.locationForeground,
        false,
      );

      expect(repository.openSettingsCalls, 1);
      expect(repository.requestCalls, 0);
      expect(repository.fetchCalls, 0);
      expect(
        viewModel.state.feedback?.messageKey,
        'permissions_feedback_manage_in_settings',
      );
    },
  );

  test('setPermissionEnabled ignores non-interactive permissions', () async {
    final repository = FakePermissionsRepository()
      ..permissions = const [
        AppPermissionStatus(
          type: AppPermissionType.motionActivity,
          isGranted: false,
          isInteractive: false,
          helperMessageKey: 'permissions_helper_coming_soon',
        ),
      ];
    final viewModel = PermissionsViewModel(repository: repository);
    await viewModel.refresh();

    await viewModel.setPermissionEnabled(
      AppPermissionType.motionActivity,
      true,
    );

    expect(repository.requestCalls, 0);
    expect(repository.openSettingsCalls, 0);
  });

  test('setPermissionEnabled sets error feedback on failure', () async {
    final repository = FakePermissionsRepository()
      ..permissions = const [
        AppPermissionStatus(
          type: AppPermissionType.locationForeground,
          isGranted: false,
        ),
      ]
      ..throwsOnRequest = true;
    final viewModel = PermissionsViewModel(repository: repository);

    await viewModel.setPermissionEnabled(
      AppPermissionType.locationForeground,
      true,
    );

    expect(viewModel.state.feedback?.messageKey, 'permissions_error_generic');
    expect(viewModel.state.feedback?.isError, isTrue);
  });
}
