import 'package:flutter/foundation.dart';
import 'package:trackflow/core/utils/app_logger.dart';

enum Flavor {
  development,
  staging,
  production,
}

class FlavorConfig {
  static Flavor? _currentFlavor;
  
  static Flavor get currentFlavor {
    return _currentFlavor ?? Flavor.development;
  }
  
  static String get name => currentFlavor.name;
  
  static String get title {
    switch (currentFlavor) {
      case Flavor.development:
        return 'TrackFlow Dev';
      case Flavor.staging:
        return 'TrackFlow Staging';
      case Flavor.production:
        return 'TrackFlow';
    }
  }
  
  static bool get isDevelopment => currentFlavor == Flavor.development;
  static bool get isStaging => currentFlavor == Flavor.staging;
  static bool get isProduction => currentFlavor == Flavor.production;
  
  static bool get isInitialized => _currentFlavor != null;
  
  static void setFlavor(Flavor flavor) {
    _currentFlavor = flavor;
    if (kDebugMode) {
      AppLogger.info('Current Flavor: ${flavor.name}', tag: 'FlavorConfig');
    }
  }

  /// Get bundle identifier for the current flavor
  static String get bundleId {
    switch (currentFlavor) {
      case Flavor.development:
        return 'com.crd.producer-gmail.com.trackflow.dev';
      case Flavor.staging:
        return 'com.crd.producer-gmail.com.trackflow.staging';
      case Flavor.production:
        return 'com.crd.producer-gmail.com.trackflow';
    }
  }

  /// Get Firebase project ID for the current flavor
  static String get firebaseProjectId {
    switch (currentFlavor) {
      case Flavor.development:
        return 'trackflow-dev';
      case Flavor.staging:
        return 'trackflow-staging';
      case Flavor.production:
        return 'trackflow-prod';
    }
  }

  /// Check if analytics should be enabled for current flavor
  static bool get enableAnalytics {
    switch (currentFlavor) {
      case Flavor.development:
        return false; // Disable analytics in development
      case Flavor.staging:
        return true; // Enable analytics in staging for testing
      case Flavor.production:
        return true; // Enable analytics in production
    }
  }

  /// Check if crash reporting should be enabled for current flavor
  static bool get enableCrashReporting {
    switch (currentFlavor) {
      case Flavor.development:
        return false; // Disable crash reporting in development
      case Flavor.staging:
        return true; // Enable crash reporting in staging
      case Flavor.production:
        return true; // Enable crash reporting in production
    }
  }

  /// Get the appropriate log level for the current flavor
  static String get logLevel {
    switch (currentFlavor) {
      case Flavor.development:
        return 'debug'; // Verbose logging in development
      case Flavor.staging:
        return 'info'; // Info level logging in staging
      case Flavor.production:
        return 'warning'; // Warning and error only in production
    }
  }
}