import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../region_catalog/data/models/region_pack_kind.dart';
import '../../region_catalog/data/models/region_pack_node.dart';
import '../../region_picker/view_model/region_picker_view_model.dart';
import '../../../translations/locale_keys.g.dart';
import '../../../ui/core/app_colors.dart';

class RegionPickerView extends StatefulWidget {
  const RegionPickerView({required this.viewModel, super.key});

  final RegionPickerViewModel viewModel;

  @override
  State<RegionPickerView> createState() => _RegionPickerViewState();
}

class _RegionPickerViewState extends State<RegionPickerView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.viewModel.searchQuery,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.viewModel,
        widget.viewModel.appStateViewModel,
      ]),
      builder: (context, _) {
        final nodes = widget.viewModel.visibleNodes;
        final breadcrumbs = widget.viewModel.breadcrumbNodes;
        final isCurrentLevelLoading = widget.viewModel.isCurrentLevelLoading;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.slate200,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                    child: Row(
                      children: [
                        if (widget.viewModel.canGoBack)
                          IconButton(
                            onPressed: widget.viewModel.goBack,
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.slate600,
                            ),
                          )
                        else
                          const SizedBox(width: 48),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LocaleKeys.region_finder_title.tr(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slate900,
                                ),
                              ),
                              if (breadcrumbs.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    breadcrumbs
                                        .map((node) => node.name)
                                        .join(' / '),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.slate500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.slate400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      onChanged: widget.viewModel.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: LocaleKeys.region_finder_search_hint.tr(),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        LocaleKeys.region_finder_results_count.tr(
                          namedArgs: {'count': nodes.length.toString()},
                        ),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.slate400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: nodes.isEmpty
                        ? isCurrentLevelLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _EmptyState(
                                  searchQuery: widget.viewModel.searchQuery,
                                )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemBuilder: (context, index) {
                              final node = nodes[index];
                              return _PackNodeItem(
                                node: node,
                                isSelected: widget.viewModel.isSelected(
                                  node.id,
                                ),
                                showFullPath:
                                    widget.viewModel.isSearching ||
                                    breadcrumbs.isNotEmpty,
                                onOpenChildren: node.hasChildren
                                    ? () {
                                        unawaited(
                                          widget.viewModel.openChildren(node),
                                        );
                                      }
                                    : null,
                                onTap: () async {
                                  await widget.viewModel.selectPack(node);
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemCount: nodes.length,
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PackNodeItem extends StatelessWidget {
  const _PackNodeItem({
    required this.node,
    required this.isSelected,
    required this.showFullPath,
    required this.onTap,
    this.onOpenChildren,
  });

  final RegionPackNode node;
  final bool isSelected;
  final bool showFullPath;
  final VoidCallback onTap;
  final VoidCallback? onOpenChildren;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.emerald600 : AppColors.slate200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.emerald100
                              : AppColors.indigo50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _iconForKind(node.kind),
                          size: 18,
                          color: isSelected
                              ? AppColors.emerald700
                              : AppColors.indigo600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    node.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.slate900,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.emerald50,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      LocaleKeys.region_finder_current_badge
                                          .tr(),
                                      style: const TextStyle(
                                        color: AppColors.emerald700,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              showFullPath
                                  ? node.displayPath
                                  : _labelForKind(node.kind),
                              style: const TextStyle(
                                color: AppColors.slate500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 10, 12),
            child: onOpenChildren != null
                ? SizedBox.square(
                    dimension: 48,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: ValueKey<String>('region-picker-open-${node.id}'),
                        borderRadius: BorderRadius.circular(12),
                        onTap: onOpenChildren,
                        child: const Icon(
                          Icons.chevron_right,
                          color: AppColors.slate400,
                        ),
                      ),
                    ),
                  )
                : FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: isSelected
                          ? AppColors.emerald600
                          : AppColors.slate100,
                      foregroundColor: isSelected
                          ? Colors.white
                          : AppColors.slate600,
                    ),
                    onPressed: onTap,
                    child: Text(
                      isSelected
                          ? LocaleKeys.region_finder_action_selected.tr()
                          : LocaleKeys.region_finder_action_select.tr(),
                    ),
                  ),
          ),
        ],
      ),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.searchQuery});

  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.place_outlined, color: AppColors.slate400),
          const SizedBox(height: 8),
          Text(
            LocaleKeys.region_finder_empty_title.tr(),
            style: const TextStyle(
              color: AppColors.slate900,
              fontWeight: FontWeight.w600,
            ),
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
}
