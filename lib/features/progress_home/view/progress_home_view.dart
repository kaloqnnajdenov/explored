import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../app_state/view_model/app_state_view_model.dart';
import '../../map/view/widgets/tracked_history_map.dart';
import '../../map/view_model/map_view_model.dart';
import '../../region_catalog/data/models/region_pack_node.dart';
import '../../region_catalog/view/widgets/region_boundary_layer.dart';
import '../../region_picker/view/region_picker_view.dart';
import '../../region_picker/view_model/region_picker_view_model.dart';
import '../../../translations/locale_keys.g.dart';
import '../../../ui/core/app_colors.dart';
import '../../../ui/core/widgets/coming_soon.dart';
import '../../../ui/core/widgets/hex_mascot.dart';
import '../../../ui/core/widgets/not_implemented_badge.dart';
import '../../../ui/core/widgets/placeholder_metric_value.dart';

class ProgressHomeView extends StatefulWidget {
  const ProgressHomeView({
    required this.appStateViewModel,
    required this.mapViewModel,
    super.key,
  });

  final AppStateViewModel appStateViewModel;
  final MapViewModel mapViewModel;

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
        widget.appStateViewModel,
        widget.mapViewModel,
      ]),
      builder: (context, _) {
        final selectedPack = widget.appStateViewModel.selectedPackOrNull;

        return Scaffold(
          backgroundColor: AppColors.slate50,
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                    border: Border.all(
                                      color: AppColors.emerald200,
                                    ),
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
                          _buildGlobalProgressCard(),
                          const SizedBox(height: 16),
                          selectedPack == null
                              ? _buildCurrentRegionLoadingCard()
                              : _buildCurrentRegionCard(selectedPack),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _FeatureMiniCard(
                                  icon: Icons.hiking,
                                  title: LocaleKeys.progress_feature_trails
                                      .tr(),
                                  color: AppColors.amber600,
                                  background: AppColors.amber50,
                                  onTap: () => showComingSoonSnackBar(context),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _FeatureMiniCard(
                                  icon: Icons.terrain,
                                  title: LocaleKeys.progress_feature_peaks.tr(),
                                  color: AppColors.indigo600,
                                  background: AppColors.indigo50,
                                  onTap: () => showComingSoonSnackBar(context),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _FeatureMiniCard(
                                  icon: Icons.cabin,
                                  title: LocaleKeys.progress_feature_huts.tr(),
                                  color: AppColors.rose600,
                                  background: AppColors.rose50,
                                  onTap: () => showComingSoonSnackBar(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
              Positioned(
                left: 24,
                bottom: 24,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.emerald100.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.emerald200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.9,
                              end: 1.2,
                            ).animate(_pulseController),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.emerald500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            LocaleKeys.progress_tracking_active.tr(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.emerald700,
                            ),
                          ),
                        ],
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

  Widget _buildGlobalProgressCard() {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.progress_total_explored_label.tr(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate500,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              const PlaceholderMetricValue(fontSize: 30),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: 0,
                  minHeight: 6,
                  backgroundColor: AppColors.slate100,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.slate900,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    LocaleKeys.progress_last_7_days_placeholder.tr(),
                    style: const TextStyle(
                      color: AppColors.slate500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const NotImplementedBadge(),
                ],
              ),
            ],
          ),
          const Positioned(
            right: 0,
            top: 0,
            child: HexMascot(pose: HexMascotPose.idle, size: 144),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentRegionCard(RegionPackNode pack) {
    final mapState = widget.mapViewModel.state;
    final lastLocation = mapState.locationTracking.lastLocation;
    final currentLocation = lastLocation == null
        ? null
        : LatLng(lastLocation.latitude, lastLocation.longitude);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.emerald900,
        borderRadius: BorderRadius.circular(16),
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
            height: 130,
            child: Stack(
              children: [
                TrackedHistoryMap(
                  tileSource: mapState.tileSource,
                  persistedSamples: mapState.persistedSamples,
                  currentLocation: currentLocation,
                  initialCenter: pack.center,
                  initialZoom: 9,
                  initialCameraFit: CameraFit.bounds(
                    bounds: pack.bounds.toLatLngBounds(),
                    padding: const EdgeInsets.all(12),
                    maxZoom: 10.5,
                  ),
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                  baseLayers: [
                    RegionBoundaryLayer(
                      boundary:
                          widget.appStateViewModel.selectedParentRegionBoundary,
                      fillColor: AppColors.emerald100.withValues(alpha: 0.16),
                      borderColor: AppColors.emerald200,
                      borderStrokeWidth: 1.2,
                    ),
                    RegionBoundaryLayer(
                      boundary: widget.appStateViewModel.selectedBoundary,
                      fillColor: AppColors.emerald600.withValues(alpha: 0.28),
                      borderColor: AppColors.emerald500,
                      borderStrokeWidth: 1.8,
                    ),
                  ],
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.emerald900.withValues(alpha: 0.6),
                        Colors.transparent,
                        AppColors.emerald900.withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                  child: const SizedBox.expand(),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: GestureDetector(
                    onTap: _openRegionFinder,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.navigation,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                LocaleKeys.progress_tap_find_region.tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _openRegionFinder,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.map_outlined,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            LocaleKeys.progress_current_region_label.tr(),
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
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => context.go('/pack/${pack.id}'),
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  pack.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const PlaceholderMetricValue(
                  fontSize: 36,
                  color: AppColors.emerald300,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      LocaleKeys.progress_region_area_placeholder.tr(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const NotImplementedBadge(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentRegionLoadingCard() {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: AppColors.emerald900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Future<void> _openRegionFinder() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => RegionPickerView(
        viewModel: RegionPickerViewModel(
          appStateViewModel: widget.appStateViewModel,
        ),
      ),
    );
  }
}

class _FeatureMiniCard extends StatefulWidget {
  const _FeatureMiniCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  State<_FeatureMiniCard> createState() => _FeatureMiniCardState();
}

class _FeatureMiniCardState extends State<_FeatureMiniCard> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _scale = 0.97;
        });
      },
      onTapCancel: () {
        setState(() {
          _scale = 1;
        });
      },
      onTapUp: (_) {
        setState(() {
          _scale = 1;
        });
      },
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(12),
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
          child: Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, size: 17, color: widget.color),
              ),
              const SizedBox(height: 8),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.slate900,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              const NotImplementedBadge(),
            ],
          ),
        ),
      ),
    );
  }
}
