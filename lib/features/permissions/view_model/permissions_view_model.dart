import 'package:flutter/foundation.dart';

import '../data/models/app_permission.dart';
import '../data/repositories/permissions_repository.dart';

class PermissionsFeedback {
  const PermissionsFeedback({
    required this.id,
    required this.messageKey,
    this.isError = false,
  });

  final int id;
  final String messageKey;
  final bool isError;
}

class PermissionsViewState {
  const PermissionsViewState({
    required this.isLoading,
    required this.permissions,
    this.activeRequest,
    this.feedback,
  });

  factory PermissionsViewState.initial() {
    return const PermissionsViewState(
      isLoading: false,
      permissions: <AppPermissionStatus>[],
    );
  }

  final bool isLoading;
  final List<AppPermissionStatus> permissions;
  final AppPermissionType? activeRequest;
  final PermissionsFeedback? feedback;

  PermissionsViewState copyWith({
    bool? isLoading,
    List<AppPermissionStatus>? permissions,
    AppPermissionType? activeRequest,
    PermissionsFeedback? feedback,
    bool clearFeedback = false,
  }) {
    return PermissionsViewState(
      isLoading: isLoading ?? this.isLoading,
      permissions: permissions ?? this.permissions,
      activeRequest: activeRequest ?? this.activeRequest,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
    );
  }
}

class PermissionsViewModel extends ChangeNotifier {
  PermissionsViewModel({required PermissionsRepository repository})
      : _repository = repository,
        _state = PermissionsViewState.initial();

  final PermissionsRepository _repository;

  PermissionsViewState _state;
  int _feedbackId = 0;

  PermissionsViewState get state => _state;

  Future<void> refresh() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final permissions = await _repository.fetchPermissions();
      _state = _state.copyWith(
        isLoading: false,
        permissions: permissions,
      );
    } catch (_) {
      _state = _state.copyWith(
        isLoading: false,
        feedback: _feedback('permissions_error_generic', isError: true),
      );
    }

    notifyListeners();
  }

  Future<void> requestPermission(AppPermissionType type) async {
    if (_state.isLoading) {
      return;
    }

    _state = _state.copyWith(isLoading: true, activeRequest: type);
    notifyListeners();

    try {
      await _repository.requestPermission(type);
    } catch (_) {
      _state = _state.copyWith(
        feedback: _feedback('permissions_error_generic', isError: true),
      );
    }

    _state = _state.copyWith(activeRequest: null);
    await refresh();
  }

  PermissionsFeedback _feedback(String messageKey, {bool isError = false}) {
    _feedbackId += 1;
    return PermissionsFeedback(
      id: _feedbackId,
      messageKey: messageKey,
      isError: isError,
    );
  }
}
