import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Centralized logging service. Logs are suppressed in release builds.
class LoggerService {
  LoggerService._();

  static final LoggerService _instance = LoggerService._();

  /// Singleton accessor.
  static LoggerService get instance => _instance;

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: kReleaseMode ? Level.off : Level.debug,
  );

  /// Logs a debug-level message.
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an info-level message.
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an error-level message.
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
