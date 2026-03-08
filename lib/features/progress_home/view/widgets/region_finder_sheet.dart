import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../app_state/data/models/region.dart';
import '../../../app_state/view_model/app_state_view_model.dart';
import '../../../map/view/widgets/tracked_history_map.dart';
import '../../../map/view_model/map_view_model.dart';
import '../../../../translations/locale_keys.g.dart';
import '../../../../ui/core/app_colors.dart';

class RegionFinderSheet extends StatefulWidget {
  const RegionFinderSheet({
    required this.appStateViewModel,
    required this.mapViewModel,
    this.userLocation,
    super.key,
  });

  final AppStateViewModel appStateViewModel;
  final MapViewModel mapViewModel;
  final LatLng? userLocation;

  @override
  State<RegionFinderSheet> createState() => _RegionFinderSheetState();
}

class _RegionFinderSheetState extends State<RegionFinderSheet> {
  late final MapController _mapController;
  late final TextEditingController _searchController;
  late String _selectedRegionId;
  bool _nearMeOnly = false;
  bool _mapAreaFilter = true;
  bool _showSearchAreaButton = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _searchController = TextEditingController();
    _selectedRegionId = widget.appStateViewModel.currentRegionId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allRegions = widget.appStateViewModel.regions;
    final selectedRegion = allRegions.firstWhere(
      (region) => region.id == _selectedRegionId,
      orElse: () => allRegions.first,
    );
    final mapState = widget.mapViewModel.state;
    final trackedLocation = mapState.locationTracking.lastLocation;
    final userLocation =
        widget.userLocation ?? widget.appStateViewModel.currentRegion.center;
    final currentLocation = trackedLocation == null
        ? userLocation
        : LatLng(trackedLocation.latitude, trackedLocation.longitude);

    final searchedRegions = allRegions
        .where((region) {
          final search = _searchController.text.trim().toLowerCase();
          if (search.isEmpty) {
            return true;
          }
          return region.name.toLowerCase().contains(search);
        })
        .toList(growable: false);

    final filteredRegions = _nearMeOnly
        ? searchedRegions
              .where(
                (region) => _distanceInKm(region.center, userLocation) <= 120,
              )
              .toList(growable: false)
        : searchedRegions;

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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        LocaleKeys.region_finder_title.tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: AppColors.slate400),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: LocaleKeys.region_finder_search_hint.tr(),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      selected: _nearMeOnly,
                      onSelected: (selected) {
                        setState(() {
                          _nearMeOnly = selected;
                        });
                      },
                      avatar: Icon(
                        Icons.navigation,
                        size: 16,
                        color: _nearMeOnly ? Colors.white : AppColors.slate600,
                      ),
                      selectedColor: AppColors.emerald600,
                      labelStyle: TextStyle(
                        color: _nearMeOnly ? Colors.white : AppColors.slate600,
                        fontWeight: FontWeight.w600,
                      ),
                      label: Text(LocaleKeys.region_finder_chip_near_me.tr()),
                    ),
                    InputChip(
                      selected: _mapAreaFilter,
                      onSelected: (selected) {
                        setState(() {
                          _mapAreaFilter = selected;
                        });
                      },
                      selectedColor: AppColors.blue500,
                      avatar: Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: _mapAreaFilter
                            ? Colors.white
                            : AppColors.slate600,
                      ),
                      deleteIconColor: _mapAreaFilter
                          ? Colors.white
                          : AppColors.slate600,
                      onDeleted: _mapAreaFilter
                          ? () {
                              setState(() {
                                _mapAreaFilter = false;
                              });
                            }
                          : null,
                      labelStyle: TextStyle(
                        color: _mapAreaFilter
                            ? Colors.white
                            : AppColors.slate600,
                        fontWeight: FontWeight.w600,
                      ),
                      label: Text(LocaleKeys.region_finder_chip_map_area.tr()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 160,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Stack(
                        children: [
                          TrackedHistoryMap(
                            mapController: _mapController,
                            tileSource: mapState.tileSource,
                            persistedSamples: mapState.persistedSamples,
                            currentLocation: currentLocation,
                            initialCenter: selectedRegion.center,
                            initialZoom: 8.6,
                            onTap: (tapPosition, latLng) {
                              final hitRegion = _regionForPoint(
                                latLng,
                                allRegions,
                              );
                              if (hitRegion == null) {
                                return;
                              }
                              _selectRegion(hitRegion, fromMapTap: true);
                            },
                            onPositionChanged: (position, hasGesture) {
                              if (hasGesture && !_showSearchAreaButton) {
                                setState(() {
                                  _showSearchAreaButton = true;
                                });
                              }
                            },
                            baseLayers: [
                              if (_nearMeOnly)
                                CircleLayer(
                                  circles: [
                                    CircleMarker(
                                      point: userLocation,
                                      radius: 60,
                                      color: AppColors.blue500.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderColor: AppColors.blue500.withValues(
                                        alpha: 0.35,
                                      ),
                                      borderStrokeWidth: 1,
                                      useRadiusInMeter: true,
                                    ),
                                  ],
                                ),
                              PolygonLayer(
                                polygons: [
                                  for (final region in allRegions)
                                    Polygon(
                                      points: region.bounds,
                                      color: region.id == _selectedRegionId
                                          ? AppColors.emerald600.withValues(
                                              alpha: 0.30,
                                            )
                                          : AppColors.emerald100.withValues(
                                              alpha: 0.25,
                                            ),
                                      borderColor:
                                          region.id == _selectedRegionId
                                          ? AppColors.emerald700
                                          : AppColors.slate300,
                                      borderStrokeWidth:
                                          region.id == _selectedRegionId
                                          ? 2
                                          : 1,
                                    ),
                                ],
                              ),
                            ],
                          ),
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            top: _showSearchAreaButton ? 10 : -48,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.slate900,
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showSearchAreaButton = false;
                                  });
                                },
                                child: Text(
                                  LocaleKeys.region_finder_search_area.tr(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      namedArgs: {'count': filteredRegions.length.toString()},
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
                child: filteredRegions.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemBuilder: (context, index) {
                          final region = filteredRegions[index];
                          final isSelected = region.id == _selectedRegionId;
                          return _RegionItem(
                            region: region,
                            isSelected: isSelected,
                            isCurrent:
                                region.id ==
                                widget.appStateViewModel.currentRegionId,
                            onTap: () => _selectRegion(region),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemCount: filteredRegions.length,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
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

  Future<void> _selectRegion(Region region, {bool fromMapTap = false}) async {
    setState(() {
      _selectedRegionId = region.id;
    });
    await widget.appStateViewModel.setCurrentRegionId(region.id);
    _mapController.move(region.center, 9.6);
    if (fromMapTap) {
      return;
    }
  }

  Region? _regionForPoint(LatLng point, List<Region> regions) {
    for (final region in regions) {
      if (_pointInsidePolygon(point, region.bounds)) {
        return region;
      }
    }
    return null;
  }

  bool _pointInsidePolygon(LatLng point, List<LatLng> polygon) {
    var inside = false;
    for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i].longitude;
      final yi = polygon[i].latitude;
      final xj = polygon[j].longitude;
      final yj = polygon[j].latitude;

      final intersects =
          ((yi > point.latitude) != (yj > point.latitude)) &&
          (point.longitude <
              (xj - xi) * (point.latitude - yi) / (yj - yi + 0.0000001) + xi);
      if (intersects) {
        inside = !inside;
      }
    }
    return inside;
  }

  double _distanceInKm(LatLng a, LatLng b) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(b.latitude - a.latitude);
    final dLng = _toRadians(b.longitude - a.longitude);
    final startLat = _toRadians(a.latitude);
    final endLat = _toRadians(b.latitude);

    final h =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(startLat) *
            math.cos(endLat) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return earthRadiusKm * c;
  }

  double _toRadians(double value) => value * math.pi / 180;
}

class _RegionItem extends StatelessWidget {
  const _RegionItem({
    required this.region,
    required this.isSelected,
    required this.isCurrent,
    required this.onTap,
  });

  final Region region;
  final bool isSelected;
  final bool isCurrent;
  final VoidCallback onTap;

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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.emerald100 : AppColors.indigo50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.terrain,
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
                            region.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate900,
                            ),
                          ),
                        ),
                        if (isCurrent)
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
                              LocaleKeys.region_finder_current_badge.tr(),
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
                      LocaleKeys.region_finder_area.tr(
                        namedArgs: {
                          'area': region.totalArea.toStringAsFixed(0),
                        },
                      ),
                      style: const TextStyle(
                        color: AppColors.slate500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: 0,
                        minHeight: 6,
                        backgroundColor: AppColors.slate100,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.emerald600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
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
            ],
          ),
        ),
      ),
    );
  }
}
