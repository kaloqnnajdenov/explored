import '../models/app_permission.dart';
import '../models/app_state_snapshot.dart';
import '../models/gps_quality.dart';
import '../models/user_point.dart';
import '../services/app_state_prefs_service.dart';
import '../../../region_catalog/data/models/region_boundary.dart';
import '../../../region_catalog/data/models/region_catalog.dart';
import '../../../region_catalog/data/models/region_pack_node.dart';
import '../../../region_catalog/data/models/selected_pack_ref.dart';
import '../../../region_catalog/data/repositories/region_catalog_repository.dart';

abstract class AppStateRepository {
  AppStateSnapshot createInitialState();

  Future<List<RegionPackNode>> loadRootPacks();

  Future<List<RegionPackNode>> restoreSelectedPack();

  Future<List<RegionPackNode>> loadChildren(String parentId);

  Future<List<RegionPackNode>> loadDownloadedPacks();

  Future<void> setHasSeenOnboarding(bool value);

  Future<void> setPermissions(
    Map<TrackingPermissionType, PermissionGrantState> permissions,
  );

  Future<void> setSelectedPack(SelectedPackRef ref);

  Future<void> setDownloadedPacks(List<SelectedPackRef> refs);

  Future<void> setUserPoints(List<UserPoint> points);

  Future<RegionBoundary> loadBoundary(String packId);
}

class DefaultAppStateRepository implements AppStateRepository {
  DefaultAppStateRepository({
    required AppStatePrefsService prefsService,
    required RegionCatalogRepository regionCatalogRepository,
  }) : _prefsService = prefsService,
       _regionCatalogRepository = regionCatalogRepository;

  final AppStatePrefsService _prefsService;
  final RegionCatalogRepository _regionCatalogRepository;

  @override
  AppStateSnapshot createInitialState() {
    final selectedPackRef = _prefsService.readSelectedPackRef();
    return AppStateSnapshot(
      hasSeenOnboarding: _prefsService.readHasSeenOnboarding(),
      permissions: _prefsService.readPermissions(),
      isTracking: true,
      gpsQuality: GpsQuality.good,
      regionCatalog: RegionCatalog.empty,
      selectedPackId:
          selectedPackRef?.id ?? _prefsService.readSelectedPackId() ?? '',
      selectedPackRef: selectedPackRef,
      downloadedPackRefs: _prefsService.readDownloadedPackRefs(),
      isCatalogLoading: false,
      catalogError: null,
      hasLoadedRootPacks: false,
      userPoints: _prefsService.readUserPoints(),
    );
  }

  @override
  Future<List<RegionPackNode>> loadRootPacks() async {
    return _markDownloaded(await _regionCatalogRepository.loadRootCountries());
  }

  @override
  Future<List<RegionPackNode>> restoreSelectedPack() async {
    final selectedPackRef = _prefsService.readSelectedPackRef();
    if (selectedPackRef == null) {
      return const <RegionPackNode>[];
    }
    return _markDownloaded(
      await _regionCatalogRepository.loadNodesForSelectionRef(selectedPackRef),
    );
  }

  @override
  Future<List<RegionPackNode>> loadChildren(String parentId) async {
    return _markDownloaded(
      await _regionCatalogRepository.loadChildren(parentId),
    );
  }

  @override
  Future<List<RegionPackNode>> loadDownloadedPacks() async {
    final refs = _prefsService.readDownloadedPackRefs();
    final nodesById = <String, RegionPackNode>{};
    for (final ref in refs) {
      final nodes = await _regionCatalogRepository.loadNodesForSelectionRef(
        ref,
      );
      for (final node in nodes) {
        nodesById[node.id] = node;
      }
    }
    return _markDownloaded(nodesById.values.toList(growable: false));
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
  Future<void> setSelectedPack(SelectedPackRef ref) {
    return _prefsService.writeSelectedPackRef(ref);
  }

  @override
  Future<void> setDownloadedPacks(List<SelectedPackRef> refs) {
    return _prefsService.writeDownloadedPackRefs(refs);
  }

  @override
  Future<void> setUserPoints(List<UserPoint> points) {
    return _prefsService.writeUserPoints(points);
  }

  @override
  Future<RegionBoundary> loadBoundary(String packId) {
    return _regionCatalogRepository.loadBoundary(packId);
  }

  List<RegionPackNode> _markDownloaded(List<RegionPackNode> nodes) {
    final downloadedIds = _prefsService.readDownloadedPackIds();
    return nodes
        .map(
          (node) => downloadedIds.contains(node.id)
              ? node.copyWith(isDownloaded: true)
              : node,
        )
        .toList(growable: false);
  }
}
