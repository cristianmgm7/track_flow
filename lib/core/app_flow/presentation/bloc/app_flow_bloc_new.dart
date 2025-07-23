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
    required this.needsOnboarding,
    required this.needsProfileSetup,
  });
}

class AppFlowBlocReady extends AppFlowBlocState {}

class AppFlowBlocError extends AppFlowBlocState {
  final String error;

  AppFlowBlocError({required this.error});
}

/// BLoC that handles application flow orchestration
///
/// This BLoC is responsible ONLY for coordinating the app flow.
/// It does NOT implement business logic or make decisions about navigation.
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
    if (_isCheckingFlow) return; // Prevent multiple simultaneous checks

    _isCheckingFlow = true;
    emit(AppFlowBlocLoading());

    try {
      final result = await _coordinator.determineAppFlow();

      result.fold(
        (failure) {
          emit(AppFlowBlocError(error: failure.message));
        },
        (flowState) {
          emit(_mapToBlocState(flowState));
        },
      );
    } catch (e) {
      emit(AppFlowBlocError(error: 'Failed to check app flow: $e'));
    } finally {
      _isCheckingFlow = false;
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AppFlowBlocState> emit,
  ) async {
    emit(AppFlowBlocLoading());

    try {
      final result = await _coordinator.signOut();

      result.fold(
        (failure) {
          emit(AppFlowBlocError(error: failure.message));
        },
        (_) {
          emit(AppFlowBlocUnauthenticated());
        },
      );
    } catch (e) {
      emit(AppFlowBlocError(error: 'Sign out failed: $e'));
    }
  }

  /// Map AppFlowState to AppFlowBlocState
  ///
  /// This is a pure mapping function with no business logic.
  AppFlowBlocState _mapToBlocState(AppFlowState flowState) {
    switch (flowState.status) {
      case AppFlowStatus.loading:
        return AppFlowBlocLoading();

      case AppFlowStatus.unauthenticated:
        return AppFlowBlocUnauthenticated();

      case AppFlowStatus.authenticated:
        return AppFlowBlocAuthenticated(
          needsOnboarding: !flowState.session.isOnboardingCompleted,
          needsProfileSetup: !flowState.session.isProfileComplete,
        );

      case AppFlowStatus.ready:
        return AppFlowBlocReady();

      case AppFlowStatus.error:
        return AppFlowBlocError(
          error: flowState.errorMessage ?? 'Unknown error',
        );
    }
  }

  /// Trigger background sync if user is ready
  Future<void> triggerBackgroundSyncIfReady() async {
    try {
      await _coordinator.triggerBackgroundSyncIfReady();
    } catch (e) {
      // Handle sync errors silently for now
      print('Background sync failed: $e');
    }
  }
}
