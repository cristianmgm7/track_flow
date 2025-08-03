import 'package:injectable/injectable.dart';
import 'package:trackflow/core/common/interfaces/resetable.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// Service responsible for resetting BLoC states during session cleanup
/// 
/// This service coordinates the reset of all BLoCs that implement the Resetable
/// interface to prevent state persistence between different user sessions.
/// It works alongside SessionCleanupService to ensure complete session isolation.
@injectable
class BlocStateCleanupService {
  // Registry of all resetable BLoCs
  final List<Resetable> _resetableBloCs = [];

  /// Register a BLoC for state cleanup
  /// 
  /// This method should be called during BLoC initialization to register
  /// BLoCs that need to be reset during session cleanup.
  void registerResetable(Resetable resetable) {
    if (!_resetableBloCs.contains(resetable)) {
      _resetableBloCs.add(resetable);
      AppLogger.info(
        'Registered resetable component: ${resetable.runtimeType}',
        tag: 'BLOC_STATE_CLEANUP',
      );
    }
  }

  /// Unregister a BLoC from state cleanup
  /// 
  /// This method should be called when a BLoC is disposed to prevent
  /// memory leaks and avoid calling reset on disposed BLoCs.
  void unregisterResetable(Resetable resetable) {
    final removed = _resetableBloCs.remove(resetable);
    if (removed) {
      AppLogger.info(
        'Unregistered resetable component: ${resetable.runtimeType}',
        tag: 'BLOC_STATE_CLEANUP',
      );
    }
  }

  /// Reset all registered BLoCs to their initial state
  /// 
  /// This method iterates through all registered resetable components
  /// and calls their reset() method. It handles errors gracefully to
  /// ensure that failure in one BLoC doesn't prevent others from resetting.
  void resetAllBlocStates() {
    AppLogger.info(
      'Starting BLoC state cleanup for ${_resetableBloCs.length} components',
      tag: 'BLOC_STATE_CLEANUP',
    );

    int successCount = 0;
    int errorCount = 0;

    for (final resetable in _resetableBloCs) {
      try {
        resetable.reset();
        successCount++;
        AppLogger.info(
          'Successfully reset: ${resetable.runtimeType}',
          tag: 'BLOC_STATE_CLEANUP',
        );
      } catch (e) {
        errorCount++;
        AppLogger.warning(
          'Failed to reset ${resetable.runtimeType}: $e',
          tag: 'BLOC_STATE_CLEANUP',
        );
      }
    }

    AppLogger.info(
      'BLoC state cleanup completed - Success: $successCount, Errors: $errorCount',
      tag: 'BLOC_STATE_CLEANUP',
    );
  }

  /// Get the number of registered resetable components
  int get registeredCount => _resetableBloCs.length;

  /// Clear all registered components (for testing purposes)
  void clearRegistry() {
    _resetableBloCs.clear();
    AppLogger.info(
      'Cleared BLoC registry',
      tag: 'BLOC_STATE_CLEANUP',
    );
  }
}