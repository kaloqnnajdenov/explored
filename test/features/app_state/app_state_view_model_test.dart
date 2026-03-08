import 'package:explored/features/app_state/data/models/app_permission.dart';
import 'package:explored/features/app_state/data/models/app_state_snapshot.dart';
import 'package:explored/features/app_state/data/models/gps_quality.dart';
import 'package:explored/features/app_state/data/models/region.dart';
import 'package:explored/features/app_state/data/models/user_point.dart';
import 'package:explored/features/app_state/data/repositories/app_state_repository.dart';
import 'package:explored/features/app_state/view_model/app_state_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

class FakeAppStateRepository implements AppStateRepository {
  bool hasSeenOnboarding = false;
  Map<TrackingPermissionType, PermissionGrantState> permissions = {
    for (final permission in TrackingPermissionType.values)
      permission: PermissionGrantState.prompt,
  };
  String currentRegionId = 'r1';
  Set<String> downloadedIds = <String>{};
  List<UserPoint> userPoints = const <UserPoint>[];

  @override
  Future<AppStateSnapshot> load() async {
    return _seedSnapshot();
  }

  @override
  Future<void> setCurrentRegionId(String regionId) async {
    currentRegionId = regionId;
  }

  @override
  Future<void> setDownloadedRegionIds(Set<String> ids) async {
    downloadedIds = ids;
  }

  @override
  Future<void> setHasSeenOnboarding(bool value) async {
    hasSeenOnboarding = value;
  }

  @override
  Future<void> setPermissions(
    Map<TrackingPermissionType, PermissionGrantState> permissions,
  ) async {
    this.permissions = permissions;
  }

  @override
  Future<void> setUserPoints(List<UserPoint> points) async {
    userPoints = points;
  }

  AppStateSnapshot _seedSnapshot() {
    return AppStateSnapshot(
      hasSeenOnboarding: hasSeenOnboarding,
      permissions: permissions,
      isTracking: true,
      gpsQuality: GpsQuality.good,
      regions: const [
        Region(
          id: 'r1',
          name: 'Region 1',
          totalArea: 10,
          exploredArea: 0,
          isDownloaded: false,
          center: LatLng(0, 0),
          bounds: [LatLng(0, 0), LatLng(0, 1), LatLng(1, 1), LatLng(1, 0)],
          features: RegionFeatures(
            trails: RegionFeatureProgress(total: 1, completed: 0),
            peaks: RegionFeatureProgress(total: 1, completed: 0),
            huts: RegionFeatureProgress(total: 1, completed: 0),
          ),
        ),
      ],
      currentRegionId: currentRegionId,
      userPoints: userPoints,
    );
  }
}

void main() {
  test('setHasSeenOnboarding updates state and persists', () async {
    final repository = FakeAppStateRepository();
    final viewModel = AppStateViewModel(
      repository: repository,
      initialState: await repository.load(),
    );

    await viewModel.setHasSeenOnboarding(true);

    expect(viewModel.hasSeenOnboarding, isTrue);
    expect(repository.hasSeenOnboarding, isTrue);
  });

  test('downloadRegion marks region and persists ids', () async {
    final repository = FakeAppStateRepository();
    final viewModel = AppStateViewModel(
      repository: repository,
      initialState: await repository.load(),
    );

    await viewModel.downloadRegion('r1');

    expect(viewModel.regions.first.isDownloaded, isTrue);
    expect(repository.downloadedIds, contains('r1'));
  });

  test('add and remove user points persist', () async {
    final repository = FakeAppStateRepository();
    final viewModel = AppStateViewModel(
      repository: repository,
      initialState: await repository.load(),
    );

    await viewModel.addUserPoint(1.1, 2.2);
    expect(viewModel.userPoints.length, 1);
    expect(repository.userPoints.length, 1);

    final id = viewModel.userPoints.first.id;
    await viewModel.removeUserPoint(id);

    expect(viewModel.userPoints, isEmpty);
    expect(repository.userPoints, isEmpty);
  });
}
