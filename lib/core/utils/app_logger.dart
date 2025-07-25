import 'package:flutter/foundation.dart';

/// Simple logging abstraction for the app
///
/// This provides a consistent logging interface that can be easily
/// replaced with a proper logging framework (like logger, firebase_crashlytics, etc.)
/// in the future without changing code throughout the app.
class AppLogger {
  // Use Flutter's built-in debug mode detection
  static bool get _isDebugMode => kDebugMode;

  /// Log debug information (only in debug mode)
  static void debug(String message, {String? tag}) {
    if (_isDebugMode) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      print('🐛 DEBUG: $tagPrefix$message');
    }
  }

  /// Log general information
  static void info(String message, {String? tag}) {
    if (_isDebugMode) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      print('ℹ️ INFO: $tagPrefix$message');
    }
  }

  /// Log warnings
  static void warning(String message, {String? tag}) {
    if (_isDebugMode) {
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
    if (_isDebugMode) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      print('🚨 ERROR: $tagPrefix$message');
      if (error != null) {
        print('   Exception: $error');
      }
      if (stackTrace != null) {
        print('   StackTrace: $stackTrace');
      }
    }

    // TODO: In production, send to crash reporting service
    // FirebaseCrashlytics.instance.recordError(error, stackTrace, context: message);
  }

  /// Log critical errors that need immediate attention
  static void critical(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Always log critical errors, even in release mode
    final tagPrefix = tag != null ? '[$tag] ' : '';
    print('💀 CRITICAL: $tagPrefix$message');
    if (error != null) {
      print('   Exception: $error');
    }
    if (stackTrace != null) {
      print('   StackTrace: $stackTrace');
    }

    // TODO: In production, send to monitoring service immediately
    // ErrorMonitoringService.reportCritical(message, error, stackTrace);
  }

  /// Log sync operations with emojis for easy visual parsing
  static void sync(
    String phase,
    String message, {
    String? syncKey,
    int? duration,
  }) {
    if (_isDebugMode) {
      final keyInfo = syncKey != null ? ' [$syncKey]' : '';
      final durationInfo = duration != null ? ' (${duration}ms)' : '';
      print('🔄 SYNC$keyInfo: $phase - $message$durationInfo');
    }
  }

  /// Log network operations
  static void network(String message, {String? url, int? statusCode}) {
    if (_isDebugMode) {
      final urlInfo = url != null ? ' [$url]' : '';
      final statusInfo = statusCode != null ? ' (HTTP $statusCode)' : '';
      print('🌐 NETWORK$urlInfo: $message$statusInfo');
    }
  }

  /// Log database operations
  static void database(String message, {String? table, int? count}) {
    if (_isDebugMode) {
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
    if (_isDebugMode) {
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
    if (_isDebugMode) {
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
