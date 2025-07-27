import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/invitations/domain/entities/project_invitation.dart';
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart';
import 'package:trackflow/core/entities/unique_id.dart';

/// Use case to observe sent invitations by a user
/// Returns a stream of sent invitations
@lazySingleton
class ObserveSentInvitationsUseCase {
  final InvitationRepository _invitationRepository;

  ObserveSentInvitationsUseCase(this._invitationRepository);

  /// Observe sent invitations by a user
  /// Returns a stream of sent invitations
  Stream<Either<Failure, List<ProjectInvitation>>> call(UserId userId) {
    return _invitationRepository.watchSentInvitations(userId);
  }
}
