import 'package:firebase_core/firebase_core.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/services/dynamic_link_service.dart';
import 'package:trackflow/core/services/database_health_monitor.dart';
import 'package:trackflow/core/services/performance_metrics_collector.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/session/domain/services/session_service.dart';
import 'package:trackflow/core/session/domain/entities/session_state.dart';

/// Simple app bootstrap that replaces complex initialization coordination
///
/// This service provides direct, fast initialization without the complexity
/// of multiple coordination layers. It follows the pattern used by successful
/// apps like Notion, Linear, and Figma.
@injectable
class AppBootstrap {
  final SessionService _sessionService;
  final PerformanceMetricsCollector _performanceCollector;

  AppBootstrap({
    required SessionService sessionService,
    required PerformanceMetricsCollector performanceCollector,
  }) : _sessionService = sessionService,
       _performanceCollector = performanceCollector;

  /// Initialize the app with minimal, essential services only
  ///
  /// This method performs only the critical initialization steps:
  /// 1. Firebase + DI setup
  /// 2. Simple auth check
  /// 3. Returns initial state immediately
  ///
  /// Sync and other non-critical operations are deferred to background.
  Future<AppInitialState> initialize() async {
    try {
      _performanceCollector.startAppInitialization();
      AppLogger.info(
        'Starting simplified app initialization',
        tag: 'APP_BOOTSTRAP',
      );

      // Phase 1: Essential Firebase and DI initialization
      await _performanceCollector.timeOperation('firebase_init', () async {
        AppLogger.info('Initializing Firebase...', tag: 'APP_BOOTSTRAP');
        await Firebase.initializeApp();
        AppLogger.info(
          'Firebase initialized successfully',
          tag: 'APP_BOOTSTRAP',
        );
      });

      await _performanceCollector.timeOperation(
        'dependency_injection',
        () async {
          AppLogger.info('Configuring dependencies...', tag: 'APP_BOOTSTRAP');
          await configureDependencies();
          AppLogger.info(
            'Dependencies configured successfully',
            tag: 'APP_BOOTSTRAP',
          );
        },
      );

      // Phase 2: Essential services initialization
      await _performanceCollector.timeOperation('essential_services', () async {
        AppLogger.info(
          'Initializing essential services...',
          tag: 'APP_BOOTSTRAP',
        );

        // Initialize dynamic link service
        await DynamicLinkService().init();

        // Quick database health check (non-blocking if possible)
        try {
          final healthMonitor = sl<DatabaseHealthMonitor>();
          final healthResult = await healthMonitor.performStartupHealthCheck();

          if (!healthResult.isHealthy) {
            AppLogger.warning(
              'Database health check failed: ${healthResult.message}',
              tag: 'APP_BOOTSTRAP',
            );
            // Continue anyway - app can work with degraded database
          }
        } catch (e) {
          AppLogger.warning(
            'Database health check failed, continuing: $e',
            tag: 'APP_BOOTSTRAP',
          );
          // Continue anyway - app can work with degraded database
        }

        AppLogger.info('Essential services initialized', tag: 'APP_BOOTSTRAP');
      });

      // Phase 3: Simple auth check (no complex coordination)
      final authState = await _performanceCollector.timeOperation(
        'auth_check',
        () async {
          AppLogger.info(
            'Performing simple auth check...',
            tag: 'APP_BOOTSTRAP',
          );

          final sessionResult = await _sessionService.getCurrentSession();

          return sessionResult.fold(
            (failure) {
              AppLogger.warning(
                'Auth check failed: ${failure.message}',
                tag: 'APP_BOOTSTRAP',
              );
              return AppInitialState.auth;
            },
            (session) {
              AppLogger.info(
                'Auth check completed: ${session.state}',
                tag: 'APP_BOOTSTRAP',
              );

              switch (session.state) {
                case SessionState.unauthenticated:
                  return AppInitialState.auth;
                case SessionState.authenticated:
                  return AppInitialState.setup;
                case SessionState.ready:
                  return AppInitialState.dashboard;
                case SessionState.error:
                  return AppInitialState.error;
              }
            },
          );
        },
      );

      _performanceCollector.completeAppInitialization();

      final duration =
          _performanceCollector.getMetric('app_initialization_total')?.duration;
      AppLogger.info(
        'App bootstrap completed successfully in ${duration?.inMilliseconds ?? 'unknown'}ms',
        tag: 'APP_BOOTSTRAP',
      );

      return authState;
    } catch (error, stackTrace) {
      AppLogger.error(
        'App bootstrap failed: $error',
        tag: 'APP_BOOTSTRAP',
        error: error,
        stackTrace: stackTrace,
      );

      _performanceCollector.completeAppInitialization();
      return AppInitialState.error;
    }
  }

  /// Get initialization performance metrics
  Map<String, dynamic> getInitializationMetrics() {
    return _performanceCollector.getInitializationMetrics().map(
      (key, metric) => MapEntry(key, {
        'duration_ms': metric.duration.inMilliseconds,
        'timestamp': metric.timestamp.toIso8601String(),
        'metadata': metric.metadata,
      }),
    );
  }
}

/// Simple initial states for app navigation
///
/// These states are used directly by the UI without complex mapping
enum AppInitialState {
  /// App is still loading (splash screen)
  splash,

  /// User needs to authenticate
  auth,

  /// User is authenticated but needs setup (onboarding/profile)
  setup,

  /// User is ready to use the app
  dashboard,

  /// App encountered an error during initialization
  error,
}

/// Extension for better debugging
extension AppInitialStateExtension on AppInitialState {
  String get displayName {
    switch (this) {
      case AppInitialState.splash:
        return 'Splash';
      case AppInitialState.auth:
        return 'Authentication';
      case AppInitialState.setup:
        return 'Setup';
      case AppInitialState.dashboard:
        return 'Dashboard';
      case AppInitialState.error:
        return 'Error';
    }
  }
}
