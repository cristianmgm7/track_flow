import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/invitations/domain/entities/invitation_id.dart';
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart';

/// Use case to cancel a sent invitation
@lazySingleton
class CancelInvitationUseCase {
  final InvitationRepository _invitationRepository;

  CancelInvitationUseCase(this._invitationRepository);

  /// Cancel a sent invitation
  /// Returns success or failure
  Future<Either<Failure, Unit>> call(InvitationId invitationId) {
    return _invitationRepository.cancelInvitation(invitationId);
  }
}
