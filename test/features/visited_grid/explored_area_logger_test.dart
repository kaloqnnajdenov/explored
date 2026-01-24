import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/visited_grid/data/models/explored_area_log_entry.dart';
import 'package:explored/features/visited_grid/data/services/explored_area_logger.dart';

void main() {
  test('ConsoleExploredAreaLogger prints log entry', () {
    final messages = <String>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) {
        messages.add(message);
      }
    };
    addTearDown(() {
      debugPrint = originalDebugPrint;
    });

    final logger = ConsoleExploredAreaLogger();
    logger.log(
      ExploredAreaLogEntry(
        event: 'explored_area_viewed',
        timestamp: DateTime.utc(2025, 1, 1),
        totalAreaM2: 1200,
        totalAreaKm2: 0.0012,
        cellCount: 3,
        canonicalVersion: 4,
        schemaVersion: 3,
        appVersion: '1.0.0',
        deltaAreaM2: 400,
        cellId: 'cell-1',
      ),
    );

    expect(messages, hasLength(1));
    expect(messages.first, contains('explored_area'));
    expect(messages.first, contains('explored_area_viewed'));
  });
}
