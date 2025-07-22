import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/session_manager/presentation/bloc/app_flow_events.dart';
import 'package:trackflow/core/session_manager/presentation/bloc/app_flow_state.dart';
import 'package:trackflow/core/session_manager/services/app_session_service.dart';
import 'package:trackflow/core/session_manager/domain/entities/app_session.dart';
import 'package:trackflow/core/sync/background_sync_coordinator.dart';

@injectable
class AppFlowBloc extends Bloc<AppFlowEvent, AppFlowState> {
  final AppSessionService _sessionService;
  final BackgroundSyncCoordinator _backgroundSyncCoordinator;

  StreamSubscription<AppSession>? _sessionSubscription;
  bool _isCheckingFlow = false; // Prevent multiple simultaneous checks

  AppFlowBloc({
    required AppSessionService sessionService,
    required BackgroundSyncCoordinator backgroundSyncCoordinator,
  })  : _sessionService = sessionService,
        _backgroundSyncCoordinator = backgroundSyncCoordinator,
        super(AppFlowLoading()) {
    on<CheckAppFlow>(_onCheckAppFlow);
    on<SignOutRequested>(_onSignOutRequested); // New event for logout
  }

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    return super.close();
  }

  Future<void> _onCheckAppFlow(
    CheckAppFlow event,
    Emitter<AppFlowState> emit,
  ) async {
    // Prevent multiple simultaneous checks
    if (_isCheckingFlow) {
      return;
    }

    _isCheckingFlow = true;
    emit(AppFlowLoading());

    try {
      // Initialize session using the service
      final sessionResult = await _sessionService.initializeSession();

      await sessionResult.fold(
        (failure) async {
          emit(
            AppFlowError('Failed to initialize session: ${failure.message}'),
          );
        },
        (session) async {
          // Map session state to app flow state
          final flowState = _mapSessionToFlowState(session);

          // CHANGE: Always emit ready state immediately for navigation
          emit(flowState);

          // If user needs sync, trigger background sync (non-blocking)
          if (session.status == SessionStatus.ready &&
              !session.isSyncComplete) {
            _backgroundSyncCoordinator.triggerBackgroundSync(
              syncKey: 'app_initialization',
            );
          }
        },
      );
    } catch (e) {
      emit(AppFlowError('Unexpected error: $e'));
    } finally {
      _isCheckingFlow = false;
    }
  }

  /// Maps AppSession state to AppFlowState (simplified)
  AppFlowState _mapSessionToFlowState(AppSession session) {
    switch (session.status) {
      case SessionStatus.loading:
        return AppFlowLoading(progress: session.syncProgress);
      case SessionStatus.unauthenticated:
        return AppFlowUnauthenticated();
      case SessionStatus.authenticated:
        return AppFlowAuthenticated(
          needsOnboarding: !session.isOnboardingCompleted,
          needsProfileSetup: session.isOnboardingCompleted && !session.isProfileComplete,
        );
      case SessionStatus.ready:
        return AppFlowReady();
      case SessionStatus.error:
        return AppFlowError(session.errorMessage ?? 'Unknown error');
    }
  }

  // Removed _handleDataSync - now using BackgroundSyncCoordinator for non-blocking sync

  /// Handle user sign out requests
  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AppFlowState> emit,
  ) async {
    emit(AppFlowLoading());

    final result = await _sessionService.signOut();
    result.fold(
      (failure) {
        emit(AppFlowError('Sign out failed: ${failure.message}'));
      },
      (session) {
        emit(AppFlowUnauthenticated());
      },
    );
  }
}
