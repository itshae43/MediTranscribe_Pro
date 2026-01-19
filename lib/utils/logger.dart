import 'package:logger/logger.dart' as log_pkg;

/// Custom Logger
/// Enhanced logging for debugging and monitoring

class AppLogger {
  static final log_pkg.Logger _logger = log_pkg.Logger(
    printer: log_pkg.PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: log_pkg.DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Log debug message
  static void debug(String message, [dynamic data]) {
    _logger.d('$message${data != null ? '\n$data' : ''}');
  }

  /// Log info message
  static void info(String message, [dynamic data]) {
    _logger.i('$message${data != null ? '\n$data' : ''}');
  }

  /// Log warning message
  static void warning(String message, [dynamic data]) {
    _logger.w('$message${data != null ? '\n$data' : ''}');
  }

  /// Log error message
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log fatal error
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log API call
  static void api(String method, String endpoint, {dynamic data, int? statusCode}) {
    final status = statusCode != null ? ' [$statusCode]' : '';
    _logger.i('API $method$status: $endpoint${data != null ? '\n$data' : ''}');
  }

  /// Log user action
  static void action(String action, {Map<String, dynamic>? params}) {
    _logger.i('USER ACTION: $action${params != null ? '\n$params' : ''}');
  }

  /// Log performance metric
  static void performance(String operation, Duration duration) {
    _logger.i('PERF: $operation completed in ${duration.inMilliseconds}ms');
  }

  /// Log navigation
  static void navigation(String route) {
    _logger.i('NAV: Navigating to $route');
  }
}

/// Extension for easy logging from any class
extension LoggerExtension on Object {
  void logDebug(String message) => AppLogger.debug('[$runtimeType] $message');
  void logInfo(String message) => AppLogger.info('[$runtimeType] $message');
  void logWarning(String message) => AppLogger.warning('[$runtimeType] $message');
  void logError(String message, [dynamic error]) => 
      AppLogger.error('[$runtimeType] $message', error);
}
