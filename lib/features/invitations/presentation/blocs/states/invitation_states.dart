import 'package:equatable/equatable.dart';
import 'package:trackflow/features/invitations/domain/entities/project_invitation.dart';

// =============================================================================
// WATCHER STATES
// =============================================================================

/// Base state for invitation watcher
abstract class InvitationWatcherState extends Equatable {
  const InvitationWatcherState();

  @override
  List<Object?> get props => [];
}

/// Initial state for invitation watcher
class InvitationWatcherInitial extends InvitationWatcherState {
  const InvitationWatcherInitial();
}

/// Loading state for invitation watcher
class InvitationWatcherLoading extends InvitationWatcherState {
  const InvitationWatcherLoading();
}

/// Success state for invitation watcher
class InvitationWatcherSuccess extends InvitationWatcherState {
  final List<ProjectInvitation> invitations;

  const InvitationWatcherSuccess(this.invitations);

  @override
  List<Object?> get props => [invitations];
}

/// Error state for invitation watcher
class InvitationWatcherError extends InvitationWatcherState {
  final String message;

  const InvitationWatcherError(this.message);

  @override
  List<Object?> get props => [message];
}

// =============================================================================
// ACTOR STATES
// =============================================================================

/// Base state for invitation actor
abstract class InvitationActorState extends Equatable {
  const InvitationActorState();

  @override
  List<Object?> get props => [];
}

/// Initial state for invitation actor
class InvitationActorInitial extends InvitationActorState {
  const InvitationActorInitial();
}

/// Loading state for invitation actor
class InvitationActorLoading extends InvitationActorState {
  const InvitationActorLoading();
}

/// Success state for invitation actor
class InvitationActorSuccess extends InvitationActorState {
  final String message;
  final ProjectInvitation? invitation;

  const InvitationActorSuccess({required this.message, this.invitation});

  @override
  List<Object?> get props => [message, invitation];
}

/// Error state for invitation actor
class InvitationActorError extends InvitationActorState {
  final String message;

  const InvitationActorError(this.message);

  @override
  List<Object?> get props => [message];
}

// =============================================================================
// SPECIFIC WATCHER STATES
// =============================================================================

/// State for pending invitations watcher
class PendingInvitationsWatcherState extends InvitationWatcherState {
  final List<ProjectInvitation> pendingInvitations;

  const PendingInvitationsWatcherState(this.pendingInvitations);

  @override
  List<Object?> get props => [pendingInvitations];
}

/// State for sent invitations watcher
class SentInvitationsWatcherState extends InvitationWatcherState {
  final List<ProjectInvitation> sentInvitations;

  const SentInvitationsWatcherState(this.sentInvitations);

  @override
  List<Object?> get props => [sentInvitations];
}

/// State for invitation count watcher
class InvitationCountWatcherState extends InvitationWatcherState {
  final int pendingCount;

  const InvitationCountWatcherState(this.pendingCount);

  @override
  List<Object?> get props => [pendingCount];
}

// =============================================================================
// SPECIFIC ACTOR STATES
// =============================================================================

/// State for send invitation action
class SendInvitationSuccess extends InvitationActorSuccess {
  const SendInvitationSuccess({
    required super.message,
    required ProjectInvitation super.invitation,
  });
}

/// State for accept invitation action
class AcceptInvitationSuccess extends InvitationActorSuccess {
  const AcceptInvitationSuccess({
    required super.message,
    required ProjectInvitation super.invitation,
  });
}

/// State for decline invitation action
class DeclineInvitationSuccess extends InvitationActorSuccess {
  const DeclineInvitationSuccess({
    required super.message,
    required ProjectInvitation super.invitation,
  });
}

/// State for cancel invitation action
class CancelInvitationSuccess extends InvitationActorSuccess {
  const CancelInvitationSuccess({required super.message});
}
