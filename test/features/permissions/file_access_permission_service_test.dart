import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

import 'package:explored/features/location/data/services/location_permission_service.dart';
import 'package:explored/features/location/data/services/platform_info.dart';
import 'package:explored/features/permissions/data/services/file_access_permission_service.dart';

class FakePlatformInfo implements PlatformInfo {
  FakePlatformInfo({
    required this.isAndroid,
    required this.isIOS,
    required this.androidSdkInt,
  });

  @override
  final bool isAndroid;

  @override
  final bool isIOS;

  @override
  final int? androidSdkInt;
}

class FakePermissionHandlerClient implements PermissionHandlerClient {
  FakePermissionHandlerClient({
    required this.statusValue,
  });

  permission_handler.PermissionStatus statusValue;
  permission_handler.Permission? lastPermission;
  int requestCalls = 0;
  int statusCalls = 0;

  @override
  Future<permission_handler.PermissionStatus> request(
    permission_handler.Permission permission,
  ) async {
    requestCalls += 1;
    lastPermission = permission;
    return statusValue;
  }

  @override
  Future<permission_handler.PermissionStatus> status(
    permission_handler.Permission permission,
  ) async {
    statusCalls += 1;
    lastPermission = permission;
    return statusValue;
  }

  @override
  Future<permission_handler.ServiceStatus> serviceStatus(
    permission_handler.PermissionWithService permission,
  ) async {
    return permission_handler.ServiceStatus.enabled;
  }

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openNotificationSettings() async => true;
}

void main() {
  test('Non-Android platforms treat file access as granted', () async {
    final client = FakePermissionHandlerClient(
      statusValue: permission_handler.PermissionStatus.denied,
    );
    final service = PermissionHandlerFileAccessPermissionService(
      client: client,
      platformInfo: FakePlatformInfo(
        isAndroid: false,
        isIOS: true,
        androidSdkInt: null,
      ),
    );

    final granted = await service.isGranted();
    final requested = await service.request();

    expect(granted, isTrue);
    expect(requested, isTrue);
    expect(client.statusCalls, 0);
    expect(client.requestCalls, 0);
  });

  test('Android with unknown SDK treats file access as granted', () async {
    final client = FakePermissionHandlerClient(
      statusValue: permission_handler.PermissionStatus.denied,
    );
    final service = PermissionHandlerFileAccessPermissionService(
      client: client,
      platformInfo: FakePlatformInfo(
        isAndroid: true,
        isIOS: false,
        androidSdkInt: null,
      ),
    );

    final granted = await service.isGranted();
    final requested = await service.request();

    expect(granted, isTrue);
    expect(requested, isTrue);
    expect(client.statusCalls, 0);
    expect(client.requestCalls, 0);
  });

  test('Android below SDK 33 requests storage permission', () async {
    final client = FakePermissionHandlerClient(
      statusValue: permission_handler.PermissionStatus.denied,
    );
    final service = PermissionHandlerFileAccessPermissionService(
      client: client,
      platformInfo: FakePlatformInfo(
        isAndroid: true,
        isIOS: false,
        androidSdkInt: 30,
      ),
    );

    final granted = await service.isGranted();
    expect(granted, isFalse);
    expect(client.lastPermission, permission_handler.Permission.storage);

    client.statusValue = permission_handler.PermissionStatus.granted;
    final requested = await service.request();
    expect(requested, isTrue);
    expect(client.lastPermission, permission_handler.Permission.storage);
  });
}
