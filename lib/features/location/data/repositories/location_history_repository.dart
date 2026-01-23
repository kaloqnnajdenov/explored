import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/history_export_result.dart';
import '../models/lat_lng_sample.dart';
import '../services/location_history_database.dart';
import '../services/location_history_export_service.dart';
import 'location_updates_repository.dart';

abstract class LocationHistoryRepository {
  Stream<List<LatLngSample>> get historyStream;

  List<LatLngSample> get currentSamples;

  Future<void> start();

  Future<void> stop();

  Future<void> dispose();

  Future<List<LatLngSample>> addImportedSamples(
    List<LatLngSample> samples,
  );

  /// Exports the full persisted history dataset as a CSV file.
  Future<HistoryExportResult> exportHistory();

  /// Saves the full persisted history dataset as a CSV file on device storage.
  Future<HistoryExportResult> downloadHistory();
}

class DefaultLocationHistoryRepository implements LocationHistoryRepository {
  DefaultLocationHistoryRepository({
    required LocationUpdatesRepository locationUpdatesRepository,
    required LocationHistoryDao historyDao,
    required LocationHistoryExportService exportService,
  })  : _locationUpdatesRepository = locationUpdatesRepository,
        _historyDao = historyDao,
        _exportService = exportService {
    _controller = StreamController<List<LatLngSample>>.broadcast();
  }

  final LocationUpdatesRepository _locationUpdatesRepository;
  final LocationHistoryDao _historyDao;
  final LocationHistoryExportService _exportService;
  late final StreamController<List<LatLngSample>> _controller;
  StreamSubscription<LatLngSample>? _subscription;
  final List<LatLngSample> _samples = <LatLngSample>[];
  final Set<_SampleKey> _sampleKeys = <_SampleKey>{};
  Future<void> _persistChain = Future<void>.value();
  bool _hasLoaded = false;

  @override
  Stream<List<LatLngSample>> get historyStream => _controller.stream;

  @override
  List<LatLngSample> get currentSamples =>
      List<LatLngSample>.unmodifiable(_samples);

  @override
  Future<void> start() async {
    await _ensureLoaded();
    _subscription ??=
        _locationUpdatesRepository.locationUpdates.listen(_handleSample);
  }

  @override
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }

  @override
  Future<List<LatLngSample>> addImportedSamples(
    List<LatLngSample> samples,
  ) async {
    if (samples.isEmpty) {
      return const <LatLngSample>[];
    }

    final added = <LatLngSample>[];
    for (final sample in samples) {
      if (_addSample(sample)) {
        added.add(sample);
      }
    }

    if (added.isNotEmpty) {
      _samples.sort(_compareSamples);
      _emit();
      await _queuePersist(added);
    }

    return added;
  }

  @override
  Future<HistoryExportResult> exportHistory() async {
    await _syncPersistedHistoryIfNeeded();
    return _exportService.exportHistory();
  }

  @override
  Future<HistoryExportResult> downloadHistory() async {
    await _syncPersistedHistoryIfNeeded();
    return _exportService.downloadHistory();
  }

  void _handleSample(LatLngSample sample) {
    if (_addSample(sample)) {
      unawaited(_queuePersist([sample]));
      _emit();
    }
  }

  bool _addSample(LatLngSample sample) {
    final key = _SampleKey.fromSample(sample);
    if (_sampleKeys.contains(key)) {
      return false;
    }
    _sampleKeys.add(key);
    _samples.add(sample);
    return true;
  }

  Future<void> _loadPersistedSamples() async {
    try {
      final rows = await _historyDao.fetchAllSamples();
      if (rows.isEmpty) {
        return;
      }
      _samples
        ..clear()
        ..addAll(rows.map(_toSample));
      _sampleKeys
        ..clear()
        ..addAll(_samples.map(_SampleKey.fromSample));
      _samples.sort(_compareSamples);
      _emit();
    } catch (error) {
      debugPrint('Failed to load history samples: $error');
    }
  }

  LatLngSample _toSample(LocationSample row) {
    return LatLngSample(
      latitude: row.latitude,
      longitude: row.longitude,
      timestamp: DateTime.parse(row.timestamp),
      accuracyMeters: row.accuracyMeters,
      isInterpolated: row.isInterpolated,
      source: row.source,
    );
  }

  Future<void> _queuePersist(Iterable<LatLngSample> samples) {
    if (samples.isEmpty) {
      return _persistChain;
    }
    final batch = List<LatLngSample>.from(samples);
    _persistChain = _persistChain.then((_) async {
      try {
        await _historyDao.insertSamples(batch);
      } catch (error) {
        debugPrint('Failed to persist history samples: $error');
      }
    });
    return _persistChain;
  }

  Future<void> _ensureLoaded() async {
    if (_hasLoaded) {
      return;
    }
    await _loadPersistedSamples();
    _hasLoaded = true;
  }

  Future<void> _syncPersistedHistoryIfNeeded() async {
    await _persistChain;
    await _ensureLoaded();
    final memoryCount = _samples.length;
    final persistedCount = await _historyDao.fetchSampleCount();
    debugPrint(
      'History sync check: memory=$memoryCount persisted=$persistedCount',
    );
    if (memoryCount == 0 || memoryCount <= persistedCount) {
      return;
    }
    try {
      await _historyDao.replaceAllSamples(_samples);
    } catch (error) {
      debugPrint('Failed to sync history samples: $error');
    }
  }

  void _emit() {
    if (_controller.isClosed) {
      return;
    }
    _controller.add(List<LatLngSample>.unmodifiable(_samples));
  }

  int _compareSamples(LatLngSample a, LatLngSample b) {
    final timeCompare = a.timestamp.compareTo(b.timestamp);
    if (timeCompare != 0) {
      return timeCompare;
    }
    final latCompare = a.latitude.compareTo(b.latitude);
    if (latCompare != 0) {
      return latCompare;
    }
    return a.longitude.compareTo(b.longitude);
  }
}

class _SampleKey {
  const _SampleKey({
    required this.latE5,
    required this.lonE5,
    required this.timestampMicros,
  });

  final int latE5;
  final int lonE5;
  final int timestampMicros;

  factory _SampleKey.fromSample(LatLngSample sample) {
    return _SampleKey(
      latE5: (sample.latitude * 100000).round(),
      lonE5: (sample.longitude * 100000).round(),
      timestampMicros: sample.timestamp.microsecondsSinceEpoch,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! _SampleKey) {
      return false;
    }
    return latE5 == other.latE5 &&
        lonE5 == other.lonE5 &&
        timestampMicros == other.timestampMicros;
  }

  @override
  int get hashCode => Object.hash(latE5, lonE5, timestampMicros);
}
