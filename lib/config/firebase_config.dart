import 'package:firebase_core/firebase_core.dart';
import 'flavor_config.dart';
import '../firebase_options_development.dart' as dev;
import '../firebase_options_staging.dart' as staging;
import '../firebase_options_production.dart' as prod;

class FirebaseConfig {
  static FirebaseOptions get currentPlatform {
    switch (FlavorConfig.currentFlavor) {
      case Flavor.development:
        return dev.DefaultFirebaseOptions.currentPlatform;
      case Flavor.staging:
        return staging.DefaultFirebaseOptions.currentPlatform;
      case Flavor.production:
        return prod.DefaultFirebaseOptions.currentPlatform;
    }
  }
}