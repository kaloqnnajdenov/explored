enum TrackingPermissionType {
  location,
  backgroundLocation,
  motion,
  notifications,
  files,
}

enum PermissionGrantState { granted, denied, prompt }

extension TrackingPermissionTypeStorage on TrackingPermissionType {
  String get storageKey {
    switch (this) {
      case TrackingPermissionType.location:
        return 'location';
      case TrackingPermissionType.backgroundLocation:
        return 'backgroundLocation';
      case TrackingPermissionType.motion:
        return 'motion';
      case TrackingPermissionType.notifications:
        return 'notifications';
      case TrackingPermissionType.files:
        return 'files';
    }
  }

  static TrackingPermissionType fromStorageKey(String value) {
    return TrackingPermissionType.values.firstWhere(
      (permission) => permission.storageKey == value,
      orElse: () => TrackingPermissionType.location,
    );
  }
}

extension PermissionGrantStateStorage on PermissionGrantState {
  String get storageValue {
    switch (this) {
      case PermissionGrantState.granted:
        return 'granted';
      case PermissionGrantState.denied:
        return 'denied';
      case PermissionGrantState.prompt:
        return 'prompt';
    }
  }

  static PermissionGrantState fromStorageValue(String value) {
    return PermissionGrantState.values.firstWhere(
      (state) => state.storageValue == value,
      orElse: () => PermissionGrantState.prompt,
    );
  }
}
