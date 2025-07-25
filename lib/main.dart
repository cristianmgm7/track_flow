import 'package:flutter/material.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/app/my_app.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/app/app_error_widget.dart';
import 'package:trackflow/core/app_flow/services/app_bootstrap.dart';
import 'package:trackflow/core/services/performance_metrics_collector.dart';
import 'package:trackflow/core/session/domain/services/session_service.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Use simplified AppBootstrap for fast initialization
    final bootstrap = AppBootstrap(
      sessionService: null, // Will be injected after DI setup
      performanceCollector: PerformanceMetricsCollector(),
    );

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
