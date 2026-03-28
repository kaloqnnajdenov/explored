import 'entity.dart';
import 'entity_totals.dart';

class CountProgress {
  const CountProgress({
    required this.explored,
    required this.total,
  });

  final int explored;
  final int total;

  bool get hasData => total > 0;

  double get percentage => hasData ? explored / total : 0;
}

class LengthProgress {
  const LengthProgress({
    required this.exploredLengthM,
    required this.totalLengthM,
  });

  final double exploredLengthM;
  final double totalLengthM;

  bool get hasData => totalLengthM > 0;

  double get percentage => hasData ? exploredLengthM / totalLengthM : 0;
}

class EntityProgress {
  const EntityProgress({
    required this.entity,
    required this.totals,
    required this.peaks,
    required this.huts,
    required this.monuments,
    required this.roadsDrivable,
    required this.roadsWalkable,
    required this.roadsCycleway,
  });

  final Entity entity;
  final EntityTotals totals;
  final CountProgress peaks;
  final CountProgress huts;
  final CountProgress monuments;
  final LengthProgress roadsDrivable;
  final LengthProgress roadsWalkable;
  final LengthProgress roadsCycleway;
}
