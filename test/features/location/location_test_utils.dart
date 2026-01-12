import 'dart:async';
import 'dart:math' as math;

import 'package:explored/features/location/data/services/background_location_client.dart';

class TestClock {
  TestClock(this.now);

  DateTime now;

  void advance(Duration duration) {
    now = now.add(duration);
  }
}

RawLocationData buildRawLocation({
  required double latitude,
  required double longitude,
  DateTime? timestamp,
  double accuracy = 5,
  double speed = 0,
  double bearing = 0,
  double altitude = 0,
  bool isMock = false,
}) {
  return RawLocationData(
    latitude: latitude,
    longitude: longitude,
    altitude: altitude,
    accuracy: accuracy,
    bearing: bearing,
    speed: speed,
    time: (timestamp ?? DateTime.now()).millisecondsSinceEpoch.toDouble(),
    isMock: isMock,
  );
}

double latDeltaForMeters(double meters) {
  const earthRadiusMeters = 6371000.0;
  return (meters / earthRadiusMeters) * (180 / math.pi);
}

double lngDeltaForMeters(double meters, {double atLatitude = 0}) {
  const earthRadiusMeters = 6371000.0;
  final latRad = atLatitude * math.pi / 180;
  final radiusAtLat = earthRadiusMeters * math.cos(latRad);
  if (radiusAtLat == 0) {
    return 0;
  }
  return (meters / radiusAtLat) * (180 / math.pi);
}

Future<List<String>> capturePrints(FutureOr<void> Function() action) async {
  final logs = <String>[];
  await runZoned(
    () async {
      await action();
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, message) {
        logs.add(message);
      },
    ),
  );
  return logs;
}
