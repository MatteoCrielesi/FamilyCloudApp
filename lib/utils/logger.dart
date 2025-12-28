import 'package:flutter/foundation.dart';

class Logger {
  const Logger();

  void info(String message) {
    debugPrint(message);
  }

  void warning(String message) {
    debugPrint('WARN: $message');
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    debugPrint('ERROR: $message');
    if (error != null) {
      debugPrint(error.toString());
    }
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}
