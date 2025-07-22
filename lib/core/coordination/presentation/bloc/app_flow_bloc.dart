import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/coordination/presentation/bloc/app_flow_events.dart';
import 'package:trackflow/core/coordination/presentation/bloc/app_flow_state.dart';
import 'package:trackflow/core/coordination/services/app_session_service.dart';
import 'package:trackflow/core/coordination/domain/entities/app_session.dart';

@injectable
class AppFlowBloc extends Bloc<AppFlowEvent, AppFlowState> {
  final AppSessionService _sessionService;

  StreamSubscription<AppSession>? _sessionSubscription;
  bool _isCheckingFlow = false; // Prevent multiple simultaneous checks

  AppFlowBloc({
    required AppSessionService sessionService,
  }) : _sessionService = sessionService,
       super(AppFlowInitial()) {
    on<CheckAppFlow>(_onCheckAppFlow);
    on<UserAuthenticated>(_onUserAuthenticated);
    on<UserSignedOut>(_onUserSignedOut);
    on<SignOutRequested>(_onSignOutRequested); // New event for logout
  }

  @override
  Future<void> close() {
    print('🔄 [AppFlowBloc] close() called');
    _sessionSubscription?.cancel();
    return super.close();
  }

  Future<void> _onUserAuthenticated(
    UserAuthenticated event,
    Emitter<AppFlowState> emit,
  ) async {
    print('🔄 [AppFlowBloc] _onUserAuthenticated() called');
    add(CheckAppFlow());
  }

  Future<void> _onCheckAppFlow(
    CheckAppFlow event,
    Emitter<AppFlowState> emit,
  ) async {
    // Prevent multiple simultaneous checks
    if (_isCheckingFlow) {
      print('🔄 [AppFlowBloc] CheckAppFlow already in progress, skipping');
      return;
    }

    _isCheckingFlow = true;
    print('🔄 [AppFlowBloc] _onCheckAppFlow() started');
    emit(AppFlowLoading());
    print('🔄 [AppFlowBloc] Emitted AppFlowLoading');

    try {
      // Initialize session using the service
      print('🔄 [AppFlowBloc] Calling session service to initialize');
      final sessionResult = await _sessionService.initializeSession();

      await sessionResult.fold(
        (failure) async {
          print('❌ [AppFlowBloc] Session initialization failed: ${failure.message}');
          emit(AppFlowError('Failed to initialize session: ${failure.message}'));
        },
        (session) async {
          print('🔄 [AppFlowBloc] Session initialized: ${session.status}');
          
          // Map session state to app flow state
          final flowState = _mapSessionToFlowState(session);
          
          // If user needs sync, start sync process
          if (session.status == SessionStatus.ready && !session.isSyncComplete) {
            print('🔄 [AppFlowBloc] Starting data sync process');
            await _handleDataSync(session, emit);
          } else {
            print('🔄 [AppFlowBloc] Emitting flow state: ${flowState.runtimeType}');
            emit(flowState);
          }
        },
      );
    } catch (e) {
      print('❌ [AppFlowBloc] Unexpected error: $e');
      emit(AppFlowError('Unexpected error: $e'));
    } finally {
      _isCheckingFlow = false;
    }
  }

  /// Maps AppSession state to AppFlowState
  AppFlowState _mapSessionToFlowState(AppSession session) {
    switch (session.status) {
      case SessionStatus.initial:
        return AppFlowInitial();
      case SessionStatus.loading:
        return AppFlowLoading();
      case SessionStatus.unauthenticated:
        return AppFlowUnauthenticated();
      case SessionStatus.authenticatedIncomplete:
        if (!session.isOnboardingCompleted) {
          return AppFlowNeedsOnboarding();
        } else if (!session.isProfileComplete) {
          return AppFlowNeedsProfileSetup();
        }
        // Fallback - should not happen
        return AppFlowReady();
      case SessionStatus.syncing:
        return AppFlowSyncing(session.syncProgress);
      case SessionStatus.ready:
        return AppFlowReady();
      case SessionStatus.error:
        return AppFlowError(session.errorMessage ?? 'Unknown error');
    }
  }

  /// Handles data synchronization with progress updates
  Future<void> _handleDataSync(AppSession session, Emitter<AppFlowState> emit) async {
    try {
      print('🔄 [AppFlowBloc] Setting up sync stream');
      
      // Cancel any existing subscription
      await _sessionSubscription?.cancel();
      
      // Listen to sync progress
      _sessionSubscription = _sessionService.initializeDataSync(session).listen(
        (updatedSession) {
          print('🔄 [AppFlowBloc] Sync progress: ${(updatedSession.syncProgress * 100).toInt()}%');
          final flowState = _mapSessionToFlowState(updatedSession);
          emit(flowState);
        },
        onError: (error) {
          print('❌ [AppFlowBloc] Sync error: $error');
          emit(AppFlowError('Data sync failed: $error'));
        },
        onDone: () {
          print('🔄 [AppFlowBloc] Sync completed');
        },
      );
    } catch (e) {
      print('❌ [AppFlowBloc] Sync setup error: $e');
      emit(AppFlowError('Failed to setup data sync: $e'));
    }
  }

  /// Handle user sign out requests
  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AppFlowState> emit,
  ) async {
    print('🔄 [AppFlowBloc] _onSignOutRequested() called');
    emit(AppFlowLoading());
    
    final result = await _sessionService.signOut();
    result.fold(
      (failure) {
        print('❌ [AppFlowBloc] Sign out failed: ${failure.message}');
        emit(AppFlowError('Sign out failed: ${failure.message}'));
      },
      (session) {
        print('🔄 [AppFlowBloc] Sign out successful');
        emit(AppFlowUnauthenticated());
      },
    );
  }

  Future<void> _onUserSignedOut(
    UserSignedOut event,
    Emitter<AppFlowState> emit,
  ) async {
    print('🔄 [AppFlowBloc] _onUserSignedOut() called');
    // This is triggered by external logout (e.g., from auth screens)
    // Just emit unauthenticated state
    emit(AppFlowUnauthenticated());
    print('🔄 [AppFlowBloc] Emitted AppFlowUnauthenticated after external sign out');
  }
}
