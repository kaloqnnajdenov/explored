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
import '../../../ui/core/widgets/app_back_button.dart';
import '../../entity_map/view/widgets/entity_boundary_layer.dart';
import '../../map/view/widgets/tracked_history_map.dart';
import '../../map/view_model/map_view_model.dart';
import '../view_model/entity_details_view_model.dart';

class EntityDetailView extends StatefulWidget {
  const EntityDetailView({
    required this.viewModel,
    required this.mapViewModel,
    required this.entityId,
    super.key,
  });

  final EntityDetailsViewModel viewModel;
  final MapViewModel mapViewModel;
  final String entityId;

  @override
  State<EntityDetailView> createState() => _EntityDetailViewState();
}

class _EntityDetailViewState extends State<EntityDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.loadEntity(widget.entityId);
    });
  }

  @override
  void didUpdateWidget(covariant EntityDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entityId != widget.entityId) {
      widget.viewModel.loadEntity(widget.entityId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.viewModel, widget.mapViewModel]),
      builder: (context, _) {
        if (widget.viewModel.isLoading && widget.viewModel.progress == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final progress = widget.viewModel.progress;
        if (progress == null) {
          return Scaffold(
            appBar: AppBar(leading: AppBackButton(onPressed: _handleBack)),
            body: Center(
              child: Text(LocaleKeys.entity_detail_not_found.tr()),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.slate50,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        AppBackButton(onPressed: _handleBack),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                progress.entity.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slate900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _parentChainLabel(widget.viewModel.parentChain),
                                style: const TextStyle(color: AppColors.slate500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TypeBadge(entity: progress.entity),
                        const SizedBox(height: 16),
                        _EntityMiniMap(
                          progress: progress,
                          mapViewModel: widget.mapViewModel,
                        ),
                        const SizedBox(height: 16),
                        _ProgressSummary(progress: progress),
                        const SizedBox(height: 16),
                        Text(
                          LocaleKeys.entity_detail_children_title.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate900,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: widget.viewModel.children.length,
                    itemBuilder: (context, index) {
                      final child = widget.viewModel.children[index];
                      return _ChildTile(
                        entity: child,
                        onTap: () => context.go('/entity/${child.entityId}'),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _parentChainLabel(List<Entity> chain) {
    if (chain.isEmpty) {
      return '';
    }
    return chain.map((entity) => entity.name).join(' / ');
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/');
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.entity});

  final Entity entity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.emerald100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _labelKey(entity).tr(),
        style: const TextStyle(
          color: AppColors.emerald700,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  String _labelKey(Entity entity) {
    switch (entity.type) {
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

class _EntityMiniMap extends StatelessWidget {
  const _EntityMiniMap({
    required this.progress,
    required this.mapViewModel,
  });

  final EntityProgress progress;
  final MapViewModel mapViewModel;

  @override
  Widget build(BuildContext context) {
    final state = mapViewModel.state;
    final lastLocation = state.locationTracking.lastLocation;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 220,
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
          interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
          baseLayers: [
            EntityBoundaryLayer(
              boundary: state.selectedParentBoundary,
              fillColor: AppColors.emerald100.withValues(alpha: 0.18),
              borderColor: AppColors.emerald200,
              borderStrokeWidth: 1.2,
            ),
            EntityBoundaryLayer(
              boundary: state.selectedBoundary,
              fillColor: AppColors.emerald600.withValues(alpha: 0.22),
              borderColor: AppColors.emerald700,
              borderStrokeWidth: 1.6,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({required this.progress});

  final EntityProgress progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MetricCard(
          title: LocaleKeys.progress_category_peaks.tr(),
          value: '${progress.peaks.explored}/${progress.peaks.total}',
          subtitle: _subtitle(progress.peaks.percentage, progress.peaks.hasData),
        ),
        const SizedBox(height: 8),
        _MetricCard(
          title: LocaleKeys.progress_category_huts.tr(),
          value: '${progress.huts.explored}/${progress.huts.total}',
          subtitle: _subtitle(progress.huts.percentage, progress.huts.hasData),
        ),
        const SizedBox(height: 8),
        _MetricCard(
          title: LocaleKeys.progress_category_monuments.tr(),
          value:
              '${progress.monuments.explored}/${progress.monuments.total}',
          subtitle: _subtitle(
            progress.monuments.percentage,
            progress.monuments.hasData,
          ),
        ),
      ],
    );
  }

  String _subtitle(double percentage, bool hasData) {
    if (!hasData) {
      return LocaleKeys.progress_no_data.tr();
    }
    return '${(percentage * 100).toStringAsFixed(0)}%';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.slate900,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate900,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.slate500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChildTile extends StatelessWidget {
  const _ChildTile({required this.entity, required this.onTap});

  final Entity entity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate100),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  entity.name,
                  style: const TextStyle(
                    color: AppColors.slate900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.slate400),
            ],
          ),
        ),
      ),
    );
  }
}
