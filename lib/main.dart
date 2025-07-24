import 'package:flutter/material.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trackflow/core/app/my_app.dart';
import 'package:trackflow/core/services/dynamic_link_service.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/app/app_error_widget.dart';
import 'package:trackflow/core/services/database_health_monitor.dart';
import 'package:trackflow/core/services/app_initialization_coordinator.dart';
import 'package:trackflow/core/services/performance_metrics_collector.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Use initialization coordinator to prevent race conditions
    final coordinator = AppInitializationCoordinator();
    final success = await coordinator.ensureInitialized(_performAppInitialization);
    
    if (success) {
      runApp(MyApp());
    } else {
      throw Exception('App initialization failed through coordinator');
    }
    
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

/// Performs the actual app initialization logic
Future<void> _performAppInitialization() async {
  final performanceCollector = PerformanceMetricsCollector();
  performanceCollector.startAppInitialization();
  
  AppLogger.info('Starting TrackFlow initialization', tag: 'MAIN');
  
  // Phase 1: Core Firebase initialization
  await performanceCollector.timeOperation('firebase_init', () async {
    AppLogger.info('Initializing Firebase...', tag: 'MAIN');
    await Firebase.initializeApp();
    AppLogger.info('Firebase initialized successfully', tag: 'MAIN');
  });
  
  // Phase 2: Dependency injection setup
  await performanceCollector.timeOperation('dependency_injection', () async {
    AppLogger.info('Configuring dependencies...', tag: 'MAIN');
    await configureDependencies();
    AppLogger.info('Dependencies configured successfully', tag: 'MAIN');
  });
  
  // Phase 3: Dynamic link service initialization
  await performanceCollector.timeOperation('dynamic_links_init', () async {
    AppLogger.info('Initializing dynamic link service...', tag: 'MAIN');
    await DynamicLinkService().init();
    AppLogger.info('Dynamic link service initialized successfully', tag: 'MAIN');
  });
  
  // Phase 4: Database health check
  await performanceCollector.timeOperation('database_health_check', () async {
    AppLogger.info('Performing database health check...', tag: 'MAIN');
    final healthMonitor = sl<DatabaseHealthMonitor>();
    final healthResult = await healthMonitor.performStartupHealthCheck();
    
    if (!healthResult.isHealthy) {
      throw Exception('Database health check failed: ${healthResult.message}');
    }
    AppLogger.info('Database health check passed', tag: 'MAIN');
  });
  
  performanceCollector.completeAppInitialization();
  AppLogger.info('TrackFlow initialization completed successfully', tag: 'MAIN');
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
