import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../models/location_update.dart';

/// Defines the IO contract for foreground-only location updates.
abstract class ForegroundLocationService {
  Stream<LocationUpdate> get locationUpdates;

  Future<void> startLocationUpdates({
    double? distanceFilter,
  });

  Future<void> stopLocationUpdates();
}

/// Adapter over geolocator to allow mocking in unit tests.
abstract class GeolocatorClient {
  Stream<Position> getPositionStream({
    required LocationSettings locationSettings,
  });
}

/// Production geolocator client that fetches position updates.
class GeolocatorClientImpl implements GeolocatorClient {
  @override
  Stream<Position> getPositionStream({
    required LocationSettings locationSettings,
  }) {
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}

/// Foreground-only location service backed by geolocator streams.
class GeolocatorForegroundLocationService implements ForegroundLocationService {
  GeolocatorForegroundLocationService({required GeolocatorClient client})
      : _client = client;

  final GeolocatorClient _client;
  final StreamController<LocationUpdate> _controller =
      StreamController<LocationUpdate>.broadcast();
  StreamSubscription<Position>? _subscription;

  @override
  Stream<LocationUpdate> get locationUpdates => _controller.stream;

  @override
  Future<void> startLocationUpdates({
    double? distanceFilter,
  }) async {
    if (_subscription != null) {
      return;
    }

    final settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: (distanceFilter ?? 0).round(),
    );

    _subscription = _client.getPositionStream(locationSettings: settings).listen(
      (position) {
        _controller.add(_mapPosition(position));
      },
      onError: _controller.addError,
    );
  }

  @override
  Future<void> stopLocationUpdates() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  LocationUpdate _mapPosition(Position position) {
    return LocationUpdate(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      bearing: position.heading,
      speed: position.speed,
      timestamp: position.timestamp ?? DateTime.now(),
      isMock: position.isMocked,
    );
  }
}
