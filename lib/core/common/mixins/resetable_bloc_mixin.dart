import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/common/interfaces/resetable.dart';
import 'package:trackflow/core/app_flow/domain/services/bloc_state_cleanup_service.dart';
import 'package:trackflow/core/di/injection.dart';

/// Mixin that provides automatic registration and cleanup for resetable BLoCs
/// 
/// This mixin simplifies the implementation of the Resetable interface by
/// automatically registering the BLoC with the BlocStateCleanupService on
/// creation and unregistering it on disposal.
/// 
/// Example usage:
/// ```dart
/// class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState>
///     with ResetableBlocMixin<UserProfileEvent, UserProfileState> {
///   
///   UserProfileBloc() : super(UserProfileInitial()) {
///     registerForCleanup(); // Call this in constructor
///   }
/// 
///   @override
///   UserProfileState get initialState => UserProfileInitial();
/// }
/// ```
mixin ResetableBlocMixin<Event, State> on BlocBase<State> implements Resetable {
  bool _isRegistered = false;

  /// Register this BLoC for automatic state cleanup
  /// 
  /// This should be called in the BLoC constructor after super() call.
  void registerForCleanup() {
    if (!_isRegistered) {
      final cleanupService = sl<BlocStateCleanupService>();
      cleanupService.registerResetable(this);
      _isRegistered = true;
    }
  }

  /// The initial state that the BLoC should return to when reset
  /// 
  /// Subclasses must implement this to provide their initial state.
  State get initialState;

  @override
  void reset() {
    emit(initialState);
  }

  @override
  Future<void> close() {
    // Unregister from cleanup service before closing
    if (_isRegistered) {
      try {
        final cleanupService = sl<BlocStateCleanupService>();
        cleanupService.unregisterResetable(this);
      } catch (e) {
        // Service might already be disposed, ignore error
      }
      _isRegistered = false;
    }
    return super.close();
  }
}