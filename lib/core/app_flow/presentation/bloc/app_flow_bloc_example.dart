import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/app_flow/data/services/app_flow_coordinator.dart';
import 'package:trackflow/core/app_flow/domain/entities/app_flow_state.dart';

// Events
abstract class AppFlowEvent {}

class CheckAppFlow extends AppFlowEvent {}

class SignOutRequested extends AppFlowEvent {}

// States
abstract class AppFlowBlocState {}

class AppFlowBlocLoading extends AppFlowBlocState {}

class AppFlowBlocUnauthenticated extends AppFlowBlocState {}

class AppFlowBlocAuthenticated extends AppFlowBlocState {
  final bool needsOnboarding;
  final bool needsProfileSetup;

  AppFlowBlocAuthenticated({
    this.needsOnboarding = false,
    this.needsProfileSetup = false,
  });
}

class AppFlowBlocReady extends AppFlowBlocState {}

class AppFlowBlocError extends AppFlowBlocState {
  final String message;
  AppFlowBlocError(this.message);
}

/// Specialized BLoC for application flow orchestration
///
/// This BLoC is responsible ONLY for orchestrating the app flow.
/// It does NOT implement business logic or handle sync/session directly.
@injectable
class AppFlowBloc extends Bloc<AppFlowEvent, AppFlowBlocState> {
  final AppFlowCoordinator _coordinator;
  StreamSubscription<AppFlowState>? _flowSubscription;
  bool _isCheckingFlow = false;

  AppFlowBloc({required AppFlowCoordinator coordinator})
    : _coordinator = coordinator,
      super(AppFlowBlocLoading()) {
    on<CheckAppFlow>(_onCheckAppFlow);
    on<SignOutRequested>(_onSignOutRequested);
  }

  @override
  Future<void> close() {
    _flowSubscription?.cancel();
    return super.close();
  }

  Future<void> _onCheckAppFlow(
    CheckAppFlow event,
    Emitter<AppFlowBlocState> emit,
  ) async {
    if (_isCheckingFlow) return;

    _isCheckingFlow = true;
    emit(AppFlowBlocLoading());

    try {
      final flowResult = await _coordinator.determineAppFlow();

      await flowResult.fold(
        (failure) async {
          emit(
            AppFlowBlocError(
              'Failed to determine app flow: ${failure.message}',
            ),
          );
        },
        (flowState) async {
          // Map to BLoC state and emit immediately
          final blocState = _mapToBlocState(flowState);
          emit(blocState);

          // If user is ready, trigger background sync (non-blocking)
          if (flowState.isReady && !flowState.isSyncComplete) {
            _coordinator.triggerBackgroundSyncIfReady();
          }
        },
      );
    } catch (e) {
      emit(AppFlowBlocError('Unexpected error: $e'));
    } finally {
      _isCheckingFlow = false;
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AppFlowBlocState> emit,
  ) async {
    emit(AppFlowBlocLoading());

    final result = await _coordinator.signOut();
    result.fold(
      (failure) {
        emit(AppFlowBlocError('Sign out failed: ${failure.message}'));
      },
      (_) {
        emit(AppFlowBlocUnauthenticated());
      },
    );
  }

  /// Start watching app flow changes
  void startWatchingFlow() {
    _flowSubscription?.cancel();
    _flowSubscription = _coordinator.watchAppFlow().listen(
      (flowState) {
        final blocState = _mapToBlocState(flowState);
        emit(blocState);
      },
      onError: (error) {
        emit(AppFlowBlocError('Flow watch error: $error'));
      },
    );
  }

  /// Stop watching app flow changes
  void stopWatchingFlow() {
    _flowSubscription?.cancel();
    _flowSubscription = null;
  }

  /// Map AppFlowState to AppFlowBlocState
  ///
  /// This is a pure mapping function with no business logic.
  AppFlowBlocState _mapToBlocState(AppFlowState flowState) {
    if (flowState.isUnauthenticated) {
      return AppFlowBlocUnauthenticated();
    }

    if (flowState.hasError) {
      return AppFlowBlocError(flowState.errorMessage ?? 'Unknown error');
    }

    if (flowState.isAuthenticated) {
      return AppFlowBlocAuthenticated(
        needsOnboarding: flowState.needsOnboarding,
        needsProfileSetup: flowState.needsProfileSetup,
      );
    }

    if (flowState.isReady) {
      return AppFlowBlocReady();
    }

    // Default to loading
    return AppFlowBlocLoading();
  }
}
