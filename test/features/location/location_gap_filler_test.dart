import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/location/data/models/lat_lng_sample.dart';
import 'package:explored/features/location/data/repositories/location_gap_filler.dart';

const _dt = Duration(seconds: 1);

DateTime _timeAt(
  DateTime base,
  int steps, {
  int extraMicros = 0,
}) {
  return base.add(
    Duration(
      microseconds: _dt.inMicroseconds * steps + extraMicros,
    ),
  );
}

LatLngSample _sample({
  required double latitude,
  required double longitude,
  required DateTime timestamp,
  bool isInterpolated = false,
}) {
  return LatLngSample(
    latitude: latitude,
    longitude: longitude,
    timestamp: timestamp,
    isInterpolated: isInterpolated,
  );
}

List<LatLngSample> _runFiller(
  List<LatLngSample> inputs, {
  Duration interval = _dt,
  double maxSpeedMps = 60,
  double maxDistanceMeters = 15,
}) {
  final filler = LocationGapFiller(
    expectedInterval: interval,
    maxSpeedMps: maxSpeedMps,
    maxDistanceMeters: maxDistanceMeters,
  );
  final outputs = <LatLngSample>[];
  for (final sample in inputs) {
    outputs.addAll(filler.handleSample(sample));
  }
  return outputs;
}

void main() {
  group('LocationGapFiller', () {
    test('No gap (missing_count=0) -> unchanged', () {
      final base = DateTime.utc(2024, 1, 1);
      final start = _sample(
        latitude: 10.0,
        longitude: 20.0,
        timestamp: base,
      );
      final end = _sample(
        latitude: 10.00005,
        longitude: 20.00005,
        timestamp: _timeAt(base, 1),
      );

      final outputs = _runFiller([start, end]);

      expect(outputs.length, 2);
      expect(outputs[0], same(start));
      expect(outputs[1], same(end));
      expect(outputs.every((sample) => !sample.isInterpolated), isTrue);
    });

    test('Insert 1 point (missing_count=1)', () {
      final base = DateTime.utc(2024, 1, 1);
      final start = _sample(
        latitude: 10.00000,
        longitude: 20.00000,
        timestamp: base,
      );
      final end = _sample(
        latitude: 10.00010,
        longitude: 20.00010,
        timestamp: _timeAt(base, 2),
      );

      final outputs = _runFiller([start, end]);

      expect(outputs.length, 3);
      final inserted = outputs[1];
      expect(inserted.isInterpolated, isTrue);
      expect(inserted.timestamp, _timeAt(base, 1));
      expect(inserted.latitude, closeTo(10.00005, 1e-9));
      expect(inserted.longitude, closeTo(20.00005, 1e-9));
    });

    test('Insert 4 points (missing_count=4, boundary allowed)', () {
      final base = DateTime.utc(2024, 1, 1);
      final start = _sample(
        latitude: 0.00000,
        longitude: 0.00000,
        timestamp: base,
      );
      final end = _sample(
        latitude: 0.00010,
        longitude: 0.00020,
        timestamp: _timeAt(base, 5),
      );

      final outputs = _runFiller([start, end]);

      expect(outputs.length, 6);
      final expected = <List<double>>[
        [0.00002, 0.00004],
        [0.00004, 0.00008],
        [0.00006, 0.00012],
        [0.00008, 0.00016],
      ];
      for (var i = 0; i < expected.length; i += 1) {
        final sample = outputs[i + 1];
        expect(sample.isInterpolated, isTrue);
        expect(sample.timestamp, _timeAt(base, i + 1));
        expect(sample.latitude, closeTo(expected[i][0], 1e-9));
        expect(sample.longitude, closeTo(expected[i][1], 1e-9));
      }
      for (var i = 0; i < outputs.length - 1; i += 1) {
        expect(
          outputs[i].timestamp.isBefore(outputs[i + 1].timestamp),
          isTrue,
        );
      }
    });

    test('Gap too large (missing_count=5) -> do not fill', () {
      final base = DateTime.utc(2024, 1, 1);
      final start = _sample(
        latitude: 0.0,
        longitude: 0.0,
        timestamp: base,
      );
      final end = _sample(
        latitude: 0.00010,
        longitude: 0.00020,
        timestamp: _timeAt(base, 6),
      );

      final outputs = _runFiller([start, end]);

      expect(outputs.length, 2);
      expect(outputs.where((sample) => sample.isInterpolated), isEmpty);
    });

    test('Distance gap fills even when time gap is small', () {
      final base = DateTime.utc(2024, 1, 1);
      final start = _sample(
        latitude: 0.0,
        longitude: 0.0,
        timestamp: base,
      );
      final end = _sample(
        latitude: 0.00025,
        longitude: 0.0,
        timestamp: base.add(const Duration(seconds: 5)),
      );

      final outputs = _runFiller(
        [start, end],
        interval: const Duration(seconds: 15),
        maxDistanceMeters: 10,
      );

      expect(outputs.length, 4);
      expect(outputs.first.isInterpolated, isFalse);
      expect(outputs.last.isInterpolated, isFalse);
      expect(outputs[1].isInterpolated, isTrue);
      expect(outputs[2].isInterpolated, isTrue);
      expect(outputs[1].latitude, closeTo(0.00008, 1e-9));
      expect(outputs[2].latitude, closeTo(0.00017, 1e-9));
      expect(
        outputs[1].timestamp,
        base.add(const Duration(microseconds: 1666667)),
      );
      expect(
        outputs[2].timestamp,
        base.add(const Duration(microseconds: 3333333)),
      );
    });

    test('Mixed segments: fill only eligible gaps', () {
      final base = DateTime.utc(2024, 1, 1);
      final samples = <LatLngSample>[
        _sample(latitude: 0.0, longitude: 0.0, timestamp: base),
        _sample(
          latitude: 0.00005,
          longitude: 0.00005,
          timestamp: _timeAt(base, 2),
        ),
        _sample(
          latitude: 0.00010,
          longitude: 0.00010,
          timestamp: _timeAt(base, 3),
        ),
        _sample(
          latitude: 0.00015,
          longitude: 0.00015,
          timestamp: _timeAt(base, 9),
        ),
        _sample(
          latitude: 0.00020,
          longitude: 0.00020,
          timestamp: _timeAt(base, 11),
        ),
      ];

      final outputs = _runFiller(samples);
      final interpolated =
          outputs.where((sample) => sample.isInterpolated).toList();

      expect(outputs.length, 7);
      expect(interpolated.length, 2);
      expect(
        interpolated.map((sample) => sample.timestamp).toSet(),
        {_timeAt(base, 1), _timeAt(base, 10)},
      );
    });

    test('Rounding enforced (5 decimals)', () {
      final base = DateTime.utc(2024, 1, 1);
      final start = _sample(
        latitude: 52.520008,
        longitude: 13.404954,
        timestamp: base,
      );
      final end = _sample(
        latitude: 52.520019,
        longitude: 13.404999,
        timestamp: _timeAt(base, 3),
      );

      final outputs = _runFiller([start, end]);
      final interpolated =
          outputs.where((sample) => sample.isInterpolated).toList();

      expect(interpolated.length, 2);
      for (final sample in interpolated) {
        final latScaled = sample.latitude * 100000;
        final lonScaled = sample.longitude * 100000;
        expect((latScaled - latScaled.round()).abs(), lessThan(1e-6));
        expect((lonScaled - lonScaled.round()).abs(), lessThan(1e-6));
      }
    });

    test('Crossing zero / negative coords', () {
      final base = DateTime.utc(2024, 1, 1);
      final start = _sample(
        latitude: 0.0,
        longitude: -0.00005,
        timestamp: base,
      );
      final end = _sample(
        latitude: 0.0,
        longitude: 0.00005,
        timestamp: _timeAt(base, 2),
      );

      final outputs = _runFiller([start, end]);
      final inserted = outputs[1];

      expect(inserted.isInterpolated, isTrue);
      expect(inserted.longitude, 0.0);
      expect(inserted.longitude.isNegative, isFalse);
    });

    test('Invalid endpoint coordinates -> skip fill', () {
      final base = DateTime.utc(2024, 1, 1);
      final start = _sample(
        latitude: 10.0,
        longitude: 10.0,
        timestamp: base,
      );
      final end = _sample(
        latitude: 95.0,
        longitude: 10.0,
        timestamp: _timeAt(base, 2),
      );

      final outputs = _runFiller([start, end]);

      expect(outputs.length, 2);
      expect(outputs.where((sample) => sample.isInterpolated), isEmpty);
    });

    test('Non-monotonic timestamps / out-of-order', () {
      final base = DateTime.utc(2024, 1, 1);
      final start = _sample(
        latitude: 10.0,
        longitude: 10.0,
        timestamp: _timeAt(base, 2),
      );
      final end = _sample(
        latitude: 10.00010,
        longitude: 10.00010,
        timestamp: _timeAt(base, 1),
      );

      final outputs = _runFiller([start, end]);

      expect(outputs.length, 2);
      expect(outputs.where((sample) => sample.isInterpolated), isEmpty);
    });

    test('Implausible jump (speed threshold) -> do not fill', () {
      final base = DateTime.utc(2024, 1, 1);
      final start = _sample(
        latitude: 0.0,
        longitude: 0.0,
        timestamp: base,
      );
      final end = _sample(
        latitude: 1.0,
        longitude: 1.0,
        timestamp: _timeAt(base, 2),
      );

      final outputs = _runFiller([start, end], maxSpeedMps: 5);

      expect(outputs.length, 2);
      expect(outputs.where((sample) => sample.isInterpolated), isEmpty);
    });

    test('Boundary timing floating-point issues are deterministic', () {
      final base = DateTime.utc(2024, 1, 1);
      final start = _sample(
        latitude: 0.0,
        longitude: 0.0,
        timestamp: base,
      );

      final nearLow = _sample(
        latitude: 0.00010,
        longitude: 0.00010,
        timestamp: _timeAt(base, 5, extraMicros: -1),
      );
      final outputsLow = _runFiller([start, nearLow]);
      expect(outputsLow.where((sample) => sample.isInterpolated).length, 4);

      final nearHigh = _sample(
        latitude: 0.00010,
        longitude: 0.00010,
        timestamp: _timeAt(base, 5, extraMicros: 1),
      );
      final outputsHigh = _runFiller([start, nearHigh]);
      expect(outputsHigh.where((sample) => sample.isInterpolated), isEmpty);
    });

    test('Original points preserved', () {
      final base = DateTime.utc(2024, 1, 1);
      final start = _sample(
        latitude: 12.34567,
        longitude: 23.45678,
        timestamp: base,
      );
      final end = _sample(
        latitude: 12.34582,
        longitude: 23.45693,
        timestamp: _timeAt(base, 2),
      );

      final outputs = _runFiller([start, end]);

      expect(outputs.length, 3);
      expect(outputs.first, same(start));
      expect(outputs.last, same(end));
      expect(outputs.first.isInterpolated, isFalse);
      expect(outputs.last.isInterpolated, isFalse);
      expect(outputs[1].isInterpolated, isTrue);
    });
  });
}
