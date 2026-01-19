import 'dart:async';

import '../models/lat_lng_sample.dart';
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
}

class DefaultLocationHistoryRepository implements LocationHistoryRepository {
  DefaultLocationHistoryRepository({
    required LocationUpdatesRepository locationUpdatesRepository,
  }) : _locationUpdatesRepository = locationUpdatesRepository {
    _controller = StreamController<List<LatLngSample>>.broadcast();
  }

  final LocationUpdatesRepository _locationUpdatesRepository;
  late final StreamController<List<LatLngSample>> _controller;
  StreamSubscription<LatLngSample>? _subscription;
  final List<LatLngSample> _samples = <LatLngSample>[];
  final Set<_SampleKey> _sampleKeys = <_SampleKey>{};

  @override
  Stream<List<LatLngSample>> get historyStream => _controller.stream;

  @override
  List<LatLngSample> get currentSamples =>
      List<LatLngSample>.unmodifiable(_samples);

  @override
  Future<void> start() async {
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
    }

    return added;
  }

  void _handleSample(LatLngSample sample) {
    if (_addSample(sample)) {
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
