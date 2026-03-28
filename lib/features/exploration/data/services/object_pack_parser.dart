import 'dart:convert';

import '../../../../domain/objects/object_category.dart';
import '../models/parsed_object_row.dart';
import 'ndjson_reader.dart';

class ObjectPackParser {
  const ObjectPackParser();

  List<ParsedObjectRow> parse(String raw, {required String countrySlug}) {
    return parseRows(raw, countrySlug: countrySlug).toList(growable: false);
  }

  Iterable<ParsedObjectRow> parseRows(
    String raw, {
    required String countrySlug,
  }) sync* {
    for (final row in iterateNdjsonLines(raw)) {
      yield _parseRow(row, countrySlug);
    }
  }

  ParsedObjectRow _parseRow(Map<String, dynamic> row, String countrySlug) {
    final objectId = row['object_id'] as String?;
    if (objectId == null || objectId.isEmpty) {
      throw const FormatException('Object row is missing object_id');
    }
    final categoryRaw = row['category'] as String?;
    if (categoryRaw == null || categoryRaw.isEmpty) {
      throw FormatException('Object $objectId is missing category');
    }

    final category = ObjectCategory.fromRaw(categoryRaw);
    final metricType = row['metric_type'] as String?;
    final lengthM =
        (row['length_m'] as num?)?.toDouble() ??
        (metricType == 'length_m'
            ? (row['metric_value'] as num?)?.toDouble()
            : null);
    if (category == ObjectCategory.roadSegment && lengthM == null) {
      throw FormatException('Road object $objectId is missing length_m');
    }

    return ParsedObjectRow(
      objectId: objectId,
      category: category,
      subtype: row['subtype'] as String?,
      name: row['name'] as String?,
      geometryGeoJson: jsonEncode(row['geometry']),
      countryId: row['country_id'] as String?,
      regionId: row['region_id'] as String?,
      cityId: row['city_id'] as String?,
      cityCenterId: row['city_center_id'] as String?,
      drivable: row['drivable'] as bool?,
      walkable: row['walkable'] as bool?,
      cycleway: row['cycleway'] as bool?,
      lengthM: lengthM,
      countrySlug: (row['country_slug'] as String?) ?? countrySlug,
    );
  }
}
