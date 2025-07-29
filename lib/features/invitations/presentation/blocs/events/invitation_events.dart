import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/invitations/domain/entities/invitation_id.dart';
import 'package:trackflow/features/invitations/domain/value_objects/send_invitation_params.dart';

// =============================================================================
// WATCHER EVENTS
// =============================================================================

/// Base event for invitation watcher
abstract class InvitationWatcherEvent extends Equatable {
  const InvitationWatcherEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start watching pending invitations
class WatchPendingInvitations extends InvitationWatcherEvent {
  const WatchPendingInvitations();
}

/// Event to start watching sent invitations
class WatchSentInvitations extends InvitationWatcherEvent {
  const WatchSentInvitations();
}

/// Event to start watching invitation count
class WatchInvitationCount extends InvitationWatcherEvent {
  const WatchInvitationCount();
}

/// Event to stop watching invitations
class StopWatchingInvitations extends InvitationWatcherEvent {
  const StopWatchingInvitations();
}

// =============================================================================
// ACTOR EVENTS
// =============================================================================

/// Base event for invitation actor
abstract class InvitationActorEvent extends Equatable {
  const InvitationActorEvent();

  @override
  List<Object?> get props => [];
}

/// Event to send an invitation
class SendInvitation extends InvitationActorEvent {
  final SendInvitationParams params;

  const SendInvitation(this.params);

  @override
  List<Object?> get props => [params];
}

/// Event to accept an invitation
class AcceptInvitation extends InvitationActorEvent {
  final InvitationId invitationId;

  const AcceptInvitation(this.invitationId);

  @override
  List<Object?> get props => [invitationId];
}

/// Event to decline an invitation
class DeclineInvitation extends InvitationActorEvent {
  final InvitationId invitationId;

  const DeclineInvitation(this.invitationId);

  @override
  List<Object?> get props => [invitationId];
}

/// Event to cancel an invitation
class CancelInvitation extends InvitationActorEvent {
  final InvitationId invitationId;

  const CancelInvitation(this.invitationId);

  @override
  List<Object?> get props => [invitationId];
}

/// Event to reset actor state
class ResetInvitationActorState extends InvitationActorEvent {
  const ResetInvitationActorState();
}

/// Event to search for a user by email
class SearchUserByEmail extends InvitationActorEvent {
  final String email;

  const SearchUserByEmail(this.email);

  @override
  List<Object?> get props => [email];
}

/// Event to clear user search results
class ClearUserSearch extends InvitationActorEvent {
  const ClearUserSearch();
}
