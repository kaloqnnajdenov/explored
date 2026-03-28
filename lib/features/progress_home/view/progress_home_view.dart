import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/entities/entity.dart';
import '../../../domain/entities/entity_progress.dart';
import '../../../domain/entities/entity_type.dart';
import '../../../translations/locale_keys.g.dart';
import '../../../ui/core/app_colors.dart';
import '../../../ui/core/widgets/hex_mascot.dart';
import '../../entity_map/view/widgets/entity_boundary_layer.dart';
import '../../entity_selector/view/entity_selector_view.dart';
import '../../entity_selector/view_model/entity_selector_view_model.dart';
import '../../exploration/data/repositories/entity_repository.dart';
import '../../exploration/data/repositories/selection_repository.dart';
import '../../map/view/widgets/tracked_history_map.dart';
import '../../map/view_model/map_view_model.dart';
import '../view_model/progress_view_model.dart';

class ProgressHomeView extends StatefulWidget {
  const ProgressHomeView({
    required this.progressViewModel,
    required this.mapViewModel,
    required this.entityRepository,
    required this.selectionRepository,
    super.key,
  });

  final ProgressViewModel progressViewModel;
  final MapViewModel mapViewModel;
  final EntityRepository entityRepository;
  final SelectionRepository selectionRepository;

  @override
  State<ProgressHomeView> createState() => _ProgressHomeViewState();
}

class _ProgressHomeViewState extends State<ProgressHomeView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    widget.mapViewModel.initialize();
    widget.progressViewModel.initialize();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.progressViewModel,
        widget.mapViewModel,
      ]),
      builder: (context, _) {
        final progress = widget.progressViewModel.selectedProgress;

        return Scaffold(
          backgroundColor: AppColors.slate50,
          body: Stack(
            children: [
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: _refreshSelection,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.go('/profile'),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.emerald100,
                                border: Border.all(color: AppColors.emerald200),
                              ),
                              child: const Center(
                                child: HexMascot(
                                  pose: HexMascotPose.idle,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => context.go('/settings'),
                            icon: const Icon(
                              Icons.settings,
                              size: 20,
                              color: AppColors.slate400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (widget.progressViewModel.isLoading &&
                          progress == null)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (progress != null) ...[
                        _SelectedEntityCard(
                          progress: progress,
                          mapViewModel: widget.mapViewModel,
                          pulseController: _pulseController,
                          onOpenSelector: _openEntitySelector,
                          onOpenDetails: () =>
                              context.go('/entity/${progress.entity.entityId}'),
                        ),
                        const SizedBox(height: 16),
                        _CategoryGrid(progress: progress),
                        const SizedBox(height: 16),
                        _ChildrenSection(
                          entities: widget.progressViewModel.children,
                          onSelect: (entity) async {
                            await widget.progressViewModel.selectEntity(
                              entity.entityId,
                            );
                            await widget.mapViewModel.refreshSelectedEntity();
                          },
                          onOpenDetails: (entity) =>
                              context.go('/entity/${entity.entityId}'),
                        ),
                      ] else
                        const _NoProgressState(),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 24,
                bottom: 24,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 8,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => context.go('/map'),
                    child: const SizedBox(
                      width: 56,
                      height: 56,
                      child: Icon(
                        Icons.map_outlined,
                        size: 24,
                        color: AppColors.slate600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _refreshSelection() async {
    await widget.progressViewModel.refresh();
    await widget.mapViewModel.refreshSelectedEntity();
  }

  Future<void> _openEntitySelector() async {
    final didChange = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EntitySelectorView(
        viewModel: EntitySelectorViewModel(
          entityRepository: widget.entityRepository,
          selectionRepository: widget.selectionRepository,
        ),
      ),
    );
    if (didChange == true) {
      await _refreshSelection();
    }
  }
}

class _NoProgressState extends StatelessWidget {
  const _NoProgressState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Column(
        children: [
          const HexMascot(pose: HexMascotPose.mapUnroll, size: 120),
          const SizedBox(height: 12),
          Text(
            LocaleKeys.progress_no_data.tr(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.slate900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedEntityCard extends StatelessWidget {
  const _SelectedEntityCard({
    required this.progress,
    required this.mapViewModel,
    required this.pulseController,
    required this.onOpenSelector,
    required this.onOpenDetails,
  });

  final EntityProgress progress;
  final MapViewModel mapViewModel;
  final AnimationController pulseController;
  final VoidCallback onOpenSelector;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final state = mapViewModel.state;
    final lastLocation = state.locationTracking.lastLocation;
    final overall = _overallProgress(progress);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.emerald900,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            child: TrackedHistoryMap(
              tileSource: state.tileSource,
              persistedSamples: state.persistedSamples,
              currentLocation: lastLocation == null
                  ? null
                  : LatLng(lastLocation.latitude, lastLocation.longitude),
              initialCenter: progress.entity.centroid,
              initialZoom: 10.5,
              initialCameraFit: CameraFit.bounds(
                bounds: progress.entity.bbox.toLatLngBounds(),
                padding: const EdgeInsets.all(18),
                maxZoom: 12.5,
              ),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
              baseLayers: [
                EntityBoundaryLayer(
                  boundary: state.selectedParentBoundary,
                  fillColor: AppColors.emerald100.withValues(alpha: 0.18),
                  borderColor: AppColors.emerald200,
                  borderStrokeWidth: 1.2,
                ),
                EntityBoundaryLayer(
                  boundary: state.selectedBoundary,
                  fillColor: AppColors.emerald600.withValues(alpha: 0.24),
                  borderColor: AppColors.emerald500,
                  borderStrokeWidth: 1.8,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: onOpenSelector,
                      child: Row(
                        children: [
                          Text(
                            LocaleKeys.progress_selected_entity_label.tr(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.expand_more,
                            size: 16,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.9,
                        end: 1.2,
                      ).animate(pulseController),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.emerald300,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      LocaleKeys.progress_tracking_active.tr(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  progress.entity.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _TypeChip(entity: progress.entity),
                    const SizedBox(width: 8),
                    Text(
                      '${(overall * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: AppColors.emerald300,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  LocaleKeys.progress_totals_summary.tr(
                    namedArgs: {
                      'peaks': progress.totals.peaksCount.toString(),
                      'huts': progress.totals.hutsCount.toString(),
                      'monuments': progress.totals.monumentsCount.toString(),
                    },
                  ),
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: onOpenDetails,
                    icon: const Icon(Icons.chevron_right),
                    label: Text(LocaleKeys.progress_view_details.tr()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _overallProgress(EntityProgress progress) {
    final values = <double>[
      progress.peaks.percentage,
      progress.huts.percentage,
      progress.monuments.percentage,
      progress.roadsDrivable.percentage,
      progress.roadsWalkable.percentage,
      progress.roadsCycleway.percentage,
    ];
    return values.reduce((sum, value) => sum + value) / values.length;
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.entity});

  final Entity entity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _label(entity.type).tr(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  String _label(EntityType type) {
    switch (type) {
      case EntityType.country:
        return LocaleKeys.entity_type_country;
      case EntityType.region:
        return LocaleKeys.entity_type_region;
      case EntityType.city:
        return LocaleKeys.entity_type_city;
      case EntityType.cityCenter:
        return LocaleKeys.entity_type_city_center;
    }
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.progress});

  final EntityProgress progress;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _CategoryProgressCard(
          title: LocaleKeys.progress_category_peaks.tr(),
          value: '${progress.peaks.explored}/${progress.peaks.total}',
          subtitle: _progressSubtitle(
            progress.peaks.percentage,
            progress.peaks.hasData,
          ),
        ),
        _CategoryProgressCard(
          title: LocaleKeys.progress_category_huts.tr(),
          value: '${progress.huts.explored}/${progress.huts.total}',
          subtitle: _progressSubtitle(
            progress.huts.percentage,
            progress.huts.hasData,
          ),
        ),
        _CategoryProgressCard(
          title: LocaleKeys.progress_category_monuments.tr(),
          value: '${progress.monuments.explored}/${progress.monuments.total}',
          subtitle: _progressSubtitle(
            progress.monuments.percentage,
            progress.monuments.hasData,
          ),
        ),
        _CategoryProgressCard(
          title: LocaleKeys.progress_category_roads_drivable.tr(),
          value:
              '${progress.roadsDrivable.exploredLengthM.toStringAsFixed(0)}m/${progress.roadsDrivable.totalLengthM.toStringAsFixed(0)}m',
          subtitle: _progressSubtitle(
            progress.roadsDrivable.percentage,
            progress.roadsDrivable.hasData,
          ),
        ),
        _CategoryProgressCard(
          title: LocaleKeys.progress_category_roads_walkable.tr(),
          value:
              '${progress.roadsWalkable.exploredLengthM.toStringAsFixed(0)}m/${progress.roadsWalkable.totalLengthM.toStringAsFixed(0)}m',
          subtitle: _progressSubtitle(
            progress.roadsWalkable.percentage,
            progress.roadsWalkable.hasData,
          ),
        ),
        _CategoryProgressCard(
          title: LocaleKeys.progress_category_roads_cycleway.tr(),
          value:
              '${progress.roadsCycleway.exploredLengthM.toStringAsFixed(0)}m/${progress.roadsCycleway.totalLengthM.toStringAsFixed(0)}m',
          subtitle: _progressSubtitle(
            progress.roadsCycleway.percentage,
            progress.roadsCycleway.hasData,
          ),
        ),
      ],
    );
  }

  String _progressSubtitle(double percentage, bool hasData) {
    if (!hasData) {
      return LocaleKeys.progress_no_data.tr();
    }
    return '${(percentage * 100).toStringAsFixed(0)}%';
  }
}

class _CategoryProgressCard extends StatelessWidget {
  const _CategoryProgressCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width / 2 - 22,
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
            title,
            style: const TextStyle(
              color: AppColors.slate500,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.slate900,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppColors.slate500)),
        ],
      ),
    );
  }
}

class _ChildrenSection extends StatelessWidget {
  const _ChildrenSection({
    required this.entities,
    required this.onSelect,
    required this.onOpenDetails,
  });

  final List<Entity> entities;
  final ValueChanged<Entity> onSelect;
  final ValueChanged<Entity> onOpenDetails;

  @override
  Widget build(BuildContext context) {
    if (entities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.progress_children_title.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.slate900,
          ),
        ),
        const SizedBox(height: 8),
        for (final entity in entities) ...[
          _ChildEntityTile(
            entity: entity,
            onSelect: () => onSelect(entity),
            onOpenDetails: () => onOpenDetails(entity),
          ),
          if (entity != entities.last) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ChildEntityTile extends StatelessWidget {
  const _ChildEntityTile({
    required this.entity,
    required this.onSelect,
    required this.onOpenDetails,
  });

  final Entity entity;
  final VoidCallback onSelect;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entity.name,
                  style: const TextStyle(
                    color: AppColors.slate900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _typeLabel(entity.type).tr(),
                  style: const TextStyle(
                    color: AppColors.slate500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onSelect,
            child: Text(LocaleKeys.progress_select_child.tr()),
          ),
          IconButton(
            onPressed: onOpenDetails,
            icon: const Icon(Icons.chevron_right, color: AppColors.slate400),
          ),
        ],
      ),
    );
  }

  String _typeLabel(EntityType type) {
    switch (type) {
      case EntityType.country:
        return LocaleKeys.entity_type_country;
      case EntityType.region:
        return LocaleKeys.entity_type_region;
      case EntityType.city:
        return LocaleKeys.entity_type_city;
      case EntityType.cityCenter:
        return LocaleKeys.entity_type_city_center;
    }
  }
}
