import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// Coordinates app initialization to prevent race conditions and ensure single initialization
/// 
/// This service ensures that critical app initialization only happens once,
/// even if multiple parts of the app try to initialize simultaneously.
@injectable
class AppInitializationCoordinator {
  static const Duration _initializationTimeout = Duration(seconds: 30);
  
  Completer<bool>? _initializationCompleter;
  bool _isInitialized = false;
  bool _isInitializing = false;
  DateTime? _initializationStartTime;
  
  /// Ensures initialization happens only once, returns true if successful
  Future<bool> ensureInitialized(Future<void> Function() initializationLogic) async {
    // If already initialized, return immediately
    if (_isInitialized) {
      AppLogger.debug('App already initialized', tag: 'INIT_COORDINATOR');
      return true;
    }
    
    // If currently initializing, wait for completion
    if (_isInitializing && _initializationCompleter != null) {
      AppLogger.debug('Waiting for ongoing initialization...', tag: 'INIT_COORDINATOR');
      
      try {
        return await _initializationCompleter!.future
            .timeout(_initializationTimeout);
      } catch (error) {
        AppLogger.error(
          'Timeout or error waiting for initialization',
          tag: 'INIT_COORDINATOR',
          error: error,
        );
        return false;
      }
    }
    
    // Start initialization
    _isInitializing = true;
    _initializationStartTime = DateTime.now();
    _initializationCompleter = Completer<bool>();
    
    AppLogger.info('Starting coordinated app initialization', tag: 'INIT_COORDINATOR');
    
    try {
      await initializationLogic();
      
      _isInitialized = true;
      _isInitializing = false;
      
      final duration = DateTime.now().difference(_initializationStartTime!).inMilliseconds;
      AppLogger.info(
        'App initialization completed successfully in ${duration}ms',
        tag: 'INIT_COORDINATOR',
      );
      
      _initializationCompleter!.complete(true);
      return true;
      
    } catch (error, stackTrace) {
      _isInitializing = false;
      
      final duration = DateTime.now().difference(_initializationStartTime!).inMilliseconds;
      AppLogger.error(
        'App initialization failed after ${duration}ms',
        tag: 'INIT_COORDINATOR',
        error: error,
        stackTrace: stackTrace,
      );
      
      _initializationCompleter!.complete(false);
      return false;
    }
  }
  
  /// Resets initialization state (useful for testing or recovery)
  void reset() {
    AppLogger.warning('Resetting initialization state', tag: 'INIT_COORDINATOR');
    _isInitialized = false;
    _isInitializing = false;
    _initializationCompleter = null;
    _initializationStartTime = null;
  }
  
  /// Gets current initialization status
  AppInitializationStatus get status {
    if (_isInitialized) {
      return AppInitializationStatus.completed;
    } else if (_isInitializing) {
      return AppInitializationStatus.inProgress;
    } else {
      return AppInitializationStatus.notStarted;
    }
  }
  
  /// Gets initialization statistics
  Map<String, dynamic> getInitializationStats() {
    return {
      'isInitialized': _isInitialized,
      'isInitializing': _isInitializing,
      'status': status.name,
      'startTime': _initializationStartTime?.toIso8601String(),
      'duration': _initializationStartTime != null 
          ? DateTime.now().difference(_initializationStartTime!).inMilliseconds
          : null,
    };
  }
}

enum AppInitializationStatus {
  notStarted,
  inProgress,
  completed,
}