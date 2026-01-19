import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/location/data/models/lat_lng_sample.dart';
import 'package:explored/features/location/data/models/location_permission_level.dart';
import 'package:explored/features/location/data/repositories/location_history_repository.dart';
import 'package:explored/features/location/data/repositories/location_updates_repository.dart';

class FakeLocationUpdatesRepository implements LocationUpdatesRepository {
  final StreamController<LatLngSample> _controller =
      StreamController<LatLngSample>.broadcast();

  @override
  Stream<LatLngSample> get locationUpdates => _controller.stream;

  @override
  bool get isRunning => false;

  @override
  Future<void> startTracking() async {}

  @override
  Future<void> stopTracking() async {}

  @override
  Future<void> refreshPermissions() async {}

  @override
  Future<LocationPermissionLevel> checkPermissionLevel() async {
    return LocationPermissionLevel.foreground;
  }

  @override
  Future<LocationPermissionLevel> requestForegroundPermission() async {
    return LocationPermissionLevel.foreground;
  }

  @override
  Future<LocationPermissionLevel> requestBackgroundPermission() async {
    return LocationPermissionLevel.background;
  }

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<bool> isNotificationPermissionGranted() async => true;

  @override
  Future<bool> requestNotificationPermission() async => true;

  @override
  bool get isNotificationPermissionRequired => false;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openNotificationSettings() async => true;

  @override
  bool get requiresBackgroundPermission => false;

  void emit(LatLngSample sample) {
    _controller.add(sample);
  }
}

void main() {
  test('captures live samples and deduplicates by timestamp and coords',
      () async {
    final updatesRepository = FakeLocationUpdatesRepository();
    final historyRepository = DefaultLocationHistoryRepository(
      locationUpdatesRepository: updatesRepository,
    );

    await historyRepository.start();

    final sample = LatLngSample(
      latitude: 42.0,
      longitude: 23.0,
      timestamp: DateTime.utc(2024, 1, 1),
    );
    updatesRepository.emit(sample);
    updatesRepository.emit(sample);

    final history = await historyRepository.historyStream.first;
    expect(history.length, 1);
    expect(history.first.latitude, 42.0);

    await historyRepository.dispose();
  });

  test('addImportedSamples merges and returns only new samples', () async {
    final updatesRepository = FakeLocationUpdatesRepository();
    final historyRepository = DefaultLocationHistoryRepository(
      locationUpdatesRepository: updatesRepository,
    );

    final sampleA = LatLngSample(
      latitude: 42.0,
      longitude: 23.0,
      timestamp: DateTime.utc(2024, 1, 1),
      source: LatLngSampleSource.imported,
    );
    final sampleB = LatLngSample(
      latitude: 42.0001,
      longitude: 23.0001,
      timestamp: DateTime.utc(2024, 1, 2),
      source: LatLngSampleSource.imported,
    );

    final added = await historyRepository.addImportedSamples(
      [sampleA, sampleA, sampleB],
    );

    expect(added.length, 2);
    expect(historyRepository.currentSamples.length, 2);
    await historyRepository.dispose();
  });
}
