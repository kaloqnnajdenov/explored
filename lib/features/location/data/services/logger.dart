/// Receives structured log events for tracking diagnostics.
abstract class Logger {
  void log(String eventName, Map<String, dynamic> fields);
}
