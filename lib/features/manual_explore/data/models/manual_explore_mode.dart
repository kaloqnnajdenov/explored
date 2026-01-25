import 'manual_explore_edit_kind.dart';

enum ManualExploreMode { add, delete }

extension ManualExploreModeX on ManualExploreMode {
  ManualExploreEditKind get editKind {
    switch (this) {
      case ManualExploreMode.add:
        return ManualExploreEditKind.add;
      case ManualExploreMode.delete:
        return ManualExploreEditKind.delete;
    }
  }
}
