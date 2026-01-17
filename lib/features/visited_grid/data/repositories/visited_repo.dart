import 'package:drift/drift.dart';

import '../services/visited_grid_database.dart';

abstract class VisitedRepo {
  Future<Set<String>> fetchLifetimeVisited({
    required int resolution,
    required List<String> candidateIds,
  });

  Future<Set<String>> fetchDailyVisited({
    required int resolution,
    required int fromDay,
    required int toDay,
    required List<String> candidateIds,
  });
}

class DriftVisitedRepo implements VisitedRepo {
  DriftVisitedRepo({
    required VisitedGridDao visitedGridDao,
    int maxChunkSize = 800,
  })  : _visitedGridDao = visitedGridDao,
        _maxChunkSize = maxChunkSize;

  final VisitedGridDao _visitedGridDao;
  final int _maxChunkSize;

  @override
  Future<Set<String>> fetchLifetimeVisited({
    required int resolution,
    required List<String> candidateIds,
  }) async {
    if (candidateIds.isEmpty) {
      return <String>{};
    }

    final result = <String>{};
    for (final chunk in chunkBySize(candidateIds, _maxChunkSize)) {
      final placeholders = List.filled(chunk.length, '?').join(', ');
      final query = '''
SELECT cell_id
FROM visits_lifetime
WHERE res = ?
  AND cell_id IN ($placeholders)
''';
      final variables = <Variable>[
        Variable.withInt(resolution),
        ...chunk.map(Variable.withString),
      ];
      final rows = await _visitedGridDao
          .customSelect(query, variables: variables)
          .get();
      for (final row in rows) {
        result.add(row.read<String>('cell_id'));
      }
    }

    return result;
  }

  @override
  Future<Set<String>> fetchDailyVisited({
    required int resolution,
    required int fromDay,
    required int toDay,
    required List<String> candidateIds,
  }) async {
    if (candidateIds.isEmpty) {
      return <String>{};
    }

    final result = <String>{};
    for (final chunk in chunkBySize(candidateIds, _maxChunkSize)) {
      final placeholders = List.filled(chunk.length, '?').join(', ');
      final query = '''
SELECT DISTINCT cell_id
FROM visits_daily
WHERE res = ?
  AND day_yyyy_mmdd BETWEEN ? AND ?
  AND cell_id IN ($placeholders)
''';
      final variables = <Variable>[
        Variable.withInt(resolution),
        Variable.withInt(fromDay),
        Variable.withInt(toDay),
        ...chunk.map(Variable.withString),
      ];
      final rows = await _visitedGridDao
          .customSelect(query, variables: variables)
          .get();
      for (final row in rows) {
        result.add(row.read<String>('cell_id'));
      }
    }

    return result;
  }
}

Iterable<List<T>> chunkBySize<T>(List<T> input, int size) sync* {
  if (size <= 0) {
    throw ArgumentError.value(size, 'size', 'Chunk size must be positive');
  }
  for (var i = 0; i < input.length; i += size) {
    final end = i + size > input.length ? input.length : i + size;
    yield input.sublist(i, end);
  }
}
