import 'package:equatable/equatable.dart';
import 'package:trackflow/features/auth/domain/entities/user.dart';

/// Represents the current application session state
class AppSession extends Equatable {
  final SessionStatus status;
  final User? currentUser;
  final bool isOnboardingCompleted;
  final bool isProfileComplete;
  final bool isSyncComplete;
  final double syncProgress;
  final String? errorMessage;

  const AppSession({
    required this.status,
    this.currentUser,
    this.isOnboardingCompleted = false,
    this.isProfileComplete = false,
    this.isSyncComplete = false,
    this.syncProgress = 0.0,
    this.errorMessage,
  });

  /// Factory for loading state (combines initial, loading, syncing)
  const AppSession.loading({double progress = 0.0})
      : status = SessionStatus.loading,
        currentUser = null,
        isOnboardingCompleted = false,
        isProfileComplete = false,
        isSyncComplete = false,
        syncProgress = progress,
        errorMessage = null;

  /// Factory for unauthenticated state
  const AppSession.unauthenticated()
      : status = SessionStatus.unauthenticated,
        currentUser = null,
        isOnboardingCompleted = false,
        isProfileComplete = false,
        isSyncComplete = false,
        syncProgress = 0.0,
        errorMessage = null;

  /// Factory for authenticated session (may need setup completion)
  const AppSession.authenticated({
    required User user,
    bool onboardingComplete = false,
    bool profileComplete = false,
    this.syncProgress = 0.0,
  }) : status = SessionStatus.authenticated,
        currentUser = user,
        isOnboardingCompleted = onboardingComplete,
        isProfileComplete = profileComplete,
        isSyncComplete = false,
        errorMessage = null;

  /// Factory for ready state
  const AppSession.ready({
    required User user,
  }) : status = SessionStatus.ready,
        currentUser = user,
        isOnboardingCompleted = true,
        isProfileComplete = true,
        isSyncComplete = true,
        syncProgress = 1.0,
        errorMessage = null;

  /// Factory for error state
  const AppSession.error({
    required String error,
    User? user,
  }) : status = SessionStatus.error,
        currentUser = user,
        isOnboardingCompleted = false,
        isProfileComplete = false,
        isSyncComplete = false,
        syncProgress = 0.0,
        errorMessage = error;

  /// Copy with method for state mutations
  AppSession copyWith({
    SessionStatus? status,
    User? currentUser,
    bool? isOnboardingCompleted,
    bool? isProfileComplete,
    bool? isSyncComplete,
    double? syncProgress,
    String? errorMessage,
  }) {
    return AppSession(
      status: status ?? this.status,
      currentUser: currentUser ?? this.currentUser,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      isSyncComplete: isSyncComplete ?? this.isSyncComplete,
      syncProgress: syncProgress ?? this.syncProgress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Helper getters for common checks
  bool get isAuthenticated => currentUser != null;
  bool get needsOnboarding => isAuthenticated && !isOnboardingCompleted;
  bool get needsProfileSetup => isAuthenticated && isOnboardingCompleted && !isProfileComplete;
  bool get isLoading => status == SessionStatus.loading;
  bool get isReady => status == SessionStatus.ready;
  bool get hasError => status == SessionStatus.error;

  @override
  List<Object?> get props => [
        status,
        currentUser,
        isOnboardingCompleted,
        isProfileComplete,
        isSyncComplete,
        syncProgress,
        errorMessage,
      ];
}

enum SessionStatus {
  loading,
  unauthenticated,
  authenticated,
  ready,
  error,
}