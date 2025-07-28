import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/invitations/domain/entities/project_invitation.dart';
import 'package:trackflow/features/invitations/domain/entities/invitation_id.dart';
import 'package:trackflow/features/invitations/domain/value_objects/send_invitation_params.dart';

/// Repository responsible for project invitation operations
/// Follows the Actor/Watcher pattern for clean separation of concerns
abstract class InvitationRepository {
  // Actor methods (for actions)

  /// Send an invitation to a user
  Future<Either<Failure, ProjectInvitation>> sendInvitation(
    SendInvitationParams params,
  );

  /// Accept an invitation
  Future<Either<Failure, ProjectInvitation>> acceptInvitation(
    InvitationId invitationId,
  );

  /// Decline an invitation
  Future<Either<Failure, ProjectInvitation>> declineInvitation(
    InvitationId invitationId,
  );

  /// Cancel a sent invitation
  Future<Either<Failure, Unit>> cancelInvitation(InvitationId invitationId);

  // Watcher methods (for observing)

  /// Watch pending invitations for a user
  Stream<Either<Failure, List<ProjectInvitation>>> watchPendingInvitations(
    UserId userId,
  );

  /// Watch sent invitations by a user
  Stream<Either<Failure, List<ProjectInvitation>>> watchSentInvitations(
    UserId userId,
  );

  /// Get a specific invitation by ID
  Future<Either<Failure, ProjectInvitation?>> getInvitationById(
    InvitationId invitationId,
  );

  /// Get pending invitations count for a user
  Future<Either<Failure, int>> getPendingInvitationsCount(UserId userId);
}
