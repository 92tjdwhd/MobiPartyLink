import 'dart:developer' as developer;

class Logger {
  static const String _name = 'MobiPartyLink';
  
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      level: 500, // debug level
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      level: 800, // info level
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      level: 900, // warning level
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      level: 1000, // error level
      error: error,
      stackTrace: stackTrace,
    );
  }
}
