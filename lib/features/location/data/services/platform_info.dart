import 'dart:io';

/// Exposes platform flags so services can be unit tested without dart:io.
abstract class PlatformInfo {
  bool get isAndroid;
  bool get isIOS;
}

/// Uses dart:io to report the current runtime platform.
class DevicePlatformInfo implements PlatformInfo {
  @override
  bool get isAndroid => Platform.isAndroid;

  @override
  bool get isIOS => Platform.isIOS;
}
