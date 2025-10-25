import 'package:flutter/foundation.dart';
import 'package:trackflow/config/flavor_config.dart';

/// Helper class to manage flavor-specific logos throughout the app
class FlavorLogoHelper {
  static const String _devLogoPath = 'assets/logo/trackflow_dev.png';
  static const String _stagingLogoPath = 'assets/logo/trackflow_staging.png';
  static const String _prodLogoPath = 'assets/logo/trackflow_prod.png';

  /// Get the appropriate logo path based on the current flavor
  ///
  /// Uses FlavorConfig to determine the current flavor
  /// Falls back to debug/release mode if FlavorConfig is not initialized
  static String getLogoPath() {
    // Try to use FlavorConfig first
    try {
      return getLogoPathForFlavor(FlavorConfig.name);
    } catch (e) {
      // Fallback to debug/release mode
      if (kDebugMode) {
        return _devLogoPath;
      } else {
        return _prodLogoPath;
      }
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
  static bool get isDevelopment {
    try {
      return FlavorConfig.isDevelopment;
    } catch (e) {
      return kDebugMode;
    }
  }

  /// Check if the current environment is production
  static bool get isProduction {
    try {
      return FlavorConfig.isProduction;
    } catch (e) {
      return !kDebugMode;
    }
  }

  /// Get current flavor name
  static String get currentFlavor {
    try {
      return FlavorConfig.name;
    } catch (e) {
      if (kDebugMode) {
        return 'development';
      } else {
        return 'production';
      }
    }
  }
}
