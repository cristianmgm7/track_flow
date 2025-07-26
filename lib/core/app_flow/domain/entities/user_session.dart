import 'package:equatable/equatable.dart';
import 'package:trackflow/core/app_flow/domain/entities/session_state.dart';
import 'package:trackflow/features/auth/domain/entities/user.dart';

/// Represents the current user session state
///
/// This entity is responsible ONLY for user session information.
/// It does NOT contain any sync-related data or logic.
class UserSession extends Equatable {
  final User? currentUser;
  final bool isOnboardingCompleted;
  final bool isProfileComplete;
  final SessionState state;
  final String? errorMessage;

  const UserSession({
    required this.state,
    this.currentUser,
    this.isOnboardingCompleted = false,
    this.isProfileComplete = false,
    this.errorMessage,
  });

  /// Factory for unauthenticated state
  const UserSession.unauthenticated()
    : state = SessionState.unauthenticated,
      currentUser = null,
      isOnboardingCompleted = false,
      isProfileComplete = false,
      errorMessage = null;

  /// Factory for authenticated session (may need setup completion)
  const UserSession.authenticated({
    required User user,
    bool onboardingComplete = false,
    bool profileComplete = false,
  }) : state = SessionState.authenticated,
       currentUser = user,
       isOnboardingCompleted = onboardingComplete,
       isProfileComplete = profileComplete,
       errorMessage = null;

  /// Factory for ready state (fully authenticated and set up)
  const UserSession.ready({required User user})
    : state = SessionState.ready,
      currentUser = user,
      isOnboardingCompleted = true,
      isProfileComplete = true,
      errorMessage = null;

  /// Factory for error state
  const UserSession.error({required String error, User? user})
    : state = SessionState.error,
      currentUser = user,
      isOnboardingCompleted = false,
      isProfileComplete = false,
      errorMessage = error;

  /// Copy with method for state mutations
  UserSession copyWith({
    SessionState? state,
    User? currentUser,
    bool? isOnboardingCompleted,
    bool? isProfileComplete,
    String? errorMessage,
  }) {
    return UserSession(
      state: state ?? this.state,
      currentUser: currentUser ?? this.currentUser,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Helper getters for common checks
  bool get isAuthenticated => currentUser != null;
  bool get needsOnboarding => isAuthenticated && !isOnboardingCompleted;
  bool get needsProfileSetup =>
      isAuthenticated && isOnboardingCompleted && !isProfileComplete;
  bool get isReady => state == SessionState.ready;
  bool get hasError => state == SessionState.error;

  @override
  List<Object?> get props => [
    state,
    currentUser,
    isOnboardingCompleted,
    isProfileComplete,
    errorMessage,
  ];
}
