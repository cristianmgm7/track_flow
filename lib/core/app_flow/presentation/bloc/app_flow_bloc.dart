import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_events.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_state.dart';
import 'package:trackflow/core/app_flow/domain/services/app_flow_coordinator.dart';
import 'package:trackflow/core/app_flow/domain/entities/app_flow_state.dart'
    as coordinator_state;

@injectable
class AppFlowBloc extends Bloc<AppFlowEvent, AppFlowState> {
  final AppFlowCoordinator _coordinator;

  StreamSubscription<coordinator_state.AppFlowState>? _flowSubscription;
  bool _isCheckingFlow = false; // Prevent multiple simultaneous checks

  AppFlowBloc({required AppFlowCoordinator coordinator})
    : _coordinator = coordinator,
      super(AppFlowLoading()) {
    on<CheckAppFlow>(_onCheckAppFlow);
    on<SignOutRequested>(_onSignOutRequested); // New event for logout
  }

  @override
  Future<void> close() {
    _flowSubscription?.cancel();
    return super.close();
  }

  Future<void> _onCheckAppFlow(
    CheckAppFlow event,
    Emitter<AppFlowState> emit,
  ) async {
    if (_isCheckingFlow) return; // Prevent multiple simultaneous checks

    _isCheckingFlow = true;

    try {
      // Emit loading state immediately
      emit(AppFlowLoading());

      // Use the coordinator to determine app flow
      final result = await _coordinator.determineAppFlow();

      await result.fold(
        (failure) async {
          emit(
            AppFlowError('Failed to determine app flow: ${failure.message}'),
          );
        },
        (flowState) async {
          // Map coordinator state to BLoC state
          final blocState = _mapCoordinatorStateToBlocState(flowState);

          // Emit the state immediately for navigation
          emit(blocState);

          // Trigger background sync if user is ready (non-blocking)
          if (flowState.status == coordinator_state.AppFlowStatus.ready) {
            await _coordinator.triggerBackgroundSyncIfReady();
          }
        },
      );
    } catch (e) {
      emit(AppFlowError('Unexpected error during app flow check: $e'));
    } finally {
      _isCheckingFlow = false;
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AppFlowState> emit,
  ) async {
    try {
      emit(AppFlowLoading());
      final result = await _coordinator.signOut();

      result.fold(
        (failure) {
          emit(AppFlowError('Sign out failed: ${failure.message}'));
        },
        (_) {
          emit(AppFlowUnauthenticated());
        },
      );
    } catch (e) {
      emit(AppFlowError('Sign out failed: $e'));
    }
  }

  /// Maps AppFlowCoordinator state to AppFlowBloc state
  AppFlowState _mapCoordinatorStateToBlocState(
    coordinator_state.AppFlowState coordinatorState,
  ) {
    switch (coordinatorState.status) {
      case coordinator_state.AppFlowStatus.loading:
        return AppFlowLoading();
      case coordinator_state.AppFlowStatus.unauthenticated:
        return AppFlowUnauthenticated();
      case coordinator_state.AppFlowStatus.authenticated:
        return AppFlowAuthenticated(
          needsOnboarding: coordinatorState.needsOnboarding,
          needsProfileSetup: coordinatorState.needsProfileSetup,
        );
      case coordinator_state.AppFlowStatus.ready:
        return AppFlowReady();
      case coordinator_state.AppFlowStatus.error:
        return AppFlowError(coordinatorState.errorMessage ?? 'Unknown error');
    }
  }
}
