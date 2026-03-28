import 'dart:convert';

Iterable<Map<String, dynamic>> iterateNdjsonLines(String raw) sync* {
  for (final line in const LineSplitter().convert(raw)) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      continue;
    }
    yield Map<String, dynamic>.from(
      jsonDecode(trimmed) as Map<dynamic, dynamic>,
    );
  }
}

List<Map<String, dynamic>> parseNdjsonLines(String raw) {
  return iterateNdjsonLines(raw).toList(growable: false);
}
