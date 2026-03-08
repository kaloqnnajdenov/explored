import 'package:latlong2/latlong.dart';

import '../models/app_permission.dart';
import '../models/app_state_snapshot.dart';
import '../models/gps_quality.dart';
import '../models/region.dart';
import '../models/user_point.dart';
import '../services/app_state_prefs_service.dart';

abstract class AppStateRepository {
  Future<AppStateSnapshot> load();

  Future<void> setHasSeenOnboarding(bool value);

  Future<void> setPermissions(
    Map<TrackingPermissionType, PermissionGrantState> permissions,
  );

  Future<void> setCurrentRegionId(String regionId);

  Future<void> setDownloadedRegionIds(Set<String> ids);

  Future<void> setUserPoints(List<UserPoint> points);
}

class DefaultAppStateRepository implements AppStateRepository {
  DefaultAppStateRepository({required AppStatePrefsService prefsService})
    : _prefsService = prefsService;

  final AppStatePrefsService _prefsService;

  @override
  Future<AppStateSnapshot> load() async {
    final seedRegions = _seedRegions();
    final downloadedIds = _prefsService.readDownloadedRegionIds();
    final regions = seedRegions
        .map(
          (region) =>
              region.copyWith(isDownloaded: downloadedIds.contains(region.id)),
        )
        .toList(growable: false);
    final defaultRegionId = regions.first.id;
    final persistedRegionId = _prefsService.readCurrentRegionId();
    final currentRegionId =
        regions.any((region) => region.id == persistedRegionId)
        ? persistedRegionId!
        : defaultRegionId;

    return AppStateSnapshot(
      hasSeenOnboarding: _prefsService.readHasSeenOnboarding(),
      permissions: _prefsService.readPermissions(),
      isTracking: true,
      gpsQuality: GpsQuality.good,
      regions: regions,
      currentRegionId: currentRegionId,
      userPoints: _prefsService.readUserPoints(),
    );
  }

  @override
  Future<void> setHasSeenOnboarding(bool value) {
    return _prefsService.writeHasSeenOnboarding(value);
  }

  @override
  Future<void> setPermissions(
    Map<TrackingPermissionType, PermissionGrantState> permissions,
  ) {
    return _prefsService.writePermissions(permissions);
  }

  @override
  Future<void> setCurrentRegionId(String regionId) {
    return _prefsService.writeCurrentRegionId(regionId);
  }

  @override
  Future<void> setDownloadedRegionIds(Set<String> ids) {
    return _prefsService.writeDownloadedRegionIds(ids);
  }

  @override
  Future<void> setUserPoints(List<UserPoint> points) {
    return _prefsService.writeUserPoints(points);
  }

  List<Region> _seedRegions() {
    return const [
      Region(
        id: 'northern-alps',
        name: 'Northern Alps',
        totalArea: 1580,
        exploredArea: 0,
        isDownloaded: false,
        center: LatLng(47.312, 10.716),
        bounds: [
          LatLng(47.650, 10.060),
          LatLng(47.610, 11.160),
          LatLng(47.060, 11.340),
          LatLng(46.980, 10.080),
        ],
        features: RegionFeatures(
          trails: RegionFeatureProgress(total: 320, completed: 0),
          peaks: RegionFeatureProgress(total: 88, completed: 0),
          huts: RegionFeatureProgress(total: 52, completed: 0),
        ),
      ),
      Region(
        id: 'eastern-dolomites',
        name: 'Eastern Dolomites',
        totalArea: 910,
        exploredArea: 0,
        isDownloaded: false,
        center: LatLng(46.537, 12.131),
        bounds: [
          LatLng(46.820, 11.700),
          LatLng(46.770, 12.570),
          LatLng(46.220, 12.660),
          LatLng(46.200, 11.720),
        ],
        features: RegionFeatures(
          trails: RegionFeatureProgress(total: 250, completed: 0),
          peaks: RegionFeatureProgress(total: 72, completed: 0),
          huts: RegionFeatureProgress(total: 45, completed: 0),
        ),
      ),
      Region(
        id: 'zillertal-alps',
        name: 'Zillertal Alps',
        totalArea: 1090,
        exploredArea: 0,
        isDownloaded: false,
        center: LatLng(47.037, 11.885),
        bounds: [
          LatLng(47.350, 11.420),
          LatLng(47.350, 12.320),
          LatLng(46.760, 12.320),
          LatLng(46.740, 11.430),
        ],
        features: RegionFeatures(
          trails: RegionFeatureProgress(total: 280, completed: 0),
          peaks: RegionFeatureProgress(total: 79, completed: 0),
          huts: RegionFeatureProgress(total: 41, completed: 0),
        ),
      ),
      Region(
        id: 'stubai-valley',
        name: 'Stubai Valley',
        totalArea: 540,
        exploredArea: 0,
        isDownloaded: false,
        center: LatLng(47.083, 11.239),
        bounds: [
          LatLng(47.270, 10.980),
          LatLng(47.250, 11.520),
          LatLng(46.860, 11.530),
          LatLng(46.840, 10.970),
        ],
        features: RegionFeatures(
          trails: RegionFeatureProgress(total: 134, completed: 0),
          peaks: RegionFeatureProgress(total: 36, completed: 0),
          huts: RegionFeatureProgress(total: 21, completed: 0),
        ),
      ),
      Region(
        id: 'brenta-dolomites',
        name: 'Brenta Dolomites',
        totalArea: 670,
        exploredArea: 0,
        isDownloaded: false,
        center: LatLng(46.173, 10.914),
        bounds: [
          LatLng(46.410, 10.610),
          LatLng(46.430, 11.220),
          LatLng(45.970, 11.250),
          LatLng(45.930, 10.590),
        ],
        features: RegionFeatures(
          trails: RegionFeatureProgress(total: 186, completed: 0),
          peaks: RegionFeatureProgress(total: 55, completed: 0),
          huts: RegionFeatureProgress(total: 33, completed: 0),
        ),
      ),
      Region(
        id: 'otztal-alps',
        name: 'Otztal Alps',
        totalArea: 1230,
        exploredArea: 0,
        isDownloaded: false,
        center: LatLng(46.868, 10.879),
        bounds: [
          LatLng(47.200, 10.350),
          LatLng(47.180, 11.420),
          LatLng(46.530, 11.430),
          LatLng(46.490, 10.320),
        ],
        features: RegionFeatures(
          trails: RegionFeatureProgress(total: 298, completed: 0),
          peaks: RegionFeatureProgress(total: 82, completed: 0),
          huts: RegionFeatureProgress(total: 48, completed: 0),
        ),
      ),
    ];
  }
}
