import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/app/my_app.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/app/screens/app_error_screen.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Phase 1: Initialize Firebase FIRST
    AppLogger.info('Initializing Firebase...', tag: 'MAIN');
    await Firebase.initializeApp();
    AppLogger.info('Firebase initialized successfully', tag: 'MAIN');

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
    title: 'TrackFlow - Recovery Mode',
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
