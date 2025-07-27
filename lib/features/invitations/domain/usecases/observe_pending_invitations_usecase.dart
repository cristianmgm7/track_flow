import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/invitations/domain/entities/project_invitation.dart';
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart';
import 'package:trackflow/core/entities/unique_id.dart';

/// Use case to observe pending invitations for a user
/// Returns a stream of pending invitations
@lazySingleton
class ObservePendingInvitationsUseCase {
  final InvitationRepository _invitationRepository;

  ObservePendingInvitationsUseCase(this._invitationRepository);

  /// Observe pending invitations for a user
  /// Returns a stream of pending invitations
  Stream<Either<Failure, List<ProjectInvitation>>> call(UserId userId) {
    return _invitationRepository.watchPendingInvitations(userId);
  }
}
