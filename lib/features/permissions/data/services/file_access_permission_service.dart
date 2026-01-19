import 'package:permission_handler/permission_handler.dart' as permission_handler;

import '../../../location/data/services/location_permission_service.dart';
import '../../../location/data/services/platform_info.dart';

abstract class FileAccessPermissionService {
  Future<bool> isGranted();

  Future<bool> request();
}

class PermissionHandlerFileAccessPermissionService
    implements FileAccessPermissionService {
  PermissionHandlerFileAccessPermissionService({
    required PermissionHandlerClient client,
    required PlatformInfo platformInfo,
  })  : _client = client,
        _platformInfo = platformInfo;

  final PermissionHandlerClient _client;
  final PlatformInfo _platformInfo;

  @override
  Future<bool> isGranted() async {
    if (!_isFileAccessSupported()) {
      return true;
    }
    final status = await _client.status(_storagePermission());
    return _isGrantedStatus(status);
  }

  @override
  Future<bool> request() async {
    if (!_isFileAccessSupported()) {
      return true;
    }
    final status = await _client.request(_storagePermission());
    return _isGrantedStatus(status);
  }

  bool _isFileAccessSupported() {
    final sdkInt = _platformInfo.androidSdkInt;
    if (!_platformInfo.isAndroid || sdkInt == null) {
      return false;
    }
    return sdkInt < 33;
  }

  permission_handler.Permission _storagePermission() {
    return permission_handler.Permission.storage;
  }

  bool _isGrantedStatus(permission_handler.PermissionStatus status) {
    return status == permission_handler.PermissionStatus.granted ||
        status == permission_handler.PermissionStatus.limited;
  }
}
