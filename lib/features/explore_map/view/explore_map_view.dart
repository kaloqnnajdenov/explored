import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../app_state/data/models/user_point.dart';
import '../../app_state/view_model/app_state_view_model.dart';
import '../../map/view/widgets/tracked_history_map.dart';
import '../../map/view_model/map_view_model.dart';
import '../../../translations/locale_keys.g.dart';
import '../../../ui/core/app_colors.dart';
import '../../../ui/core/widgets/app_back_button.dart';
import '../../../ui/core/widgets/coming_soon.dart';

enum _EditMode { none, add, delete }

class ExploreMapView extends StatefulWidget {
  const ExploreMapView({
    required this.appStateViewModel,
    required this.mapViewModel,
    super.key,
  });

  final AppStateViewModel appStateViewModel;
  final MapViewModel mapViewModel;

  @override
  State<ExploreMapView> createState() => _ExploreMapViewState();
}

class _ExploreMapViewState extends State<ExploreMapView> {
  late final MapController _mapController;
  _EditMode _editMode = _EditMode.none;
  bool _editMenuExpanded = false;
  bool _fogEnabled = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    widget.mapViewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.appStateViewModel,
        widget.mapViewModel,
      ]),
      builder: (context, _) {
        final region = widget.appStateViewModel.currentRegion;
        final lastLocation =
            widget.mapViewModel.state.locationTracking.lastLocation;
        final userPoints = widget.appStateViewModel.userPoints;
        final tileSource = widget.mapViewModel.state.tileSource;

        return Scaffold(
          backgroundColor: AppColors.slate100,
          body: Stack(
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
                child: TrackedHistoryMap(
                  mapController: _mapController,
                  tileSource: tileSource,
                  persistedSamples: widget.mapViewModel.state.persistedSamples,
                  currentLocation: lastLocation == null
                      ? null
                      : LatLng(lastLocation.latitude, lastLocation.longitude),
                  initialCenter: region.center,
                  initialZoom: 9.6,
                  onTap: (tapPosition, latLng) {
                    if (_editMode != _EditMode.add) {
                      return;
                    }
                    widget.appStateViewModel.addUserPoint(
                      latLng.latitude,
                      latLng.longitude,
                    );
                  },
                  baseLayers: [
                    MarkerLayer(
                      markers: [
                        for (final point in userPoints)
                          Marker(
                            point: LatLng(point.latitude, point.longitude),
                            width: 24,
                            height: 24,
                            child: GestureDetector(
                              onTap: () => _handlePointTap(point),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _editMode == _EditMode.delete
                                      ? AppColors.rose600
                                      : AppColors.emerald600,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _editMode == _EditMode.delete
                                      ? Icons.delete_outline
                                      : Icons.place,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_fogEnabled)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: AppColors.slate900.withValues(alpha: 0.30),
                    ),
                  ),
                ),
              Positioned(
                top: 16,
                left: 16,
                child: SafeArea(child: AppBackButton(onPressed: _handleBack)),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _CircleIconButton(
                        icon: _editMenuExpanded ? Icons.close : Icons.edit,
                        foregroundColor: _editMode == _EditMode.add
                            ? AppColors.emerald600
                            : _editMode == _EditMode.delete
                            ? AppColors.rose600
                            : AppColors.slate600,
                        onPressed: _toggleEditMenu,
                      ),
                      const SizedBox(height: 8),
                      ClipRect(
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 220),
                          offset: _editMenuExpanded
                              ? Offset.zero
                              : const Offset(1, 0),
                          curve: Curves.easeOut,
                          child: IgnorePointer(
                            ignoring: !_editMenuExpanded,
                            child: Column(
                              children: [
                                _CircleIconButton(
                                  icon: Icons.add,
                                  foregroundColor: AppColors.emerald600,
                                  onPressed: () {
                                    setState(() {
                                      _editMode = _EditMode.add;
                                    });
                                  },
                                  tooltip: LocaleKeys.map_action_add_point.tr(),
                                ),
                                const SizedBox(height: 8),
                                _CircleIconButton(
                                  icon: Icons.delete_outline,
                                  foregroundColor: AppColors.rose600,
                                  onPressed: () {
                                    setState(() {
                                      _editMode = _EditMode.delete;
                                    });
                                  },
                                  tooltip: LocaleKeys.map_action_delete_point
                                      .tr(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _CircleIconButton(
                        icon: Icons.layers_outlined,
                        foregroundColor: _fogEnabled
                            ? AppColors.emerald900
                            : AppColors.slate600,
                        onPressed: () {
                          setState(() {
                            _fogEnabled = !_fogEnabled;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      _CircleIconButton(
                        icon: Icons.my_location,
                        foregroundColor: AppColors.slate600,
                        onPressed: () => showComingSoonSnackBar(context),
                      ),
                    ],
                  ),
                ),
              ),
              if (_editMode != _EditMode.none)
                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (_editMode == _EditMode.add
                                          ? AppColors.emerald600
                                          : AppColors.rose600)
                                      .withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _editMode == _EditMode.add
                                  ? LocaleKeys.map_banner_add_mode.tr()
                                  : LocaleKeys.map_banner_delete_mode.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
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

  void _toggleEditMenu() {
    setState(() {
      if (_editMenuExpanded) {
        _editMode = _EditMode.none;
      }
      _editMenuExpanded = !_editMenuExpanded;
    });
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/');
  }

  void _handlePointTap(UserPoint point) {
    if (_editMode != _EditMode.delete) {
      return;
    }
    widget.appStateViewModel.removeUserPoint(point.id);
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.foregroundColor,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final Color foregroundColor;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 5,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon, color: foregroundColor),
      ),
    );
  }
}
