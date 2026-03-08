import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_state/data/models/region.dart';
import '../../app_state/view_model/app_state_view_model.dart';
import '../../../translations/locale_keys.g.dart';
import '../../../ui/core/app_colors.dart';
import '../../../ui/core/widgets/app_back_button.dart';
import '../../../ui/core/widgets/coming_soon.dart';
import '../../../ui/core/widgets/hex_mascot.dart';
import '../../../ui/core/widgets/not_implemented_badge.dart';
import '../../../ui/core/widgets/placeholder_metric_value.dart';

class RegionDetailView extends StatefulWidget {
  const RegionDetailView({
    required this.appStateViewModel,
    required this.regionId,
    super.key,
  });

  final AppStateViewModel appStateViewModel;
  final String regionId;

  @override
  State<RegionDetailView> createState() => _RegionDetailViewState();
}

class _RegionDetailViewState extends State<RegionDetailView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _downloadPromptShown = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appStateViewModel,
      builder: (context, _) {
        final region = _region();

        if (!region.isDownloaded && !_downloadPromptShown) {
          _downloadPromptShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            _showDownloadPrompt(region);
          });
        }

        return Scaffold(
          backgroundColor: AppColors.slate50,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      AppBackButton(onPressed: _handleBack),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              region.name,
                              style: const TextStyle(
                                color: AppColors.slate900,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  LocaleKeys.region_detail_stats_placeholder
                                      .tr(),
                                  style: const TextStyle(
                                    color: AppColors.slate500,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const NotImplementedBadge(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/map'),
                        icon: const Icon(Icons.map_outlined, size: 16),
                        label: Text(LocaleKeys.region_detail_action_map.tr()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.emerald700,
                          side: const BorderSide(color: AppColors.emerald200),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: const PlaceholderMetricValue(fontSize: 24),
                  ),
                ),
                const SizedBox(height: 10),
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.emerald600,
                  labelColor: AppColors.emerald700,
                  unselectedLabelColor: AppColors.slate500,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    _FeatureTab(
                      icon: Icons.hiking,
                      label: LocaleKeys.region_detail_tab_trails.tr(),
                      count: region.features.trails.total,
                    ),
                    _FeatureTab(
                      icon: Icons.terrain,
                      label: LocaleKeys.region_detail_tab_peaks.tr(),
                      count: region.features.peaks.total,
                    ),
                    _FeatureTab(
                      icon: Icons.cabin,
                      label: LocaleKeys.region_detail_tab_huts.tr(),
                      count: region.features.huts.total,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: (_) => showComingSoonSnackBar(context),
                          decoration: InputDecoration(
                            hintText: LocaleKeys.region_detail_search_hint.tr(),
                            prefixIcon: const Icon(Icons.search),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () => showComingSoonSnackBar(context),
                        icon: const Icon(Icons.tune),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _FeatureList(
                        icon: Icons.hiking,
                        onTapItem: () => showComingSoonSnackBar(context),
                      ),
                      _FeatureList(
                        icon: Icons.terrain,
                        onTapItem: () => showComingSoonSnackBar(context),
                      ),
                      _FeatureList(
                        icon: Icons.cabin,
                        onTapItem: () => showComingSoonSnackBar(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Region _region() {
    return widget.appStateViewModel.regions.firstWhere(
      (region) => region.id == widget.regionId,
      orElse: () => widget.appStateViewModel.currentRegion,
    );
  }

  Future<void> _showDownloadPrompt(Region region) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HexMascot(pose: HexMascotPose.mapUnroll, size: 72),
              const SizedBox(height: 8),
              Text(
                LocaleKeys.region_detail_download_prompt_title.tr(
                  namedArgs: {'region': region.name},
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                LocaleKeys.region_detail_download_prompt_subtitle.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.slate500),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.emerald900,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await widget.appStateViewModel.downloadRegion(region.id);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(LocaleKeys.region_detail_download_action.tr()),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(LocaleKeys.region_detail_download_later.tr()),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/');
  }
}

class _FeatureTab extends StatelessWidget {
  const _FeatureTab({
    required this.icon,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).tabBarTheme.labelColor ==
                      AppColors.emerald700
                  ? AppColors.emerald100
                  : AppColors.slate100,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList({required this.icon, required this.onTapItem});

  final IconData icon;
  final VoidCallback onTapItem;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: 9,
      itemBuilder: (context, index) {
        if (index == 8) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix(<double>[
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ]),
                  child: const HexMascot(pose: HexMascotPose.idle, size: 120),
                ),
                const SizedBox(height: 6),
                Text(
                  LocaleKeys.region_detail_end_of_list.tr(),
                  style: const TextStyle(color: AppColors.slate500),
                ),
              ],
            ),
          );
        }

        final visited = index % 3 == 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTapItem,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slate100),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: visited
                          ? AppColors.emerald100
                          : AppColors.slate100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 17,
                      color: visited
                          ? AppColors.emerald600
                          : AppColors.slate400,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      LocaleKeys.region_detail_item_name.tr(
                        namedArgs: {'index': (index + 1).toString()},
                      ),
                      style: const TextStyle(
                        color: AppColors.slate900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    visited
                        ? Icons.check_circle_outline
                        : Icons.circle_outlined,
                    color: visited ? AppColors.emerald600 : AppColors.slate400,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
