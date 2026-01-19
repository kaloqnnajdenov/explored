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
    return _parseAndroidSdkInt(Platform.operatingSystemVersion);
  }

  int? _parseAndroidSdkInt(String version) {
    final apiMatch = RegExp(r'(?:SDK|API)\s*(\d+)', caseSensitive: false)
        .firstMatch(version);
    if (apiMatch != null) {
      return int.tryParse(apiMatch.group(1)!);
    }

    final androidMatch =
        RegExp(r'Android\s+(\d+)', caseSensitive: false).firstMatch(version);
    if (androidMatch == null) {
      return null;
    }

    final major = int.tryParse(androidMatch.group(1)!);
    if (major == null) {
      return null;
    }

    if (major >= 13) {
      return 33 + (major - 13);
    }
    if (major == 12) {
      return 31;
    }
    if (major == 11) {
      return 30;
    }
    if (major == 10) {
      return 29;
    }
    return 28;
  }
}
