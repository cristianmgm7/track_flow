// ignore_for_file: unused_import, unused_element, invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
/// BLoC State Cleanup Pattern - Practical Examples
library;

///
/// This file contains copy-paste ready examples for implementing
/// the BLoC state cleanup pattern in different scenarios.
///
/// Copy the relevant example and adapt it to your specific BLoC.

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/common/interfaces/resetable.dart';
import 'package:trackflow/core/common/mixins/resetable_bloc_mixin.dart';
import 'package:trackflow/core/app_flow/domain/services/bloc_state_cleanup_service.dart';
import 'package:trackflow/core/di/injection.dart';

// ============================================================================
// EXAMPLE 1: Simple BLoC with Basic State
// ============================================================================

/// Example events
abstract class ExampleEvent {}

class LoadData extends ExampleEvent {}

class ClearData extends ExampleEvent {}

/// Example states
abstract class ExampleState {}

class ExampleInitial extends ExampleState {}

class ExampleLoading extends ExampleState {}

class ExampleLoaded extends ExampleState {
  final String data;
  ExampleLoaded(this.data);
}

class ExampleError extends ExampleState {
  final String message;
  ExampleError(this.message);
}

/// ✅ COPY THIS: Simple BLoC with ResetableBlocMixin
@injectable
class ExampleSimpleBloc extends Bloc<ExampleEvent, ExampleState>
    with ResetableBlocMixin<ExampleEvent, ExampleState> {
  ExampleSimpleBloc() : super(ExampleInitial()) {
    on<LoadData>(_onLoadData);
    on<ClearData>(_onClearData);

    // ✅ REQUIRED: Register for automatic cleanup
    registerForCleanup();
  }

  // ✅ REQUIRED: Define the clean initial state
  @override
  ExampleState get initialState => ExampleInitial();

  Future<void> _onLoadData(LoadData event, Emitter<ExampleState> emit) async {
    emit(ExampleLoading());
    try {
      // Simulate loading data
      await Future.delayed(Duration(seconds: 1));
      emit(ExampleLoaded('User data loaded'));
    } catch (e) {
      emit(ExampleError('Failed to load data'));
    }
  }

  void _onClearData(ClearData event, Emitter<ExampleState> emit) {
    emit(ExampleInitial());
  }
}

// ============================================================================
// EXAMPLE 2: Complex BLoC with Subscriptions and Resources
// ============================================================================

/// ✅ COPY THIS: Complex BLoC with subscription cleanup
@injectable
class ExampleComplexBloc extends Bloc<ExampleEvent, ExampleState>
    with ResetableBlocMixin<ExampleEvent, ExampleState> {
  StreamSubscription<String>? _dataSubscription;
  Timer? _periodicTimer;

  ExampleComplexBloc() : super(ExampleInitial()) {
    on<LoadData>(_onLoadData);

    // ✅ REQUIRED: Register for automatic cleanup
    registerForCleanup();
  }

  // ✅ REQUIRED: Define the clean initial state
  @override
  ExampleState get initialState => ExampleInitial();

  // ✅ OVERRIDE: Custom reset with resource cleanup
  @override
  void reset() {
    // Cancel any ongoing subscriptions
    _dataSubscription?.cancel();
    _dataSubscription = null;

    // Cancel timers
    _periodicTimer?.cancel();
    _periodicTimer = null;

    // Call parent reset to emit initial state
    super.reset();
  }

  Future<void> _onLoadData(LoadData event, Emitter<ExampleState> emit) async {
    emit(ExampleLoading());

    // Example: Listen to data stream
    _dataSubscription = _getDataStream().listen(
      (data) => emit(ExampleLoaded(data)),
      onError: (error) => emit(ExampleError(error.toString())),
    );

    // Example: Start periodic updates
    _periodicTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      // Refresh data periodically
    });
  }

  Stream<String> _getDataStream() {
    // Mock data stream
    return Stream.periodic(Duration(seconds: 1), (count) => 'Data $count');
  }

  @override
  Future<void> close() {
    _dataSubscription?.cancel();
    _periodicTimer?.cancel();
    return super.close();
  }
}

// ============================================================================
// EXAMPLE 3: Cubit with Manual Implementation
// ============================================================================

enum AppTab { home, profile, settings }

/// ✅ COPY THIS: Simple Cubit with manual Resetable implementation
@injectable
class ExampleNavigationCubit extends Cubit<AppTab> implements Resetable {
  ExampleNavigationCubit() : super(AppTab.home) {
    // ✅ REQUIRED: Manual registration
    final cleanupService = sl<BlocStateCleanupService>();
    cleanupService.registerResetable(this);
  }

  void setTab(AppTab tab) => emit(tab);

  // ✅ REQUIRED: Implement reset method
  @override
  void reset() => emit(AppTab.home);

  @override
  Future<void> close() {
    // ✅ REQUIRED: Unregister from cleanup service
    try {
      final cleanupService = sl<BlocStateCleanupService>();
      cleanupService.unregisterResetable(this);
    } catch (e) {
      // Service might be disposed, ignore error
    }
    return super.close();
  }
}

// ============================================================================
// EXAMPLE 4: BLoC with Custom State Object
// ============================================================================

class UserProfileState {
  final String? name;
  final String? email;
  final bool isLoading;
  final String? error;

  const UserProfileState({
    this.name,
    this.email,
    this.isLoading = false,
    this.error,
  });

  // Create clean initial state
  static const initial = UserProfileState();

  UserProfileState copyWith({
    String? name,
    String? email,
    bool? isLoading,
    String? error,
  }) {
    return UserProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

abstract class UserProfileEvent {}

class LoadUserProfile extends UserProfileEvent {}

class UpdateUserProfile extends UserProfileEvent {
  final String name;
  final String email;
  UpdateUserProfile(this.name, this.email);
}

/// ✅ COPY THIS: BLoC with custom state object
@injectable
class ExampleUserProfileBloc extends Bloc<UserProfileEvent, UserProfileState>
    with ResetableBlocMixin<UserProfileEvent, UserProfileState> {
  ExampleUserProfileBloc() : super(UserProfileState.initial) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);

    // ✅ REQUIRED: Register for automatic cleanup
    registerForCleanup();
  }

  // ✅ REQUIRED: Define the clean initial state
  @override
  UserProfileState get initialState => UserProfileState.initial;

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 1));
      emit(
        state.copyWith(
          isLoading: false,
          name: 'John Doe',
          email: 'john@example.com',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Failed to load profile'));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Simulate API call
      await Future.delayed(Duration(milliseconds: 500));
      emit(
        state.copyWith(isLoading: false, name: event.name, email: event.email),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Failed to update profile'));
    }
  }
}

// ============================================================================
// EXAMPLE 5: BLoC with Conditional Reset
// ============================================================================

/// ✅ COPY THIS: BLoC with conditional reset logic
@injectable
class ExampleConditionalBloc extends Bloc<ExampleEvent, ExampleState>
    with ResetableBlocMixin<ExampleEvent, ExampleState> {
  ExampleConditionalBloc() : super(ExampleInitial()) {
    on<LoadData>(_onLoadData);

    // ✅ REQUIRED: Register for automatic cleanup
    registerForCleanup();
  }

  // ✅ REQUIRED: Define the clean initial state
  @override
  ExampleState get initialState => ExampleInitial();

  // ✅ OVERRIDE: Custom reset with conditions
  @override
  void reset() {
    // Only reset if we have user-specific data
    if (state is ExampleLoaded || state is ExampleError) {
      super.reset(); // Emit initial state
    }
    // If already in initial or loading state, no need to reset
  }

  Future<void> _onLoadData(LoadData event, Emitter<ExampleState> emit) async {
    emit(ExampleLoading());
    // Implementation...
  }
}

// ============================================================================
// EXAMPLE 6: Testing Helper
// ============================================================================

/// ✅ COPY THIS: Test helper for BLoC state cleanup
class BlocCleanupTestHelper {
  /// Test if a BLoC properly resets to initial state
  static void testBlocReset<T extends BlocBase<S>, S>(
    T bloc,
    S initialState,
    S nonInitialState,
  ) {
    // Arrange: Put bloc in non-initial state
    if (bloc is Cubit<S>) {
      bloc.emit(nonInitialState);
    }

    // Act: Reset the bloc
    if (bloc is Resetable) {
      (bloc as Resetable).reset();
    }

    // Assert: Verify it's back to initial state
    assert(bloc.state.runtimeType == initialState.runtimeType);
  }

  /// Test if cleanup service properly manages registration
  static void testCleanupServiceRegistration() {
    final service = BlocStateCleanupService();
    final mockResetable = _MockResetable();

    // Test registration
    service.registerResetable(mockResetable);
    assert(service.registeredCount == 1);

    // Test reset
    service.resetAllBlocStates();
    assert(mockResetable.wasReset);

    // Test unregistration
    service.unregisterResetable(mockResetable);
    assert(service.registeredCount == 0);
  }
}

class _MockResetable implements Resetable {
  bool wasReset = false;

  @override
  void reset() {
    wasReset = true;
  }
}

// ============================================================================
// COPY-PASTE TEMPLATES
// ============================================================================

/* 
✅ TEMPLATE 1: Basic BLoC
Copy this template and replace ExampleBloc, ExampleEvent, ExampleState:

@injectable
class YOUR_BLOC_NAME extends Bloc<YOUR_EVENT_TYPE, YOUR_STATE_TYPE>
    with ResetableBlocMixin<YOUR_EVENT_TYPE, YOUR_STATE_TYPE> {
  
  YOUR_BLOC_NAME() : super(YOUR_INITIAL_STATE()) {
    on<YOUR_EVENT>(_onYourEvent);
    
    registerForCleanup();
  }

  @override
  YOUR_STATE_TYPE get initialState => YOUR_INITIAL_STATE();

  Future<void> _onYourEvent(YOUR_EVENT event, Emitter<YOUR_STATE_TYPE> emit) async {
    // Your implementation
  }
}
*/

/*
✅ TEMPLATE 2: Cubit with Manual Implementation
Copy this template and replace ExampleCubit, ExampleState:

@injectable
class YOUR_CUBIT_NAME extends Cubit<YOUR_STATE_TYPE> implements Resetable {
  
  YOUR_CUBIT_NAME() : super(YOUR_INITIAL_STATE()) {
    final cleanupService = sl<BlocStateCleanupService>();
    cleanupService.registerResetable(this);
  }

  @override
  void reset() => emit(YOUR_INITIAL_STATE());

  @override
  Future<void> close() {
    try {
      final cleanupService = sl<BlocStateCleanupService>();
      cleanupService.unregisterResetable(this);
    } catch (e) {
      // Ignore disposal errors
    }
    return super.close();
  }
}
*/
