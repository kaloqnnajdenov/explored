import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_state/view_model/app_state_view_model.dart';
import '../../../translations/locale_keys.g.dart';
import '../../../ui/core/app_colors.dart';
import '../../../ui/core/widgets/app_back_button.dart';
import '../../../ui/core/widgets/coming_soon.dart';
import '../../../ui/core/widgets/hex_mascot.dart';
import '../../../ui/core/widgets/not_implemented_badge.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({required this.appStateViewModel, super.key});

  final AppStateViewModel appStateViewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    AppBackButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                          return;
                        }
                        context.go('/');
                      },
                    ),
                    const SizedBox(width: 12),
                    Text(
                      LocaleKeys.profile_title.tr(),
                      style: const TextStyle(
                        color: AppColors.slate900,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.list(
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 16),
                  _buildStatsGrid(),
                  const SizedBox(height: 16),
                  _buildAchievements(context),
                  const SizedBox(height: 16),
                  _buildAccountSection(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.emerald50,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: HexMascot(pose: HexMascotPose.celebrate, size: 180),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.emerald500,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    LocaleKeys.profile_level_badge.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            LocaleKeys.profile_name.tr(),
            style: const TextStyle(
              color: AppColors.slate900,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            LocaleKeys.profile_member_since.tr(),
            style: const TextStyle(color: AppColors.slate500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 1.25,
        children: [
          _StatCell(label: LocaleKeys.profile_stat_regions_visited.tr()),
          _StatCell(label: LocaleKeys.profile_stat_total_distance.tr()),
          _StatCell(label: LocaleKeys.profile_stat_days_active.tr()),
          _StatCell(label: LocaleKeys.profile_stat_explored.tr()),
        ],
      ),
    );
  }

  Widget _buildAchievements(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.profile_achievements_title.tr(),
          style: const TextStyle(
            color: AppColors.slate900,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        _AchievementCard(
          icon: Icons.directions_run,
          title: LocaleKeys.profile_achievement_peak_bagger.tr(),
          date: LocaleKeys.profile_achievement_date_1.tr(),
          onTap: () => showComingSoonSnackBar(context),
        ),
        const SizedBox(height: 8),
        _AchievementCard(
          icon: Icons.notifications_none,
          title: LocaleKeys.profile_achievement_early_bird.tr(),
          date: LocaleKeys.profile_achievement_date_2.tr(),
          onTap: () => showComingSoonSnackBar(context),
        ),
        const SizedBox(height: 8),
        _AchievementCard(
          icon: Icons.place_outlined,
          title: LocaleKeys.profile_achievement_trailblazer.tr(),
          date: LocaleKeys.profile_achievement_date_3.tr(),
          onTap: () => showComingSoonSnackBar(context),
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Column(
        children: [
          _ProfileActionRow(
            label: LocaleKeys.profile_action_edit_profile.tr(),
            onTap: () => showComingSoonSnackBar(context),
          ),
          const Divider(height: 1, color: AppColors.slate100),
          _ProfileActionRow(
            label: LocaleKeys.profile_action_notifications.tr(),
            onTap: () => showComingSoonSnackBar(context),
          ),
          const Divider(height: 1, color: AppColors.slate100),
          _ProfileActionRow(
            label: LocaleKeys.profile_action_privacy.tr(),
            onTap: () => showComingSoonSnackBar(context),
          ),
          const Divider(height: 1, color: AppColors.slate100),
          _ProfileActionRow(
            label: LocaleKeys.profile_action_sign_out.tr(),
            color: AppColors.rose600,
            onTap: () => showComingSoonSnackBar(context),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'XXX',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.slate400,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          const NotImplementedBadge(),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.icon,
    required this.title,
    required this.date,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.slate100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.yellow50,
              ),
              child: Icon(icon, color: AppColors.yellow600, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.slate900,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              date,
              style: const TextStyle(color: AppColors.slate400, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileActionRow extends StatelessWidget {
  const _ProfileActionRow({
    required this.label,
    required this.onTap,
    this.color = AppColors.slate900,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.slate400),
          ],
        ),
      ),
    );
  }
}
