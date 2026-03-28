import '../models/parsed_totals_row.dart';
import 'ndjson_reader.dart';

class TotalsPackParser {
  const TotalsPackParser();

  List<ParsedTotalsRow> parse(String raw) {
    return parseRows(raw).toList(growable: false);
  }

  Iterable<ParsedTotalsRow> parseRows(String raw) sync* {
    for (final row in iterateNdjsonLines(raw)) {
      yield _parseRow(row);
    }
  }

  ParsedTotalsRow _parseRow(Map<String, dynamic> row) {
    final entityId = row['entity_id'] as String?;
    if (entityId == null || entityId.isEmpty) {
      throw const FormatException('Totals row is missing entity_id');
    }

    return ParsedTotalsRow(
      entityId: entityId,
      peaksCount: (row['peaks_count'] as num?)?.toInt() ?? 0,
      hutsCount: (row['huts_count'] as num?)?.toInt() ?? 0,
      monumentsCount: (row['monuments_count'] as num?)?.toInt() ?? 0,
      roadsDrivableLengthM:
          (row['roads_drivable_length_m'] as num?)?.toDouble() ?? 0,
      roadsWalkableLengthM:
          (row['roads_walkable_length_m'] as num?)?.toDouble() ?? 0,
      roadsCyclewayLengthM:
          (row['roads_cycleway_length_m'] as num?)?.toDouble() ?? 0,
    );
  }
}
