import 'package:latlong2/latlong.dart';

import '../../../location/data/models/lat_lng_sample.dart';
import '../../../location/data/repositories/location_history_repository.dart';
import '../../../location/data/services/location_history_database.dart';
import '../../../visited_grid/data/models/visited_grid_config.dart';
import '../../../visited_grid/data/repositories/visited_grid_repository.dart';
import '../../../visited_grid/data/services/visited_grid_h3_service.dart';
import '../models/manual_explore_delete_summary.dart';

abstract class ManualExploreRepository {
  String cellIdForLatLng(LatLng location);

  bool isCellExplored(String cellId);

  LatLng cellCenter(String cellId);

  List<LatLng> cellBoundary({
    required String cellId,
    required double zoom,
  });

  Future<ManualExploreDeleteSummary> fetchDeleteSummary(
    Set<String> deleteCellIds,
  );

  Future<ManualExploreSaveResult> applyEdits({
    required Set<String> addCellIds,
    required Set<String> deleteCellIds,
    required DateTime timestampUtc,
  });
}

class ManualExploreSaveResult {
  const ManualExploreSaveResult({
    required this.addedCells,
    required this.deletedCells,
    required this.deletedSamples,
  });

  final int addedCells;
  final int deletedCells;
  final int deletedSamples;

  bool get hasChanges => addedCells > 0 || deletedCells > 0;
}

class DefaultManualExploreRepository implements ManualExploreRepository {
  DefaultManualExploreRepository({
    required LocationHistoryRepository historyRepository,
    required LocationHistoryDao historyDao,
    required VisitedGridRepository visitedGridRepository,
    required VisitedGridH3Service h3Service,
    VisitedGridConfig config = const VisitedGridConfig(),
  })  : _historyRepository = historyRepository,
        _historyDao = historyDao,
        _visitedGridRepository = visitedGridRepository,
        _h3Service = h3Service,
        _config = config;

  final LocationHistoryRepository _historyRepository;
  final LocationHistoryDao _historyDao;
  final VisitedGridRepository _visitedGridRepository;
  final VisitedGridH3Service _h3Service;
  final VisitedGridConfig _config;
  Set<String>? _exploredCellCache;

  @override
  String cellIdForLatLng(LatLng location) {
    final cell = _h3Service.cellForLatLng(
      latitude: location.latitude,
      longitude: location.longitude,
      resolution: _config.baseResolution,
    );
    return _h3Service.encodeCellId(cell);
  }

  @override
  bool isCellExplored(String cellId) {
    _exploredCellCache ??= _buildExploredCellCache();
    return _exploredCellCache!.contains(cellId);
  }

  @override
  LatLng cellCenter(String cellId) {
    final cell = _h3Service.decodeCellId(cellId);
    final center = _h3Service.cellToGeo(cell);
    return LatLng(center.lat, center.lon);
  }

  @override
  List<LatLng> cellBoundary({
    required String cellId,
    required double zoom,
  }) {
    final cell = _h3Service.decodeCellId(cellId);
    return _h3Service.cellBoundary(cell);
  }

  @override
  Future<ManualExploreDeleteSummary> fetchDeleteSummary(
    Set<String> deleteCellIds,
  ) async {
    final sampleCount = await _historyDao.countSamplesForBaseCellIds(
      deleteCellIds,
    );
    return ManualExploreDeleteSummary(
      cellCount: deleteCellIds.length,
      sampleCount: sampleCount,
    );
  }

  @override
  Future<ManualExploreSaveResult> applyEdits({
    required Set<String> addCellIds,
    required Set<String> deleteCellIds,
    required DateTime timestampUtc,
  }) async {
    final normalizedAdds = addCellIds.difference(deleteCellIds);
    final normalizedDeletes = deleteCellIds.difference(addCellIds);
    if (normalizedAdds.isEmpty && normalizedDeletes.isEmpty) {
      return const ManualExploreSaveResult(
        addedCells: 0,
        deletedCells: 0,
        deletedSamples: 0,
      );
    }

    Set<String> cellsToInsert = const <String>{};
    if (normalizedAdds.isNotEmpty) {
      final existing = await _historyDao.fetchExistingBaseCellIds(
        normalizedAdds,
      );
      cellsToInsert = normalizedAdds.difference(existing);
    }

    var deleteSampleCount = 0;
    if (normalizedDeletes.isNotEmpty) {
      deleteSampleCount = await _historyDao.countSamplesForBaseCellIds(
        normalizedDeletes,
      );
      if (deleteSampleCount == 0 && cellsToInsert.isEmpty) {
        return const ManualExploreSaveResult(
          addedCells: 0,
          deletedCells: 0,
          deletedSamples: 0,
        );
      }
    }

    final samplesToInsert = <LatLngSample>[];
    for (final cellId in cellsToInsert) {
      final center = cellCenter(cellId);
      samplesToInsert.add(
        LatLngSample(
          latitude: center.latitude,
          longitude: center.longitude,
          timestamp: timestampUtc,
          accuracyMeters: null,
          isInterpolated: false,
          source: LatLngSampleSource.manual,
        ),
      );
    }

    final editResult = await _historyRepository.applyManualEdits(
      insertSamples: samplesToInsert,
      deleteBaseCellIds: normalizedDeletes,
    );

    if (_exploredCellCache != null) {
      _exploredCellCache!
        ..removeAll(normalizedDeletes)
        ..addAll(cellsToInsert);
    }

    if (normalizedDeletes.isNotEmpty && deleteSampleCount > 0) {
      await _visitedGridRepository.rebuildFromHistory();
    } else if (editResult.insertedSamples.isNotEmpty) {
      await _visitedGridRepository.ingestSamples(editResult.insertedSamples);
    }

    return ManualExploreSaveResult(
      addedCells: cellsToInsert.length,
      deletedCells:
          deleteSampleCount == 0 ? 0 : normalizedDeletes.length,
      deletedSamples: deleteSampleCount == 0
          ? 0
          : editResult.deletedSamples,
    );
  }

  Set<String> _buildExploredCellCache() {
    final explored = <String>{};
    for (final sample in _historyRepository.currentSamples) {
      final cell = _h3Service.cellForLatLng(
        latitude: sample.latitude,
        longitude: sample.longitude,
        resolution: _config.baseResolution,
      );
      explored.add(_h3Service.encodeCellId(cell));
    }
    return explored;
  }
}
