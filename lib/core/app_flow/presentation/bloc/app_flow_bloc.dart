import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_events.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_state.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/app_flow/domain/usecases/get_auth_state_usecase.dart';
import 'package:trackflow/core/app_flow/domain/services/session_cleanup_service.dart';
import 'package:trackflow/core/app_flow/domain/services/session_service.dart';
import 'package:trackflow/core/app_flow/domain/entities/session_state.dart';

@injectable
class AppFlowBloc extends Bloc<AppFlowEvent, AppFlowState> {
  final SessionService _sessionService;
  final GetAuthStateUseCase _getAuthStateUseCase;
  final SessionCleanupService _sessionCleanupService;

  bool _isCheckingFlow = false;
  bool _isSessionCleanupInProgress = false;
  StreamSubscription? _authStateSubscription;

  AppFlowBloc({
    required SessionService sessionService,
    required GetAuthStateUseCase getAuthStateUseCase,
    required SessionCleanupService sessionCleanupService,
  }) : _sessionService = sessionService,
       _getAuthStateUseCase = getAuthStateUseCase,
       _sessionCleanupService = sessionCleanupService,
       super(AppFlowLoading()) {
    on<CheckAppFlow>(_onCheckAppFlow);

    // Listen to auth state changes
    _authStateSubscription = _getAuthStateUseCase().listen((user) {
      AppLogger.info(
        'Auth state changed - user: ${user?.email ?? 'null'}',
        tag: 'APP_FLOW_BLOC',
      );

      // Clear state on logout
      if (user == null && !_isSessionCleanupInProgress) {
        _scheduleDelayedCleanup();
      } else if (user != null) {
        _isSessionCleanupInProgress = false;
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
      return;
    }

    _isCheckingFlow = true;

    try {
      emit(AppFlowLoading());

      AppLogger.info('Starting app flow check', tag: 'APP_FLOW_BLOC');

      // Get current session directly
      final sessionResult = await _sessionService.getCurrentSession();

      final appFlowState = sessionResult.fold(
        (failure) {
          AppLogger.warning(
            'Session check failed: ${failure.message}',
            tag: 'APP_FLOW_BLOC',
          );
          return AppFlowUnauthenticated();
        },
        (session) {
          AppLogger.info(
            'Session state: ${session.state}',
            tag: 'APP_FLOW_BLOC',
          );

          switch (session.state) {
            case SessionState.unauthenticated:
              return AppFlowUnauthenticated();
            case SessionState.authenticated:
              return AppFlowAuthenticated(
                needsOnboarding: session.needsOnboarding,
                needsProfileSetup: session.needsProfileSetup,
              );
            case SessionState.ready:
              return AppFlowReady();
            case SessionState.error:
              return AppFlowError('Session error');
          }
        },
      );

      emit(appFlowState);

      AppLogger.info(
        'App flow check completed: $appFlowState',
        tag: 'APP_FLOW_BLOC',
      );
    } catch (e) {
      AppLogger.error('App flow check failed: $e', tag: 'APP_FLOW_BLOC');
      emit(AppFlowError('Unexpected error during app flow check: $e'));
    } finally {
      _isCheckingFlow = false;
    }
  }

  /// Trigger cleanup immediately
  void _scheduleDelayedCleanup() {
    if (_isSessionCleanupInProgress) {
      return;
    }

    _isSessionCleanupInProgress = true;

    // BLoCs are registered immediately via ResetableBlocMixin constructor
    // No need for delay
    _clearAllUserState();
  }

  /// Clear all user-related state when logging out
  void _clearAllUserState() {
    AppLogger.info(
      'Starting user state cleanup',
      tag: 'APP_FLOW_BLOC',
    );

    try {
      _sessionCleanupService.clearAllUserData().then((result) {
        result.fold(
          (failure) {
            AppLogger.warning(
              'Session cleanup failed: ${failure.message}',
              tag: 'APP_FLOW_BLOC',
            );
          },
          (_) {
            AppLogger.info(
              'Session cleanup completed successfully',
              tag: 'APP_FLOW_BLOC',
            );
          },
        );
      }).whenComplete(() {
        _isSessionCleanupInProgress = false;
      });
    } catch (e) {
      _isSessionCleanupInProgress = false;
      AppLogger.warning(
        'Error during session cleanup: $e',
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
