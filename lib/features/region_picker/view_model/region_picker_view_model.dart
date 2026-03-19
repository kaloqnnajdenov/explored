import 'package:flutter/foundation.dart';

import '../../app_state/view_model/app_state_view_model.dart';
import '../../region_catalog/data/models/region_pack_node.dart';

class RegionPickerViewModel extends ChangeNotifier {
  RegionPickerViewModel({required this.appStateViewModel});

  final AppStateViewModel appStateViewModel;
  final List<String> _navigationStack = <String>[];
  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  bool get isSearching => _searchQuery.trim().isNotEmpty;

  bool get canGoBack => _navigationStack.isNotEmpty || isSearching;

  String? get currentParentId =>
      _navigationStack.isEmpty ? null : _navigationStack.last;

  bool get isCurrentLevelLoading =>
      appStateViewModel.isLoadingChildren(currentParentId);

  List<RegionPackNode> get breadcrumbNodes {
    final currentParentId = this.currentParentId;
    if (currentParentId == null) {
      return const <RegionPackNode>[];
    }

    return [
      ...appStateViewModel.ancestorsOf(currentParentId),
      appStateViewModel.packById(currentParentId)!,
    ];
  }

  List<RegionPackNode> get visibleNodes {
    if (isSearching) {
      final query = _searchQuery.trim().toLowerCase();
      final matches =
          appStateViewModel.packs
              .where((node) {
                final name = node.name.toLowerCase();
                final displayPath = node.displayPath.toLowerCase();
                return name.contains(query) || displayPath.contains(query);
              })
              .toList(growable: false)
            ..sort(
              (a, b) => a.displayPath.toLowerCase().compareTo(
                b.displayPath.toLowerCase(),
              ),
            );
      return matches;
    }

    return appStateViewModel.childrenOf(currentParentId);
  }

  bool isSelected(String nodeId) => appStateViewModel.selectedPackId == nodeId;

  Future<void> initialize() {
    return appStateViewModel.ensureChildrenLoaded(currentParentId);
  }

  void setSearchQuery(String value) {
    if (_searchQuery == value) {
      return;
    }
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> openChildren(RegionPackNode node) async {
    if (!node.hasChildren) {
      return;
    }
    await appStateViewModel.ensureChildrenLoaded(node.id);
    _navigationStack.add(node.id);
    _searchQuery = '';
    notifyListeners();
  }

  void goBack() {
    if (isSearching) {
      _searchQuery = '';
      notifyListeners();
      return;
    }

    if (_navigationStack.isEmpty) {
      return;
    }
    _navigationStack.removeLast();
    notifyListeners();
  }

  Future<void> selectPack(RegionPackNode node) {
    return appStateViewModel.setSelectedPackId(node.id);
  }
}
