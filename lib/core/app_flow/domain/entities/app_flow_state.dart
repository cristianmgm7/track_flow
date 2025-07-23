import 'package:equatable/equatable.dart';
import 'package:trackflow/core/session/domain/entities/user_session.dart';
import 'package:trackflow/core/sync/domain/entities/sync_state.dart';

/// Represents the application flow state for navigation
///
/// This entity combines session and sync information to determine
/// the appropriate navigation flow. It does NOT contain business logic.
class AppFlowState extends Equatable {
  final UserSession session;
  final SyncState syncState;
  final AppFlowStatus status;
  final String? errorMessage;

  const AppFlowState({
    required this.session,
    required this.syncState,
    required this.status,
    this.errorMessage,
  });

  /// Factory for loading state
  const AppFlowState.loading({UserSession? session, SyncState? syncState})
    : session = session ?? const UserSession.unauthenticated(),
      syncState = syncState ?? SyncState.initial,
      status = AppFlowStatus.loading,
      errorMessage = null;

  /// Factory for unauthenticated state
  const AppFlowState.unauthenticated()
    : session = const UserSession.unauthenticated(),
      syncState = SyncState.initial,
      status = AppFlowStatus.unauthenticated,
      errorMessage = null;

  /// Factory for authenticated state (needs setup)
  const AppFlowState.authenticated({required UserSession session})
    : session = session,
      syncState = SyncState.initial,
      status = AppFlowStatus.authenticated,
      errorMessage = null;

  /// Factory for ready state (fully set up)
  const AppFlowState.ready({required UserSession session, SyncState? syncState})
    : session = session,
      syncState =
          syncState ??
          const SyncState(status: SyncStatus.complete, progress: 1.0),
      status = AppFlowStatus.ready,
      errorMessage = null;

  /// Factory for error state
  const AppFlowState.error({
    required String error,
    UserSession? session,
    SyncState? syncState,
  }) : session = session ?? const UserSession.unauthenticated(),
       syncState = syncState ?? SyncState.initial,
       status = AppFlowStatus.error,
       errorMessage = error;

  /// Copy with method for state mutations
  AppFlowState copyWith({
    UserSession? session,
    SyncState? syncState,
    AppFlowStatus? status,
    String? errorMessage,
  }) {
    return AppFlowState(
      session: session ?? this.session,
      syncState: syncState ?? this.syncState,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Helper getters for navigation decisions
  bool get isLoading => status == AppFlowStatus.loading;
  bool get isUnauthenticated => status == AppFlowStatus.unauthenticated;
  bool get isAuthenticated => status == AppFlowStatus.authenticated;
  bool get isReady => status == AppFlowStatus.ready;
  bool get hasError => status == AppFlowStatus.error;

  /// Navigation-specific helpers
  bool get needsOnboarding => session.needsOnboarding;
  bool get needsProfileSetup => session.needsProfileSetup;
  bool get isSyncing => syncState.isSyncing;
  bool get isSyncComplete => syncState.isComplete;

  @override
  List<Object?> get props => [session, syncState, status, errorMessage];
}

/// Represents the possible application flow states
enum AppFlowStatus {
  /// App is loading or initializing
  loading,

  /// User is not authenticated
  unauthenticated,

  /// User is authenticated but may need setup
  authenticated,

  /// User is fully set up and ready
  ready,

  /// App has encountered an error
  error,
}
