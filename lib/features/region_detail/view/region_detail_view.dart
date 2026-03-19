import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_state/view_model/app_state_view_model.dart';
import '../../region_catalog/data/models/region_pack_kind.dart';
import '../../region_catalog/data/models/region_pack_node.dart';
import '../../../translations/locale_keys.g.dart';
import '../../../ui/core/app_colors.dart';
import '../../../ui/core/widgets/app_back_button.dart';
import '../../../ui/core/widgets/hex_mascot.dart';
import '../../../ui/core/widgets/not_implemented_badge.dart';
import '../../../ui/core/widgets/placeholder_metric_value.dart';

class PackDetailView extends StatefulWidget {
  const PackDetailView({
    required this.appStateViewModel,
    required this.packId,
    super.key,
  });

  final AppStateViewModel appStateViewModel;
  final String packId;

  @override
  State<PackDetailView> createState() => _PackDetailViewState();
}

class _PackDetailViewState extends State<PackDetailView> {
  final TextEditingController _searchController = TextEditingController();
  bool _downloadPromptShown = false;
  String? _requestedChildrenForPackId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PackDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packId == widget.packId) {
      return;
    }

    _searchController.clear();
    _downloadPromptShown = false;
    _requestedChildrenForPackId = null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appStateViewModel,
      builder: (context, _) {
        final pack = _pack();
        if (pack == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!pack.isDownloaded && !_downloadPromptShown) {
          _downloadPromptShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            _showDownloadPrompt(pack);
          });
        }

        if (pack.hasChildren &&
            !widget.appStateViewModel.areChildrenLoaded(pack.id) &&
            !widget.appStateViewModel.isLoadingChildren(pack.id) &&
            _requestedChildrenForPackId != pack.id) {
          _requestedChildrenForPackId = pack.id;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            widget.appStateViewModel.ensureChildrenLoaded(pack.id);
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
                              pack.name,
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
                                  _subtitleForPack(pack),
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
                    child: _buildPrimaryMetric(pack),
                  ),
                ),
                if (pack.hasChildren) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: LocaleKeys.region_detail_search_hint.tr(),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _ChildPackList(
                      packs: _visibleChildPacks(pack),
                      isLoading: widget.appStateViewModel.isLoadingChildren(
                        pack.id,
                      ),
                      labelForKind: _labelForKind,
                      onTapPack: (childPack) =>
                          context.go('/pack/${childPack.id}'),
                    ),
                  ),
                ] else
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.slate100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocaleKeys.pack_detail_summary_title.tr(),
                              style: const TextStyle(
                                color: AppColors.slate900,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              pack.displayPath,
                              style: const TextStyle(
                                color: AppColors.slate600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const NotImplementedBadge(),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    LocaleKeys.pack_detail_summary_subtitle
                                        .tr(),
                                    style: const TextStyle(
                                      color: AppColors.slate500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  RegionPackNode? _pack() {
    return widget.appStateViewModel.packById(widget.packId) ??
        widget.appStateViewModel.selectedPackOrNull;
  }

  Future<void> _showDownloadPrompt(RegionPackNode pack) async {
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
                  namedArgs: {'region': pack.name},
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
                    await widget.appStateViewModel.downloadPack(pack.id);
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

  Widget _buildPrimaryMetric(RegionPackNode pack) {
    if (pack.kind == RegionPackKind.region) {
      return const PlaceholderMetricValue(fontSize: 24);
    }
    return Text(
      _labelForKind(pack.kind),
      style: const TextStyle(
        color: AppColors.emerald700,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  String _subtitleForPack(RegionPackNode pack) {
    if (pack.kind == RegionPackKind.region && !pack.hasChildren) {
      return LocaleKeys.region_detail_stats_placeholder.tr();
    }
    return _labelForKind(pack.kind);
  }

  List<RegionPackNode> _visibleChildPacks(RegionPackNode pack) {
    final query = _searchController.text.trim().toLowerCase();
    final children = widget.appStateViewModel.childrenOf(pack.id);
    if (query.isEmpty) {
      return children;
    }

    return children
        .where((child) {
          final name = child.name.toLowerCase();
          final displayPath = child.displayPath.toLowerCase();
          return name.contains(query) || displayPath.contains(query);
        })
        .toList(growable: false);
  }

  String _labelForKind(RegionPackKind kind) {
    switch (kind) {
      case RegionPackKind.country:
        return LocaleKeys.region_pack_kind_country.tr();
      case RegionPackKind.region:
        return LocaleKeys.region_pack_kind_region.tr();
      case RegionPackKind.city:
        return LocaleKeys.region_pack_kind_city.tr();
      case RegionPackKind.cityCenter:
        return LocaleKeys.region_pack_kind_city_center.tr();
    }
  }
}

class _ChildPackList extends StatelessWidget {
  const _ChildPackList({
    required this.packs,
    required this.isLoading,
    required this.labelForKind,
    required this.onTapPack,
  });

  final List<RegionPackNode> packs;
  final bool isLoading;
  final String Function(RegionPackKind kind) labelForKind;
  final ValueChanged<RegionPackNode> onTapPack;

  @override
  Widget build(BuildContext context) {
    if (packs.isEmpty) {
      return isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    LocaleKeys.region_finder_empty_title.tr(),
                    style: const TextStyle(color: AppColors.slate900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    LocaleKeys.region_finder_empty_subtitle.tr(),
                    style: const TextStyle(color: AppColors.slate500),
                  ),
                ],
              ),
            );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: packs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final pack = packs[index];
        return InkWell(
          key: ValueKey<String>('pack-child-${pack.id}'),
          borderRadius: BorderRadius.circular(12),
          onTap: () => onTapPack(pack),
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
                    color: AppColors.indigo50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _iconForKind(pack.kind),
                    size: 17,
                    color: AppColors.indigo600,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pack.name,
                        style: const TextStyle(
                          color: AppColors.slate900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        labelForKind(pack.kind),
                        style: const TextStyle(
                          color: AppColors.slate500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.slate400,
                  size: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _iconForKind(RegionPackKind kind) {
    switch (kind) {
      case RegionPackKind.country:
        return Icons.public;
      case RegionPackKind.region:
        return Icons.terrain;
      case RegionPackKind.city:
        return Icons.location_city;
      case RegionPackKind.cityCenter:
        return Icons.place;
    }
  }
}
