import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/app_state/data/models/app_permission.dart';
import '../../../features/app_state/view_model/app_state_view_model.dart';
import '../../../translations/locale_keys.g.dart';
import '../../../ui/core/app_colors.dart';
import '../../../ui/core/widgets/app_back_button.dart';
import '../../../ui/core/widgets/hex_mascot.dart';

class PermissionsGateView extends StatefulWidget {
  const PermissionsGateView({required this.appStateViewModel, super.key});

  final AppStateViewModel appStateViewModel;

  @override
  State<PermissionsGateView> createState() => _PermissionsGateViewState();
}

class _PermissionsGateViewState extends State<PermissionsGateView> {
  bool _isGranting = false;

  @override
  Widget build(BuildContext context) {
    final permissions = widget.appStateViewModel.permissions;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AnimatedBuilder(
            animation: widget.appStateViewModel,
            builder: (context, _) {
              return ListView(
                children: [
                  Row(children: [AppBackButton(onPressed: _handleBack)]),
                  const SizedBox(height: 18),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  Text(
                    LocaleKeys.permissions_required_label.tr(),
                    style: const TextStyle(
                      color: AppColors.slate500,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PermissionRow(
                    icon: Icons.location_on_outlined,
                    title: LocaleKeys.permissions_precise_location.tr(),
                    state:
                        permissions[TrackingPermissionType.location] ??
                        PermissionGrantState.prompt,
                  ),
                  const SizedBox(height: 10),
                  _PermissionRow(
                    icon: Icons.location_on_outlined,
                    title: LocaleKeys.permissions_background_location.tr(),
                    state:
                        permissions[TrackingPermissionType
                            .backgroundLocation] ??
                        PermissionGrantState.prompt,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    LocaleKeys.permissions_optional_label.tr(),
                    style: const TextStyle(
                      color: AppColors.slate400,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PermissionRow(
                    icon: Icons.directions_run,
                    title: LocaleKeys.permissions_motion_activity.tr(),
                    state:
                        permissions[TrackingPermissionType.motion] ??
                        PermissionGrantState.prompt,
                  ),
                  const SizedBox(height: 10),
                  _PermissionRow(
                    icon: Icons.notifications_none,
                    title: LocaleKeys.permissions_notifications.tr(),
                    state:
                        permissions[TrackingPermissionType.notifications] ??
                        PermissionGrantState.prompt,
                  ),
                  const SizedBox(height: 10),
                  _PermissionRow(
                    icon: Icons.folder_outlined,
                    title: LocaleKeys.permissions_file_access.tr(),
                    state:
                        permissions[TrackingPermissionType.files] ??
                        PermissionGrantState.prompt,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.slate900,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isGranting ? null : _grantRequiredPermissions,
                      child: _isGranting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              LocaleKeys.permissions_action_grant_required.tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: _continueInLimitedMode,
                      child: Text(
                        LocaleKeys.permissions_action_continue_limited.tr(),
                        style: const TextStyle(color: AppColors.slate500),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.slate200),
            ),
            child: const Center(
              child: HexMascot(pose: HexMascotPose.checklist, size: 96),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            LocaleKeys.permissions_title_enable_tracking.tr(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            LocaleKeys.permissions_subtitle.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.slate500),
          ),
        ],
      ),
    );
  }

  Future<void> _grantRequiredPermissions() async {
    setState(() {
      _isGranting = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 800));

    final updatedPermissions =
        Map<TrackingPermissionType, PermissionGrantState>.from(
            widget.appStateViewModel.permissions,
          )
          ..[TrackingPermissionType.location] = PermissionGrantState.granted
          ..[TrackingPermissionType.backgroundLocation] =
              PermissionGrantState.granted;

    await widget.appStateViewModel.setPermissions(updatedPermissions);
    await widget.appStateViewModel.setHasSeenOnboarding(true);

    if (!mounted) {
      return;
    }

    setState(() {
      _isGranting = false;
    });
    context.go('/');
  }

  Future<void> _continueInLimitedMode() async {
    await widget.appStateViewModel.setHasSeenOnboarding(true);
    if (!mounted) {
      return;
    }
    context.go('/');
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    if (!widget.appStateViewModel.hasSeenOnboarding) {
      context.go('/onboarding');
      return;
    }
    context.go('/');
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.icon,
    required this.title,
    required this.state,
  });

  final IconData icon;
  final String title;
  final PermissionGrantState state;

  @override
  Widget build(BuildContext context) {
    final granted = state == PermissionGrantState.granted;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: granted ? AppColors.slate100 : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: granted ? Colors.transparent : AppColors.slate200,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: granted ? AppColors.slate900 : AppColors.slate500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.slate900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _PermissionStatusBadge(granted: granted),
        ],
      ),
    );
  }
}

class _PermissionStatusBadge extends StatelessWidget {
  const _PermissionStatusBadge({required this.granted});

  final bool granted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: granted ? AppColors.slate900 : AppColors.slate100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (granted)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.check, size: 12, color: Colors.white),
            ),
          Text(
            granted
                ? LocaleKeys.permissions_status_granted_caps.tr()
                : LocaleKeys.permissions_status_not_granted_caps.tr(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: granted ? Colors.white : AppColors.slate500,
            ),
          ),
        ],
      ),
    );
  }
}
