import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_events.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/utils/image_utils.dart';
import 'package:trackflow/core/services/image_maintenance_service.dart';
import 'package:trackflow/core/app/services/audio_background_initializer.dart';
import 'package:trackflow/core/di/injection.dart';

/// Handles app initialization logic following Single Responsibility Principle
///
/// This service is responsible for:
/// - Triggering app flow checks
/// - Managing initialization state
/// - Coordinating startup sequence
/// - Performing maintenance tasks like image migration
class AppInitializer {
  final AppFlowBloc _appFlowBloc;
  final ImageMaintenanceService _imageMaintenanceService;
  bool _isInitialized = false;

  AppInitializer({
    required AppFlowBloc appFlowBloc,
    ImageMaintenanceService? imageMaintenanceService,
  }) : _appFlowBloc = appFlowBloc,
       _imageMaintenanceService =
           imageMaintenanceService ?? sl<ImageMaintenanceService>();

  /// Initialize the app
  void initialize() {
    if (_isInitialized) {
      AppLogger.warning(
        'App already initialized, skipping...',
        tag: 'APP_INITIALIZER',
      );
      return;
    }

    AppLogger.info('Starting app initialization', tag: 'APP_INITIALIZER');

    try {
      // Initialize audio background/session
      _initializeAudioBackground();

      // Perform maintenance tasks in background
      _performMaintenanceTasks();

      // Start image maintenance service
      _imageMaintenanceService.startPeriodicMaintenance();

      // Trigger app flow check - AppFlowBloc handles all verification
      _appFlowBloc.add(CheckAppFlow());

      _isInitialized = true;

      AppLogger.info(
        'App initialization completed successfully',
        tag: 'APP_INITIALIZER',
      );
    } catch (e) {
      AppLogger.error('App initialization failed: $e', tag: 'APP_INITIALIZER');
      rethrow;
    }
  }

  /// Perform maintenance tasks in background (non-blocking)
  void _performMaintenanceTasks() {
    // Run maintenance tasks in background to avoid blocking app startup
    Future.microtask(() async {
      try {
        AppLogger.info('Starting maintenance tasks', tag: 'APP_INITIALIZER');

        // Migrate existing images to permanent storage
        await ImageUtils.migrateImagesToPermanentStorage();

        // Clean up old temporary images (non-blocking)
        await ImageUtils.cleanupOldImages();

        AppLogger.info('Maintenance tasks completed', tag: 'APP_INITIALIZER');
      } catch (e) {
        AppLogger.warning(
          'Maintenance tasks failed (non-critical): $e',
          tag: 'APP_INITIALIZER',
        );
        // Don't rethrow - maintenance failures shouldn't break app startup
      }
    });
  }

  /// Initialize audio background capabilities (non-blocking)
  void _initializeAudioBackground() {
    Future.microtask(() async {
      try {
        final initializer = sl<AudioBackgroundInitializer>();
        await initializer.initialize();
      } catch (e) {
        AppLogger.warning(
          'Audio background init failed: $e',
          tag: 'APP_INITIALIZER',
        );
      }
    });
  }

  /// Check if app is initialized
  bool get isInitialized => _isInitialized;

  /// Reset initialization state (useful for testing)
  void reset() {
    _isInitialized = false;
    _imageMaintenanceService.stopPeriodicMaintenance();
    AppLogger.info('App initialization state reset', tag: 'APP_INITIALIZER');
  }

  /// Dispose resources
  void dispose() {
    _imageMaintenanceService.dispose();
  }
}
