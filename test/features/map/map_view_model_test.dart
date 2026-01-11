import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/location/data/models/lat_lng_sample.dart';
import 'package:explored/features/location/data/models/location_status.dart';
import 'package:explored/features/location/data/models/location_tracking_mode.dart';
import 'package:explored/features/location/data/repositories/location_updates_repository.dart';
import 'package:explored/features/map/data/models/map_tile_source.dart';
import 'package:explored/features/map/data/repositories/map_repository.dart';
import 'package:explored/features/map/data/services/map_attribution_service.dart';
import 'package:explored/features/map/data/services/map_tile_service.dart';
import 'package:explored/features/map/view_model/map_view_model.dart';

class FakeMapTileService implements MapTileService {
  @override
  MapTileSource getTileSource() {
    return const MapTileSource(
      urlTemplate: 'https://example.com/{z}/{x}/{y}.png',
      subdomains: ['a'],
      userAgentPackageName: 'com.explored.test',
    );
  }
}

class FakeMapAttributionService implements MapAttributionService {
  bool opened = false;

  @override
  Future<void> openAttribution() async {
    opened = true;
  }
}

class FakeLocationUpdatesRepository implements LocationUpdatesRepository {
  final StreamController<LatLngSample> _controller =
      StreamController<LatLngSample>.broadcast();
  bool _isRunning = false;

  @override
  Stream<LatLngSample> get locationUpdates => _controller.stream;

  @override
  bool get isRunning => _isRunning;

  @override
  Future<void> startTracking() async {
    _isRunning = true;
  }

  @override
  Future<void> stopTracking() async {
    _isRunning = false;
  }

  void emit(LatLngSample sample) {
    _controller.add(sample);
  }
}

void main() {
  test('Location updates update the map state', () async {
    final locationRepository = FakeLocationUpdatesRepository();
    final mapRepository = MapRepository(
      tileService: FakeMapTileService(),
      attributionService: FakeMapAttributionService(),
    );
    final viewModel = MapViewModel(
      mapRepository: mapRepository,
      locationUpdatesRepository: locationRepository,
    );

    await viewModel.initialize();

    final sample = LatLngSample(
      latitude: 42.12345,
      longitude: 23.54321,
      timestamp: DateTime(2024, 1, 1),
    );
    locationRepository.emit(sample);
    await Future<void>.delayed(Duration.zero);

    final lastLocation = viewModel.state.locationTracking.lastLocation;
    expect(lastLocation, isNotNull);
    expect(lastLocation!.latitude, 42.12345);
    expect(lastLocation.longitude, 23.54321);
    expect(
      viewModel.state.locationTracking.trackingMode,
      LocationTrackingMode.background,
    );
    expect(
      viewModel.state.locationTracking.status,
      LocationStatus.trackingStartedBackground,
    );

    viewModel.dispose();
  });

  test('Location panel visibility toggles via ViewModel', () {
    final locationRepository = FakeLocationUpdatesRepository();
    final mapRepository = MapRepository(
      tileService: FakeMapTileService(),
      attributionService: FakeMapAttributionService(),
    );
    final viewModel = MapViewModel(
      mapRepository: mapRepository,
      locationUpdatesRepository: locationRepository,
    );

    expect(viewModel.state.isLocationPanelVisible, isTrue);

    viewModel.setLocationPanelVisibility(false);
    expect(viewModel.state.isLocationPanelVisible, isFalse);

    viewModel.toggleLocationPanelVisibility();
    expect(viewModel.state.isLocationPanelVisible, isTrue);

    viewModel.dispose();
  });

  test('Recenter zoom can be updated via ViewModel', () {
    final locationRepository = FakeLocationUpdatesRepository();
    final mapRepository = MapRepository(
      tileService: FakeMapTileService(),
      attributionService: FakeMapAttributionService(),
    );
    final viewModel = MapViewModel(
      mapRepository: mapRepository,
      locationUpdatesRepository: locationRepository,
    );

    final initialZoom = viewModel.state.recenterZoom;
    viewModel.setRecenterZoom(initialZoom + 1);
    expect(viewModel.state.recenterZoom, initialZoom + 1);

    viewModel.dispose();
  });
}
