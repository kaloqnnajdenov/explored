import 'dart:convert';

import 'package:latlong2/latlong.dart';

import '../../../../domain/entities/entity_type.dart';
import '../../../../domain/shared/geo_bounds.dart';
import '../models/parsed_entity_row.dart';
import 'ndjson_reader.dart';

class EntityPackParser {
  const EntityPackParser();

  List<ParsedEntityRow> parse(String raw, {required String countrySlug}) {
    return parseRows(raw, countrySlug: countrySlug).toList(growable: false);
  }

  Iterable<ParsedEntityRow> parseRows(
    String raw, {
    required String countrySlug,
  }) sync* {
    for (final row in iterateNdjsonLines(raw)) {
      yield _parseRow(row, countrySlug);
    }
  }

  ParsedEntityRow _parseRow(Map<String, dynamic> row, String countrySlug) {
    final entityId = row['entity_id'] as String?;
    if (entityId == null || entityId.isEmpty) {
      throw const FormatException('Entity row is missing entity_id');
    }

    final typeRaw = (row['entity_type'] ?? row['type']) as String?;
    if (typeRaw == null || typeRaw.isEmpty) {
      throw FormatException('Entity $entityId is missing type');
    }

    final bbox = row['bbox'] as List<dynamic>?;
    final centroid = row['centroid'] as List<dynamic>?;
    final geometry = row['geometry'];
    if (bbox == null || centroid == null || geometry == null) {
      throw FormatException('Entity $entityId is missing geometry fields');
    }

    return ParsedEntityRow(
      entityId: entityId,
      type: EntityType.fromRaw(typeRaw),
      name: (row['name'] as String?) ?? '',
      osmType: row['osm_type'] as String?,
      osmId: (row['osm_id'] as num?)?.toInt(),
      areaId: row['area_id']?.toString(),
      adminLevel: (row['admin_level'] as num?)?.toInt(),
      bbox: GeoBounds.fromList(bbox),
      centroid: LatLng(
        (centroid[1] as num).toDouble(),
        (centroid[0] as num).toDouble(),
      ),
      countryId: (row['country_id'] ?? row['parent_country_id']) as String?,
      regionId: (row['region_id'] ?? row['parent_region_id']) as String?,
      cityId: (row['city_id'] ?? row['parent_city_id']) as String?,
      geometryGeoJson: jsonEncode(geometry),
      countrySlug: (row['country_slug'] as String?) ?? countrySlug,
      packVersion: row['pack_version'] as String?,
    );
  }
}
