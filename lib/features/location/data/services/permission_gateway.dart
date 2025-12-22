import '../models/permission_status.dart';

/// Defines a testable gateway for location permission queries and requests.
abstract class PermissionGateway {
  Future<PermissionStatus> getForegroundStatus();

  Future<PermissionStatus> requestForeground();

  Future<PermissionStatus> getBackgroundStatus();

  Future<PermissionStatus> requestBackground();

  Future<bool> isPermanentlyDenied();
}
