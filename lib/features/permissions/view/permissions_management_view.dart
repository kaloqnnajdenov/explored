import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../translations/locale_keys.g.dart';
import '../view_model/permissions_view_model.dart';
import 'widgets/permission_status_tile.dart';

class PermissionsManagementView extends StatefulWidget {
  const PermissionsManagementView({
    required this.viewModel,
    super.key,
  });

  final PermissionsViewModel viewModel;

  @override
  State<PermissionsManagementView> createState() =>
      _PermissionsManagementViewState();
}

class _PermissionsManagementViewState extends State<PermissionsManagementView> {
  int? _lastFeedbackId;

  @override
  void initState() {
    super.initState();
    widget.viewModel.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        final state = widget.viewModel.state;
        _handleFeedback(state);

        return Material(
          color: Theme.of(context).colorScheme.surface,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 12),
                  if (state.isLoading && state.permissions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: state.permissions.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final permission = state.permissions[index];
                          return PermissionStatusTile(
                            permission: permission,
                            isBusy: state.isLoading,
                            onRequest: () => widget.viewModel
                                .requestPermission(permission.type),
                          );
                        },
                      ),
                    ),
                  if (state.isLoading && state.permissions.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: LinearProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            LocaleKeys.permissions_title.tr(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        IconButton(
          tooltip: LocaleKeys.permissions_action_close.tr(),
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  void _handleFeedback(PermissionsViewState state) {
    final feedback = state.feedback;
    if (feedback == null || feedback.id == _lastFeedbackId) {
      return;
    }
    _lastFeedbackId = feedback.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(feedback.messageKey.tr()),
          backgroundColor: feedback.isError
              ? Theme.of(context).colorScheme.error
              : null,
        ),
      );
    });
  }
}
