import 'package:injectable/injectable.dart';
import 'package:trackflow/core/services/dynamic_link_service.dart';
import 'package:trackflow/core/services/database_health_monitor.dart';
import 'package:trackflow/core/services/performance_metrics_collector.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/app_flow/domain/services/session_service.dart';
import 'package:trackflow/core/app_flow/domain/entities/session_state.dart';
import 'package:trackflow/core/app_flow/domain/entities/user_session.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';

/// Simple app bootstrap that replaces complex initialization coordination
///
/// This service provides direct, fast initialization without the complexity
/// of multiple coordination layers.
@injectable
class AppBootstrap {
  final SessionService _sessionService;
  final PerformanceMetricsCollector _performanceCollector;
  final DynamicLinkService _dynamicLinkService;
  final DatabaseHealthMonitor _databaseHealthMonitor;

  AppBootstrap({
    required SessionService sessionService,
    required PerformanceMetricsCollector performanceCollector,
    required DynamicLinkService dynamicLinkService,
    required DatabaseHealthMonitor databaseHealthMonitor,
  }) : _sessionService = sessionService,
       _performanceCollector = performanceCollector,
       _dynamicLinkService = dynamicLinkService,
       _databaseHealthMonitor = databaseHealthMonitor;

  /// Initialize the app with minimal, essential services only
  ///
  /// This method performs only the critical initialization steps:
  /// 1. Firebase + DI setup (already done in main.dart)
  /// 2. Simple auth check
  /// 3. Returns initial state immediately
  ///
  /// Sync and other non-critical operations are deferred to background.
  Future<AppBootstrapResult> initialize() async {
    try {
      _performanceCollector.startAppInitialization();
      AppLogger.info(
        'Starting simplified app initialization',
        tag: 'APP_BOOTSTRAP',
      );

      // Phase 1: Essential services initialization (DI already configured)
      await _performanceCollector.timeOperation('essential_services', () async {
        AppLogger.info(
          'Initializing essential services...',
          tag: 'APP_BOOTSTRAP',
        );

        // Initialize dynamic link service
        await _dynamicLinkService.init();

        // Quick database health check (non-blocking if possible)
        try {
          final healthResult =
              await _databaseHealthMonitor.performStartupHealthCheck();

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

      // Phase 2: Simple auth check (no complex coordination)
      final authResult = await _performanceCollector.timeOperation(
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
              return AppBootstrapResult(
                state: AppInitialState.auth,
                userSession: null,
              );
            },
            (session) {
              AppLogger.info(
                'Auth check completed: ${session.state}',
                tag: 'APP_BOOTSTRAP',
              );

              switch (session.state) {
                case SessionState.unauthenticated:
                  return AppBootstrapResult(
                    state: AppInitialState.auth,
                    userSession: null,
                  );
                case SessionState.authenticated:
                  return AppBootstrapResult(
                    state: AppInitialState.setup,
                    userSession: session,
                  );
                case SessionState.ready:
                  return AppBootstrapResult(
                    state: AppInitialState.dashboard,
                    userSession: session,
                  );
                case SessionState.error:
                  return AppBootstrapResult(
                    state: AppInitialState.error,
                    userSession: null,
                  );
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

      return authResult;
    } catch (error, stackTrace) {
      AppLogger.error(
        'App bootstrap failed: $error',
        tag: 'APP_BOOTSTRAP',
        error: error,
        stackTrace: stackTrace,
      );

      _performanceCollector.completeAppInitialization();
      return AppBootstrapResult(
        state: AppInitialState.error,
        userSession: null,
      );
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

  /// Sign out the current user
  ///
  /// This method delegates to SessionService for user sign out.
  /// It handles the coordination of sign out operations.
  Future<Either<Failure, Unit>> signOut() async {
    try {
      AppLogger.info(
        'Starting sign out via AppBootstrap',
        tag: 'APP_BOOTSTRAP',
      );

      final result = await _sessionService.signOut();

      result.fold(
        (failure) {
          AppLogger.error(
            'Sign out failed: ${failure.message}',
            tag: 'APP_BOOTSTRAP',
            error: failure,
          );
        },
        (_) {
          AppLogger.info(
            'Sign out completed successfully via AppBootstrap',
            tag: 'APP_BOOTSTRAP',
          );
        },
      );

      return result;
    } catch (e) {
      AppLogger.error(
        'Sign out failed with exception: $e',
        tag: 'APP_BOOTSTRAP',
        error: e,
      );
      return Left(ServerFailure('Sign out failed: $e'));
    }
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

/// Result of app bootstrap containing both state and session info
class AppBootstrapResult {
  final AppInitialState state;
  final UserSession? userSession;

  const AppBootstrapResult({required this.state, this.userSession});
}
