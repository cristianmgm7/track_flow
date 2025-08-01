import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/app/my_app.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/app/screens/app_error_screen.dart';
import 'package:trackflow/config/flavor_config.dart';
import 'package:trackflow/config/firebase_config.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // ✅ CRITICAL: Set default flavor if not already set (needed for tests)
    if (!FlavorConfig.isInitialized) {
      FlavorConfig.setFlavor(Flavor.development);
      AppLogger.info('🧪 TEST MODE: Default flavor set to development', tag: 'MAIN');
    }

    // Phase 1: Initialize Firebase FIRST (only if not already initialized)
    AppLogger.info('🎯 FLAVOR: ${FlavorConfig.name} - Initializing Firebase...', tag: 'MAIN');
    
    // ✅ Skip Firebase in test environment to prevent connection issues
    const bool isTestMode = bool.fromEnvironment('FLUTTER_TEST', defaultValue: false);
    if (!isTestMode && Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp(options: FirebaseConfig.currentPlatform);
        AppLogger.info('✅ Firebase initialized successfully for ${FlavorConfig.name}', tag: 'MAIN');
      } catch (e) {
        AppLogger.error('❌ Firebase initialization failed: $e', tag: 'MAIN');
        // Continue without Firebase for integration tests
        if (kDebugMode) {
          AppLogger.info('🧪 Continuing in test mode without Firebase', tag: 'MAIN');
        } else {
          rethrow;
        }
      }
    } else if (isTestMode) {
      AppLogger.info('🧪 TEST MODE: Skipping Firebase initialization', tag: 'MAIN');
    } else {
      AppLogger.info('✅ Firebase already initialized for ${FlavorConfig.name}', tag: 'MAIN');
    }

    // Phase 2: Configure dependencies AFTER Firebase
    AppLogger.info('Configuring dependencies...', tag: 'MAIN');
    await configureDependencies();
    AppLogger.info('Dependencies configured successfully', tag: 'MAIN');

    // Phase 3: Let AppFlowBloc handle app state initialization
    AppLogger.info(
      'Starting app - AppFlowBloc will handle state initialization',
      tag: 'MAIN',
    );

    runApp(MyApp());
  } catch (error, stackTrace) {
    AppLogger.critical(
      'Critical initialization failure: TrackFlow cannot start',
      tag: 'MAIN',
      error: error,
      stackTrace: stackTrace,
    );

    // Run error recovery app
    runApp(_buildErrorRecoveryApp(error));
  }
}

Widget _buildErrorRecoveryApp(Object error) {
  return MaterialApp(
    title: '${FlavorConfig.title} - Recovery Mode',
    theme: ThemeData.dark(),
    home: AppErrorScreen(
      error: error,
      onRetry: () {
        // Restart the app
        main();
      },
    ),
  );
}