import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';

import '../models/gpx_point.dart';

abstract class GpxParserService {
  Future<List<GpxPoint>> parse(Uint8List bytes);
}

class XmlGpxParserService implements GpxParserService {
  XmlGpxParserService({this.useIsolate = true});

  final bool useIsolate;

  @override
  Future<List<GpxPoint>> parse(Uint8List bytes) async {
    final payloads = useIsolate
        ? await compute(_parseGpxPointPayloads, bytes)
        : _parseGpxPointPayloads(bytes);
    final results = <GpxPoint>[];
    for (final payload in payloads) {
      final latitude = payload['lat'];
      final longitude = payload['lon'];
      if (latitude is! double || longitude is! double) {
        continue;
      }
      final micros = payload['timeMicros'];
      results.add(
        GpxPoint(
          latitude: latitude,
          longitude: longitude,
          timestamp: micros == null
              ? null
              : DateTime.fromMicrosecondsSinceEpoch(
                  micros as int,
                  isUtc: true,
                ),
        ),
      );
    }
    return results;
  }
}

List<Map<String, Object?>> _parseGpxPointPayloads(Uint8List bytes) {
  final text = utf8.decode(bytes, allowMalformed: true);
  final document = XmlDocument.parse(text);
  final results = <Map<String, Object?>>[];

  for (final element in document.descendants.whereType<XmlElement>()) {
    final name = element.name.local;
    if (name != 'trkpt' && name != 'rtept' && name != 'wpt') {
      continue;
    }

    final latText = element.getAttribute('lat');
    final lonText = element.getAttribute('lon');
    if (latText == null || lonText == null) {
      continue;
    }

    final latitude = double.tryParse(latText);
    final longitude = double.tryParse(lonText);
    if (latitude == null || longitude == null) {
      continue;
    }

    DateTime? timestamp;
    for (final child in element.children.whereType<XmlElement>()) {
      if (child.name.local == 'time') {
        timestamp = DateTime.tryParse(child.innerText.trim());
        break;
      }
    }

    results.add(
      {
        'lat': latitude,
        'lon': longitude,
        'timeMicros': timestamp?.microsecondsSinceEpoch,
      },
    );
  }

  return results;
}
