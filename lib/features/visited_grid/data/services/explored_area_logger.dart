import 'package:flutter/foundation.dart';

import '../models/explored_area_log_entry.dart';

abstract class ExploredAreaLogger {
  void log(ExploredAreaLogEntry entry);
}

class ConsoleExploredAreaLogger implements ExploredAreaLogger {
  @override
  void log(ExploredAreaLogEntry entry) {
    debugPrint('[explored_area] ${entry.toFields()}');
  }
}
