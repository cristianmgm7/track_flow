import 'package:flutter/foundation.dart';

/// Helper class to manage flavor-specific logos throughout the app
class FlavorLogoHelper {
  static const String _devLogoPath = 'assets/logo/trackflow_dev.jpg';
  static const String _stagingLogoPath = 'assets/logo/trackflow_staging.jpg';
  static const String _prodLogoPath = 'assets/logo/trackflow_prod.jpg';

  /// Get the appropriate logo path based on the current flavor
  ///
  /// In debug mode, returns development logo
  /// In release mode, returns production logo
  /// You can customize this logic based on your flavor detection
  static String getLogoPath() {
    // For now, we'll use a simple approach based on debug/release mode
    // You can enhance this to detect specific flavors if needed

    if (kDebugMode) {
      // In debug mode, use development logo
      return _devLogoPath;
    } else {
      // In release mode, use production logo
      return _prodLogoPath;
    }
  }

  /// Get logo path for a specific flavor
  static String getLogoPathForFlavor(String flavor) {
    switch (flavor.toLowerCase()) {
      case 'development':
      case 'dev':
        return _devLogoPath;
      case 'staging':
        return _stagingLogoPath;
      case 'production':
      case 'prod':
        return _prodLogoPath;
      default:
        // Default to production logo
        return _prodLogoPath;
    }
  }

  /// Get the logo path for splash screen
  /// This can be different from the main app logo if needed
  static String getSplashLogoPath() {
    return getLogoPath();
  }

  /// Get splash logo path for a specific flavor
  static String getSplashLogoPathForFlavor(String flavor) {
    return getLogoPathForFlavor(flavor);
  }

  /// Check if the current environment is development
  static bool get isDevelopment => kDebugMode;

  /// Check if the current environment is production
  static bool get isProduction => !kDebugMode;

  /// Get current flavor name
  static String get currentFlavor {
    if (kDebugMode) {
      return 'development';
    } else {
      return 'production';
    }
  }
}
