import 'package:flutter/foundation.dart';
import 'package:trackflow/core/utils/app_logger.dart';

class DebugLogger {
  /// Log debug information only in debug builds
  static void debug(String message, {String? tag, Object? error}) {
    if (kDebugMode) {
      final errorSuffix = error != null ? ' - Error: $error' : '';
      AppLogger.info('$message$errorSuffix', tag: tag ?? 'DEBUG');
    }
  }

  /// Log verbose information only in debug builds
  static void verbose(String message, {String? tag}) {
    if (kDebugMode) {
      AppLogger.info(message, tag: tag ?? 'VERBOSE');
    }
  }
}
