import 'package:intl/intl.dart';

enum LogLevel { info, debug, warning, error, none }

class Logger {
  static LogLevel logLevel = LogLevel.info;

  static final Map<LogLevel, String> logLevelPrefix = {
    LogLevel.info: '[I]',
    LogLevel.debug: '[D]',
    LogLevel.warning: '[W]',
    LogLevel.error: '[E]',
  };

  static final Map<LogLevel, int> logLevelPriority = {
    LogLevel.info: 1,
    LogLevel.debug: 2,
    LogLevel.warning: 3,
    LogLevel.error: 4,
    LogLevel.none: 5,
  };

  static void log(LogLevel level, String className, String message) {
    if (logLevelPriority[level]! >= logLevelPriority[logLevel]!) {
      DateTime time = DateTime.now();
      String? prefix = logLevelPrefix[level];
      print('${_formatTime(time)} $prefix CLIMB SCALE - $className : $message');
    }
  }

  static String _formatTime(DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }

  static void i(String className, String message) {
    log(LogLevel.info, className, message);
  }

  static void d(String className, String message) {
    log(LogLevel.debug, className, message);
  }

  static void w(String className, String message) {
    log(LogLevel.warning, className, message);
  }

  static void e(
    String className,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    log(LogLevel.error, className, "$message\n$stackTrace\n$error");
  }
}
