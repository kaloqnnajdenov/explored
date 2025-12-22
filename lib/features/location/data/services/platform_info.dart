import 'dart:io';

/// Exposes platform flags so services can be unit tested without dart:io.
abstract class PlatformInfo {
  bool get isAndroid;
  bool get isIOS;

  /// Reports the Android SDK int when available, otherwise null.
  int? get androidSdkInt;
}

/// Uses dart:io to report the current runtime platform.
class DevicePlatformInfo implements PlatformInfo {
  @override
  bool get isAndroid => Platform.isAndroid;

  @override
  bool get isIOS => Platform.isIOS;

  @override
  int? get androidSdkInt {
    if (!Platform.isAndroid) {
      return null;
    }
    // Best-effort parse of "SDK xx" from the OS version string.
    final match =
        RegExp(r'SDK\s*(\d+)').firstMatch(Platform.operatingSystemVersion);
    if (match == null) {
      return null;
    }
    return int.tryParse(match.group(1)!);
  }
}
