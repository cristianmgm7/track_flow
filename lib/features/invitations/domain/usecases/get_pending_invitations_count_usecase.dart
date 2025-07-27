import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart';
import 'package:trackflow/core/entities/unique_id.dart';

/// Use case to get pending invitations count for a user
@lazySingleton
class GetPendingInvitationsCountUseCase {
  final InvitationRepository _invitationRepository;

  GetPendingInvitationsCountUseCase(this._invitationRepository);

  /// Get pending invitations count for a user
  /// Returns the count of pending invitations
  Future<Either<Failure, int>> call(UserId userId) {
    return _invitationRepository.getPendingInvitationsCount(userId);
  }
}
