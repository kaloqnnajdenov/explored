import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/app_permission.dart';
import '../data/models/app_state_snapshot.dart';
import '../data/models/gps_quality.dart';
import '../data/models/user_point.dart';
import '../data/repositories/app_state_repository.dart';
import '../../region_catalog/data/models/region_boundary.dart';
import '../../region_catalog/data/models/region_catalog.dart';
import '../../region_catalog/data/models/region_pack_node.dart';
import '../../region_catalog/data/models/selected_pack_ref.dart';

class AppStateViewModel extends ChangeNotifier {
  AppStateViewModel({
    required AppStateRepository repository,
    required AppStateSnapshot initialState,
  }) : _repository = repository,
       _state = initialState {
    if (initialState.regionCatalog.rootIds.isNotEmpty) {
      unawaited(_refreshSelectedBoundaries());
    }
  }

  final AppStateRepository _repository;

  AppStateSnapshot _state;
  RegionBoundary? _selectedBoundary;
  RegionBoundary? _selectedParentRegionBoundary;
  bool _isLoadingSelectedBoundary = false;
  bool _isLoadingDownloadedPacks = false;
  int _selectionLoadId = 0;
  Future<void>? _bootstrapFuture;
  final Set<String> _loadingParentIds = <String>{};

  bool get hasSeenOnboarding => _state.hasSeenOnboarding;

  Map<TrackingPermissionType, PermissionGrantState> get permissions =>
      _state.permissions;

  bool get isTracking => _state.isTracking;

  GpsQuality get gpsQuality => _state.gpsQuality;

  RegionCatalog get regionCatalog => _state.regionCatalog;

  List<RegionPackNode> get packs => _state.regionCatalog.allNodes;

  List<RegionPackNode> get regions => packs;

  List<RegionPackNode> get rootPacks => _state.regionCatalog.rootNodes;

  List<RegionPackNode> get downloadedPacks =>
      packs.where((pack) => pack.isDownloaded).toList(growable: false);

  String get selectedPackId => _state.selectedPackId;

  String get currentRegionId => selectedPackId;

  SelectedPackRef? get selectedPackRef => _state.selectedPackRef;

  bool get isCatalogLoading => _state.isCatalogLoading;

  String? get catalogError => _state.catalogError;

  bool get hasLoadedRootPacks => _state.hasLoadedRootPacks;

  bool get isLoadingDownloadedPacks => _isLoadingDownloadedPacks;

  bool get hasPendingDownloadedPackRefs =>
      _state.downloadedPackRefs.any((ref) => !regionCatalog.contains(ref.id));

  RegionPackNode? get selectedPackOrNull {
    if (_state.selectedPackId.isEmpty) {
      return rootPacks.firstOrNull;
    }
    return _state.regionCatalog.maybeNodeById(_state.selectedPackId) ??
        rootPacks.firstOrNull;
  }

  RegionPackNode get selectedPack {
    final pack = selectedPackOrNull;
    if (pack == null) {
      throw StateError('No selected pack is available');
    }
    return pack;
  }

  RegionPackNode get currentRegion => selectedPack;

  List<UserPoint> get userPoints => _state.userPoints;

  RegionBoundary? get selectedBoundary => _selectedBoundary;

  RegionBoundary? get selectedParentRegionBoundary =>
      _selectedParentRegionBoundary;

  bool get isLoadingSelectedBoundary => _isLoadingSelectedBoundary;

  RegionPackNode? packById(String id) => _state.regionCatalog.maybeNodeById(id);

  List<RegionPackNode> childrenOf(String? parentId) {
    return _state.regionCatalog.childrenOf(parentId);
  }

  List<RegionPackNode> ancestorsOf(String id) {
    return _state.regionCatalog.ancestorsOf(id);
  }

  RegionPackNode? countryFor(String id) {
    return _state.regionCatalog.countryAncestorOf(id);
  }

  RegionPackNode? regionFor(String id) {
    return _state.regionCatalog.regionAncestorOf(id);
  }

  bool areChildrenLoaded(String? parentId) {
    if (parentId == null) {
      return hasLoadedRootPacks;
    }
    final parent = packById(parentId);
    if (parent == null) {
      return false;
    }
    if (!parent.hasChildren) {
      return true;
    }
    return parent.childIds.isNotEmpty;
  }

  bool isLoadingChildren(String? parentId) {
    if (parentId == null) {
      return isCatalogLoading && !hasLoadedRootPacks;
    }
    return _loadingParentIds.contains(parentId);
  }

  Future<void> bootstrap() {
    return _bootstrapFuture ??= _bootstrapCatalog();
  }

  Future<void> ensureChildrenLoaded(String? parentId) async {
    if (parentId == null) {
      await bootstrap();
      return;
    }
    if (_loadingParentIds.contains(parentId) || areChildrenLoaded(parentId)) {
      return;
    }

    _loadingParentIds.add(parentId);
    _state = _state.copyWith(catalogError: null);
    notifyListeners();

    try {
      final children = await _repository.loadChildren(parentId);
      final parent = packById(parentId);
      final mergedNodes = parent == null
          ? children
          : [
              parent.copyWith(
                childIds: children
                    .map((child) => child.id)
                    .toList(growable: false),
                hasChildren: children.isNotEmpty,
              ),
              ...children,
            ];
      _state = _state.copyWith(
        regionCatalog: _state.regionCatalog.mergeNodes(mergedNodes),
      );
    } catch (error) {
      _state = _state.copyWith(catalogError: error.toString());
    } finally {
      _loadingParentIds.remove(parentId);
      notifyListeners();
    }
  }

  Future<void> ensureDownloadedPacksLoaded() async {
    if (_isLoadingDownloadedPacks || !hasPendingDownloadedPackRefs) {
      return;
    }

    _isLoadingDownloadedPacks = true;
    notifyListeners();
    try {
      final nodes = await _repository.loadDownloadedPacks();
      _state = _state.copyWith(
        regionCatalog: _state.regionCatalog.mergeNodes(nodes),
        catalogError: null,
      );
    } catch (error) {
      _state = _state.copyWith(catalogError: error.toString());
    } finally {
      _isLoadingDownloadedPacks = false;
      notifyListeners();
    }
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    _state = _state.copyWith(hasSeenOnboarding: value);
    notifyListeners();
    await _repository.setHasSeenOnboarding(value);
  }

  Future<void> setPermission(
    TrackingPermissionType type,
    PermissionGrantState state,
  ) async {
    final updated = Map<TrackingPermissionType, PermissionGrantState>.from(
      _state.permissions,
    )..[type] = state;
    _state = _state.copyWith(permissions: updated);
    notifyListeners();
    await _repository.setPermissions(updated);
  }

  Future<void> setPermissions(
    Map<TrackingPermissionType, PermissionGrantState> values,
  ) async {
    _state = _state.copyWith(
      permissions: Map<TrackingPermissionType, PermissionGrantState>.from(
        values,
      ),
    );
    notifyListeners();
    await _repository.setPermissions(_state.permissions);
  }

  Future<void> setSelectedPackId(String id) async {
    if (!_state.regionCatalog.contains(id)) {
      return;
    }

    final ref = _buildSelectedPackRef(id);
    _state = _state.copyWith(selectedPackId: id, selectedPackRef: ref);
    notifyListeners();
    unawaited(_refreshSelectedBoundaries());
    await _repository.setSelectedPack(ref);
  }

  Future<void> setCurrentRegionId(String id) => setSelectedPackId(id);

  Future<void> downloadPack(String id) async {
    final pack = packById(id);
    if (pack == null) {
      return;
    }

    final refsById = <String, SelectedPackRef>{
      for (final ref in _state.downloadedPackRefs) ref.id: ref,
      id: _buildSelectedPackRef(pack.id),
    };
    final downloadedIds = refsById.keys.toSet();
    _state = _state.copyWith(
      regionCatalog: _state.regionCatalog.copyWithDownloadedIds(downloadedIds),
      downloadedPackRefs: refsById.values.toList(growable: false),
    );
    notifyListeners();
    await _repository.setDownloadedPacks(
      refsById.values.toList(growable: false),
    );
  }

  Future<void> downloadRegion(String id) => downloadPack(id);

  Future<void> setGpsQuality(GpsQuality quality) async {
    if (_state.gpsQuality == quality) {
      return;
    }
    _state = _state.copyWith(gpsQuality: quality);
    notifyListeners();
  }

  Future<void> addUserPoint(double latitude, double longitude) async {
    final newPoint = UserPoint(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      latitude: latitude,
      longitude: longitude,
      createdAt: DateTime.now().toUtc(),
    );
    final updatedPoints = List<UserPoint>.from(_state.userPoints)
      ..add(newPoint);
    _state = _state.copyWith(userPoints: updatedPoints);
    notifyListeners();
    await _repository.setUserPoints(updatedPoints);
  }

  Future<void> removeUserPoint(String id) async {
    final updatedPoints = _state.userPoints
        .where((point) => point.id != id)
        .toList(growable: false);
    _state = _state.copyWith(userPoints: updatedPoints);
    notifyListeners();
    await _repository.setUserPoints(updatedPoints);
  }

  Future<RegionBoundary?> loadBoundaryFor(String id) async {
    if (!_state.regionCatalog.contains(id)) {
      return null;
    }

    try {
      return await _repository.loadBoundary(id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _bootstrapCatalog() async {
    _state = _state.copyWith(isCatalogLoading: true, catalogError: null);
    notifyListeners();

    try {
      final rootPacks = await _repository.loadRootPacks();
      _state = _state.copyWith(
        regionCatalog: _state.regionCatalog.mergeNodes(rootPacks),
        hasLoadedRootPacks: true,
      );
      notifyListeners();

      final restoredNodes = await _repository.restoreSelectedPack();
      if (restoredNodes.isNotEmpty) {
        _state = _state.copyWith(
          regionCatalog: _state.regionCatalog.mergeNodes(restoredNodes),
        );
      }

      final resolvedSelectedPack =
          _state.regionCatalog.maybeNodeById(_state.selectedPackId) ??
          rootPacks.firstOrNull;
      final selectedPackId = resolvedSelectedPack?.id ?? '';
      final selectedPackRef = resolvedSelectedPack == null
          ? null
          : _buildSelectedPackRef(selectedPackId);
      _state = _state.copyWith(
        selectedPackId: selectedPackId,
        selectedPackRef: selectedPackRef,
        isCatalogLoading: false,
        catalogError: null,
      );
      notifyListeners();

      if (selectedPackRef != null) {
        await _repository.setSelectedPack(selectedPackRef);
      }
      unawaited(_refreshSelectedBoundaries());
    } catch (error) {
      _state = _state.copyWith(
        isCatalogLoading: false,
        catalogError: error.toString(),
      );
      notifyListeners();
    }
  }

  SelectedPackRef _buildSelectedPackRef(String id) {
    final pack = _state.regionCatalog.nodeById(id);
    final ancestors = _state.regionCatalog.ancestorsOf(id);
    return SelectedPackRef(
      id: pack.id,
      kind: pack.kind,
      name: pack.name,
      geometryAssetPath: pack.geometryAssetPath,
      ancestors: ancestors
          .map(
            (ancestor) => SelectedPackAncestorRef(
              id: ancestor.id,
              kind: ancestor.kind,
              name: ancestor.name,
              geometryAssetPath: ancestor.geometryAssetPath,
            ),
          )
          .toList(growable: false),
    );
  }

  Future<void> _refreshSelectedBoundaries() async {
    final selectedPack = selectedPackOrNull;
    if (selectedPack == null) {
      _selectedBoundary = null;
      _selectedParentRegionBoundary = null;
      _isLoadingSelectedBoundary = false;
      notifyListeners();
      return;
    }

    final loadId = ++_selectionLoadId;
    _isLoadingSelectedBoundary = true;
    notifyListeners();

    RegionBoundary? selectedBoundary;
    RegionBoundary? parentRegionBoundary;
    try {
      selectedBoundary = await _repository.loadBoundary(selectedPack.id);
      final selectedRegion = regionFor(selectedPack.id);
      if (selectedRegion != null && selectedRegion.id != selectedPack.id) {
        parentRegionBoundary = await _repository.loadBoundary(
          selectedRegion.id,
        );
      }
    } catch (_) {
      selectedBoundary = null;
      parentRegionBoundary = null;
    }

    if (loadId != _selectionLoadId) {
      return;
    }

    _selectedBoundary = selectedBoundary;
    _selectedParentRegionBoundary = parentRegionBoundary;
    _isLoadingSelectedBoundary = false;
    notifyListeners();
  }
}
