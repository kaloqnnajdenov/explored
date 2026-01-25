import 'manual_explore_edit_kind.dart';

class ManualExploreAction {
  ManualExploreAction({
    required this.kind,
    required Set<String> cellIds,
  }) : cellIds = Set<String>.unmodifiable(cellIds);

  final ManualExploreEditKind kind;
  final Set<String> cellIds;
}
