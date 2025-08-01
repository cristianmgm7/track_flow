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
  
  static void setFlavor(Flavor flavor) {
    _currentFlavor = flavor;
    if (kDebugMode) {
      AppLogger.info('Current Flavor: ${flavor.name}', tag: 'FlavorConfig');
    }
  }
}