import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/app/my_app.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/app/app_error_widget.dart';
import 'package:trackflow/core/app_flow/services/app_bootstrap.dart';

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

    // Phase 3: Now we can safely use AppBootstrap with injected dependencies
    final bootstrap = sl<AppBootstrap>();
    final initialState = await bootstrap.initialize();

    // Log the initialization result for debugging
    AppLogger.info(
      'App initialized with state: ${initialState.displayName}',
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
    home: AppErrorWidget(
      error: error,
      onRetry: () {
        // Restart the app
        main();
      },
    ),
  );
}
