import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/gpx_import/data/services/gpx_parser_service.dart';

void main() {
  test('parses GPX track points with timestamps', () async {
    const gpx = '''
<?xml version="1.0"?>
<gpx version="1.1" creator="test">
  <trk>
    <trkseg>
      <trkpt lat="42.0" lon="23.0">
        <time>2024-01-01T00:00:00Z</time>
      </trkpt>
      <trkpt lat="42.0001" lon="23.0001">
        <time>2024-01-01T00:00:10Z</time>
      </trkpt>
    </trkseg>
  </trk>
</gpx>
''';
    final parser = XmlGpxParserService(useIsolate: false);

    final points = await parser.parse(utf8.encode(gpx));

    expect(points.length, 2);
    expect(points.first.latitude, 42.0);
    expect(points.first.longitude, 23.0);
    expect(points.first.timestamp, DateTime.parse('2024-01-01T00:00:00Z'));
  });
}
