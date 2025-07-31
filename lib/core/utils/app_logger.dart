import '../../config/environment_config.dart';

/// Smart logging abstraction for the app with flavor-aware configuration
///
/// This provides a consistent logging interface that automatically:
/// - Shows logs in Development and Staging environments
/// - Disables logs in Production for security and performance
/// - Can be easily extended with crash reporting services
class AppLogger {
  // Use environment-specific logging configuration
  static bool get _shouldLog => EnvironmentConfig.enableLogging;
  
  // For critical errors that need reporting even in production
  static bool get _shouldReportCrashes => EnvironmentConfig.enableCrashlytics;

  /// Log debug information (only when logging is enabled)
  static void debug(String message, {String? tag}) {
    if (_shouldLog) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      print('🐛 DEBUG: $tagPrefix$message');
    }
  }

  /// Log general information
  static void info(String message, {String? tag}) {
    if (_shouldLog) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      print('ℹ️ INFO: $tagPrefix$message');
    }
  }

  /// Log warnings
  static void warning(String message, {String? tag}) {
    if (_shouldLog) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      print('⚠️ WARNING: $tagPrefix$message');
    }
  }

  /// Log errors
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Show error logs only in development/staging
    if (_shouldLog) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      print('🚨 ERROR: $tagPrefix$message');
      if (error != null) {
        print('   Exception: $error');
      }
      if (stackTrace != null) {
        print('   StackTrace: $stackTrace');
      }
    }

    // In production, send to crash reporting service (no console logs)
    if (_shouldReportCrashes && error != null) {
      // TODO: Implement when Firebase Crashlytics is set up
      // FirebaseCrashlytics.instance.recordError(error, stackTrace, context: message);
    }
  }

  /// Log critical errors that need immediate attention
  static void critical(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Show critical logs only in development/staging (not production console)
    if (_shouldLog) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      print('💀 CRITICAL: $tagPrefix$message');
      if (error != null) {
        print('   Exception: $error');
      }
      if (stackTrace != null) {
        print('   StackTrace: $stackTrace');
      }
    }

    // ALWAYS report critical errors to monitoring (even in production)
    if (_shouldReportCrashes) {
      // TODO: Implement when Firebase Crashlytics is set up
      // FirebaseCrashlytics.instance.recordError(error, stackTrace, 
      //   context: 'CRITICAL: $message', isFatal: true);
    }
  }

  /// Log sync operations with emojis for easy visual parsing
  static void sync(
    String phase,
    String message, {
    String? syncKey,
    int? duration,
  }) {
    if (_shouldLog) {
      final keyInfo = syncKey != null ? ' [$syncKey]' : '';
      final durationInfo = duration != null ? ' (${duration}ms)' : '';
      print('🔄 SYNC$keyInfo: $phase - $message$durationInfo');
    }
  }

  /// Log network operations
  static void network(String message, {String? url, int? statusCode}) {
    if (_shouldLog) {
      final urlInfo = url != null ? ' [$url]' : '';
      final statusInfo = statusCode != null ? ' (HTTP $statusCode)' : '';
      print('🌐 NETWORK$urlInfo: $message$statusInfo');
    }
  }

  /// Log database operations
  static void database(String message, {String? table, int? count}) {
    if (_shouldLog) {
      final tableInfo = table != null ? ' [$table]' : '';
      final countInfo = count != null ? ' ($count items)' : '';
      print('💾 DATABASE$tableInfo: $message$countInfo');
    }
  }

  /// Log structured data for better debugging
  static void structured(
    String message, {
    String? tag,
    Map<String, dynamic>? data,
  }) {
    if (_shouldLog) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      print('📊 STRUCTURED: $tagPrefix$message');
      if (data != null) {
        data.forEach((key, value) {
          print('   $key: $value');
        });
      }
    }
  }

  /// Log performance metrics
  static void performance(
    String operation, {
    String? tag,
    int? durationMs,
    Map<String, dynamic>? metadata,
  }) {
    if (_shouldLog) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      final durationInfo = durationMs != null ? ' (${durationMs}ms)' : '';
      print('⚡ PERFORMANCE$durationInfo: $tagPrefix$operation');
      if (metadata != null) {
        metadata.forEach((key, value) {
          print('   $key: $value');
        });
      }
    }
  }
}
