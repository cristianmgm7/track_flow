import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_events.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// Handles app initialization logic following Single Responsibility Principle
///
/// This service is responsible for:
/// - Triggering app flow checks
/// - Managing initialization state
/// - Coordinating startup sequence
class AppInitializer {
  final AppFlowBloc _appFlowBloc;
  bool _isInitialized = false;

  AppInitializer({required AppFlowBloc appFlowBloc})
    : _appFlowBloc = appFlowBloc;

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
      // Trigger app flow check - AppFlowBloc handles all verification
      _appFlowBloc.add(CheckAppFlow());

      _isInitialized = true;

      AppLogger.info(
        'App initialization completed successfully',
        tag: 'APP_INITIALIZER',
      );
    } catch (e) {
      AppLogger.error(
        'App initialization failed: $e',
        tag: 'APP_INITIALIZER',
        error: e,
      );
      rethrow;
    }
  }

  /// Check if app is initialized
  bool get isInitialized => _isInitialized;

  /// Reset initialization state (useful for testing)
  void reset() {
    _isInitialized = false;
    AppLogger.info('App initialization state reset', tag: 'APP_INITIALIZER');
  }
}
