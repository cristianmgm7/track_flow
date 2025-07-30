import 'flavor_config.dart';

class EnvironmentConfig {
  static String get apiBaseUrl {
    switch (FlavorConfig.currentFlavor) {
      case Flavor.development:
        return 'https://api-dev.trackflow.app';
      case Flavor.staging:
        return 'https://api-staging.trackflow.app';
      case Flavor.production:
        return 'https://api.trackflow.app';
    }
  }
  
  static String get webAppUrl {
    switch (FlavorConfig.currentFlavor) {
      case Flavor.development:
        return 'https://dev.trackflow.app';
      case Flavor.staging:
        return 'https://staging.trackflow.app';
      case Flavor.production:
        return 'https://trackflow.app';
    }
  }
  
  static String get dynamicLinkDomain {
    switch (FlavorConfig.currentFlavor) {
      case Flavor.development:
        return 'trackflowdev.page.link';
      case Flavor.staging:
        return 'trackflowstaging.page.link';
      case Flavor.production:
        return 'trackflow.page.link';
    }
  }
  
  static bool get enableLogging {
    switch (FlavorConfig.currentFlavor) {
      case Flavor.development:
        return true;
      case Flavor.staging:
        return true;
      case Flavor.production:
        return false;
    }
  }
  
  static bool get enableCrashlytics {
    switch (FlavorConfig.currentFlavor) {
      case Flavor.development:
        return false;
      case Flavor.staging:
        return true;
      case Flavor.production:
        return true;
    }
  }
  
  static String get packageSuffix {
    switch (FlavorConfig.currentFlavor) {
      case Flavor.development:
        return '.dev';
      case Flavor.staging:
        return '.staging';
      case Flavor.production:
        return '';
    }
  }
}