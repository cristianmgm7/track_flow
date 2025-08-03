import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/app_flow/domain/value_objects/app_initial_state.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_events.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_state.dart';
import 'package:trackflow/core/app_flow/domain/services/app_bootstrap.dart';
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/app_flow/domain/entities/user_session.dart';
import 'package:trackflow/core/app_flow/domain/usecases/get_auth_state_usecase.dart';
import 'package:trackflow/core/app_flow/domain/services/session_cleanup_service.dart';

@injectable
class AppFlowBloc extends Bloc<AppFlowEvent, AppFlowState> {
  final AppBootstrap _appBootstrap;
  final BackgroundSyncCoordinator _backgroundSyncCoordinator;
  final GetAuthStateUseCase _getAuthStateUseCase;
  final SessionCleanupService _sessionCleanupService;

  bool _isCheckingFlow = false; // Prevent multiple simultaneous checks
  StreamSubscription? _authStateSubscription;

  AppFlowBloc({
    required AppBootstrap appBootstrap,
    required BackgroundSyncCoordinator backgroundSyncCoordinator,
    required GetAuthStateUseCase getAuthStateUseCase,
    required SessionCleanupService sessionCleanupService,
  }) : _appBootstrap = appBootstrap,
       _backgroundSyncCoordinator = backgroundSyncCoordinator,
       _getAuthStateUseCase = getAuthStateUseCase,
       _sessionCleanupService = sessionCleanupService,
       super(AppFlowLoading()) {
    on<CheckAppFlow>(_onCheckAppFlow);

    // Listen to auth state changes via use case
    _authStateSubscription = _getAuthStateUseCase().listen((user) {
      AppLogger.info(
        'AppFlowBloc: Auth state changed - user: ${user?.email ?? 'null'}',
        tag: 'APP_FLOW_BLOC',
      );

      // ✅ CRÍTICO: Si el usuario es null (logout), limpiar estado completo
      if (user == null) {
        AppLogger.info(
          'AppFlowBloc: User is null (logout detected), clearing all state',
          tag: 'APP_FLOW_BLOC',
        );
        _clearAllUserState();
      }

      // Trigger app flow check when auth state changes
      add(CheckAppFlow());
    });
  }

  Future<void> _onCheckAppFlow(
    CheckAppFlow event,
    Emitter<AppFlowState> emit,
  ) async {
    if (_isCheckingFlow) {
      AppLogger.info(
        'App flow check already in progress, skipping...',
        tag: 'APP_FLOW_BLOC',
      );
      return; // Prevent multiple simultaneous checks
    }

    _isCheckingFlow = true;

    try {
      // Emit loading state immediately
      emit(AppFlowLoading());

      AppLogger.info(
        'Starting simplified app flow check',
        tag: 'APP_FLOW_BLOC',
      );

      // Use AppBootstrap for simple, direct initialization
      final bootstrapResult = await _appBootstrap.initialize();

      AppLogger.info(
        'AppBootstrap result: ${bootstrapResult.state.displayName}',
        tag: 'APP_FLOW_BLOC',
      );

      // Map AppInitialState directly to AppFlowState
      final blocState = _mapInitialStateToBlocState(
        bootstrapResult.state,
        userSession: bootstrapResult.userSession,
      );

      AppLogger.info(
        'Mapped to AppFlowState: $blocState',
        tag: 'APP_FLOW_BLOC',
      );

      // Emit the state immediately for navigation
      emit(blocState);

      // Trigger background sync if user is ready (non-blocking)
      if (bootstrapResult.state == AppInitialState.dashboard) {
        _triggerBackgroundSync();
      }

      AppLogger.info(
        'App flow check completed: ${bootstrapResult.state.displayName}',
        tag: 'APP_FLOW_BLOC',
      );
    } catch (e) {
      AppLogger.error('App flow check failed: $e', tag: 'APP_FLOW_BLOC');
      emit(AppFlowError('Unexpected error during app flow check: $e'));
    } finally {
      _isCheckingFlow = false;
    }
  }

  /// Maps AppInitialState directly to AppFlowState (no complex mapping)
  AppFlowState _mapInitialStateToBlocState(
    AppInitialState initialState, {
    UserSession? userSession,
  }) {
    AppLogger.info(
      'Mapping AppInitialState: $initialState, UserSession: ${userSession?.state}',
      tag: 'APP_FLOW_BLOC',
    );

    switch (initialState) {
      case AppInitialState.splash:
        return AppFlowLoading();
      case AppInitialState.auth:
        return AppFlowUnauthenticated();
      case AppInitialState.setup:
        // Use actual onboarding/profile flags from session
        if (userSession != null) {
          AppLogger.info(
            'User session details - needsOnboarding: ${userSession.needsOnboarding}, needsProfileSetup: ${userSession.needsProfileSetup}',
            tag: 'APP_FLOW_BLOC',
          );
          return AppFlowAuthenticated(
            needsOnboarding: userSession.needsOnboarding,
            needsProfileSetup: userSession.needsProfileSetup,
          );
        } else {
          // Fallback for cases where session is not available
          AppLogger.warning(
            'No user session available, using fallback values',
            tag: 'APP_FLOW_BLOC',
          );
          return AppFlowAuthenticated(
            needsOnboarding: true,
            needsProfileSetup: true,
          );
        }
      case AppInitialState.dashboard:
        return AppFlowReady();
      case AppInitialState.error:
        return AppFlowError('App initialization failed');
    }
  }

  /// Trigger background sync without blocking the UI
  void _triggerBackgroundSync() {
    // Fire and forget - NO await
    unawaited(_performBackgroundSync());
  }

  Future<void> _performBackgroundSync() async {
    try {
      AppLogger.info('Starting background sync', tag: 'APP_FLOW_BLOC');

      await _backgroundSyncCoordinator.triggerBackgroundSync(
        syncKey: 'app_startup_sync',
      );

      AppLogger.info('Background sync completed', tag: 'APP_FLOW_BLOC');
    } catch (e) {
      AppLogger.warning('Background sync failed: $e', tag: 'APP_FLOW_BLOC');
      // Don't emit error state - background sync failures shouldn't affect UI
    }
  }

  // Helper method for fire-and-forget background operations
  void unawaited(Future future) {
    future.catchError((error) {
      // Log error but don't propagate - this is background operation
      AppLogger.warning(
        'Background operation failed: $error',
        tag: 'APP_FLOW_BLOC',
      );
    });
  }

  /// Clear all user-related state when logging out
  void _clearAllUserState() {
    AppLogger.info(
      'AppFlowBloc: Starting comprehensive user state cleanup',
      tag: 'APP_FLOW_BLOC',
    );

    // Use comprehensive session cleanup service
    try {
      // ✅ ENHANCED: Use comprehensive cleanup service
      unawaited(_sessionCleanupService.clearAllUserData().then((result) {
        result.fold(
          (failure) {
            AppLogger.warning(
              'AppFlowBloc: Session cleanup failed: ${failure.message}',
              tag: 'APP_FLOW_BLOC',
            );
          },
          (_) {
            AppLogger.info(
              'AppFlowBloc: Comprehensive session cleanup completed successfully',
              tag: 'APP_FLOW_BLOC',
            );
          },
        );
      }));
    } catch (e) {
      AppLogger.warning(
        'AppFlowBloc: Error during session cleanup: $e',
        tag: 'APP_FLOW_BLOC',
      );
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
