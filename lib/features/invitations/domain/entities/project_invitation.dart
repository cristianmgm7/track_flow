import 'package:trackflow/core/domain/entity.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/features/invitations/domain/entities/invitation_id.dart';

enum InvitationStatus {
  pending, // Invitation sent, waiting for response
  accepted, // User accepted the invitation
  declined, // User declined the invitation
  expired, // Invitation expired
  cancelled, // Invitation cancelled by sender
}

class ProjectInvitation extends Entity<InvitationId> {
  final ProjectId projectId;
  final UserId invitedByUserId; // Who sent the invitation
  final UserId? invitedUserId; // For existing users
  final String invitedEmail; // For new users
  final ProjectRole proposedRole;
  final DateTime createdAt;
  final DateTime expiresAt;
  final InvitationStatus status;
  final String? message; // Optional invitation message

  const ProjectInvitation({
    required InvitationId id,
    required this.projectId,
    required this.invitedByUserId,
    this.invitedUserId,
    required this.invitedEmail,
    required this.proposedRole,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    this.message,
  }) : super(id);

  // Domain methods
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get canBeAccepted => status == InvitationStatus.pending && !isExpired;
  bool get isForExistingUser => invitedUserId != null;
  bool get isForNewUser => invitedUserId == null;

  ProjectInvitation accept() {
    if (!canBeAccepted) {
      throw InvitationCannotBeAcceptedException();
    }
    return copyWith(status: InvitationStatus.accepted);
  }

  ProjectInvitation decline() {
    if (!canBeAccepted) {
      throw InvitationCannotBeAcceptedException();
    }
    return copyWith(status: InvitationStatus.declined);
  }

  ProjectInvitation cancel() {
    if (status != InvitationStatus.pending) {
      throw InvitationCannotBeCancelledException();
    }
    return copyWith(status: InvitationStatus.cancelled);
  }

  ProjectInvitation markAsExpired() {
    return copyWith(status: InvitationStatus.expired);
  }

  ProjectInvitation copyWith({
    InvitationId? id,
    ProjectId? projectId,
    UserId? invitedByUserId,
    UserId? invitedUserId,
    String? invitedEmail,
    ProjectRole? proposedRole,
    DateTime? createdAt,
    DateTime? expiresAt,
    InvitationStatus? status,
    String? message,
  }) {
    return ProjectInvitation(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      invitedByUserId: invitedByUserId ?? this.invitedByUserId,
      invitedUserId: invitedUserId ?? this.invitedUserId,
      invitedEmail: invitedEmail ?? this.invitedEmail,
      proposedRole: proposedRole ?? this.proposedRole,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  List<Object?> get props => [
    id,
    projectId,
    invitedByUserId,
    invitedUserId,
    invitedEmail,
    proposedRole,
    createdAt,
    expiresAt,
    status,
    message,
  ];
}

// Exceptions
class InvitationCannotBeAcceptedException implements Exception {
  const InvitationCannotBeAcceptedException();

  @override
  String toString() =>
      'Invitation cannot be accepted. It may be expired, already processed, or cancelled.';
}

class InvitationCannotBeCancelledException implements Exception {
  const InvitationCannotBeCancelledException();

  @override
  String toString() =>
      'Invitation cannot be cancelled. Only pending invitations can be cancelled.';
}

class InvitationNotFoundException implements Exception {
  const InvitationNotFoundException();

  @override
  String toString() => 'Invitation not found.';
}

class InvitationExpiredException implements Exception {
  const InvitationExpiredException();

  @override
  String toString() => 'Invitation has expired.';
}
