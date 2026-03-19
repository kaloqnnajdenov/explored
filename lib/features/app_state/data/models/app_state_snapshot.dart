import 'app_permission.dart';
import 'gps_quality.dart';
import 'user_point.dart';
import '../../../region_catalog/data/models/region_catalog.dart';
import '../../../region_catalog/data/models/region_pack_node.dart';
import '../../../region_catalog/data/models/selected_pack_ref.dart';

class AppStateSnapshot {
  static const Object _unset = Object();

  const AppStateSnapshot({
    required this.hasSeenOnboarding,
    required this.permissions,
    required this.isTracking,
    required this.gpsQuality,
    required this.regionCatalog,
    required this.selectedPackId,
    this.selectedPackRef,
    this.downloadedPackRefs = const <SelectedPackRef>[],
    this.isCatalogLoading = false,
    this.catalogError,
    this.hasLoadedRootPacks = true,
    required this.userPoints,
  });

  final bool hasSeenOnboarding;
  final Map<TrackingPermissionType, PermissionGrantState> permissions;
  final bool isTracking;
  final GpsQuality gpsQuality;
  final RegionCatalog regionCatalog;
  final String selectedPackId;
  final SelectedPackRef? selectedPackRef;
  final List<SelectedPackRef> downloadedPackRefs;
  final bool isCatalogLoading;
  final String? catalogError;
  final bool hasLoadedRootPacks;
  final List<UserPoint> userPoints;

  List<RegionPackNode> get regions => regionCatalog.allNodes;

  String get currentRegionId => selectedPackId;

  AppStateSnapshot copyWith({
    bool? hasSeenOnboarding,
    Map<TrackingPermissionType, PermissionGrantState>? permissions,
    bool? isTracking,
    GpsQuality? gpsQuality,
    RegionCatalog? regionCatalog,
    List<RegionPackNode>? regions,
    String? selectedPackId,
    Object? selectedPackRef = _unset,
    List<SelectedPackRef>? downloadedPackRefs,
    bool? isCatalogLoading,
    Object? catalogError = _unset,
    bool? hasLoadedRootPacks,
    String? currentRegionId,
    List<UserPoint>? userPoints,
  }) {
    final nextRegionCatalog =
        regionCatalog ??
        (regions == null
            ? this.regionCatalog
            : RegionCatalog(
                rootIds: [
                  for (final region in regions)
                    if (region.parentId == null ||
                        !regions.any(
                          (candidate) => candidate.id == region.parentId,
                        ))
                      region.id,
                ],
                nodesById: {for (final region in regions) region.id: region},
              ));
    return AppStateSnapshot(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      permissions: permissions ?? this.permissions,
      isTracking: isTracking ?? this.isTracking,
      gpsQuality: gpsQuality ?? this.gpsQuality,
      regionCatalog: nextRegionCatalog,
      selectedPackId: selectedPackId ?? currentRegionId ?? this.selectedPackId,
      selectedPackRef: identical(selectedPackRef, _unset)
          ? this.selectedPackRef
          : selectedPackRef as SelectedPackRef?,
      downloadedPackRefs: downloadedPackRefs ?? this.downloadedPackRefs,
      isCatalogLoading: isCatalogLoading ?? this.isCatalogLoading,
      catalogError: identical(catalogError, _unset)
          ? this.catalogError
          : catalogError as String?,
      hasLoadedRootPacks: hasLoadedRootPacks ?? this.hasLoadedRootPacks,
      userPoints: userPoints ?? this.userPoints,
    );
  }
}
