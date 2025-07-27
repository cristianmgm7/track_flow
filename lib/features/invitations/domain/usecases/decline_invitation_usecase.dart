import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/invitations/domain/entities/project_invitation.dart';
import 'package:trackflow/features/invitations/domain/entities/invitation_id.dart';
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart';
import 'package:trackflow/core/notifications/domain/services/notification_service.dart';

/// Use case to decline a project invitation
@lazySingleton
class DeclineInvitationUseCase {
  final InvitationRepository _invitationRepository;
  final NotificationService _notificationService;

  DeclineInvitationUseCase({
    required InvitationRepository invitationRepository,
    required NotificationService notificationService,
  }) : _invitationRepository = invitationRepository,
       _notificationService = notificationService;

  /// Decline an invitation
  /// Returns the updated invitation
  Future<Either<Failure, ProjectInvitation>> call(
    InvitationId invitationId,
  ) async {
    try {
      // 1. Get the invitation
      final invitationResult = await _invitationRepository.getInvitationById(
        invitationId,
      );

      return invitationResult.fold((failure) => Left(failure), (
        invitation,
      ) async {
        if (invitation == null) {
          return Left(ServerFailure('Invitation not found'));
        }

        // 2. Validate invitation can be declined
        if (!invitation.canBeAccepted) {
          return Left(ServerFailure('Invitation cannot be declined'));
        }

        // 3. Decline the invitation
        final declineResult = await _invitationRepository.declineInvitation(
          invitationId,
        );

        return declineResult.fold((failure) => Left(failure), (
          declinedInvitation,
        ) async {
          // 4. Mark related notifications as read
          await _markInvitationNotificationsAsRead(invitationId);

          // 5. Create notification for project owner about decline
          await _notifyProjectOwnerAboutDecline(declinedInvitation);

          return Right(declinedInvitation);
        });
      });
    } catch (e) {
      return Left(ServerFailure('Failed to decline invitation: $e'));
    }
  }

  /// Mark invitation notifications as read
  Future<void> _markInvitationNotificationsAsRead(
    InvitationId invitationId,
  ) async {
    // This would typically query notifications by invitation ID
    // For now, we'll implement this in the notification repository
    // TODO: Implement notification marking as read
  }

  /// Notify project owner about decline using core notification service
  Future<void> _notifyProjectOwnerAboutDecline(
    ProjectInvitation invitation,
  ) async {
    // TODO: Get project details when ProjectRepository is available
    // TODO: Get declined user profile when UserProfileRepository is available

    // For now, we'll create a simple notification using core notification service
    // await _notificationService.createProjectUpdateNotification(
    //   recipientId: invitation.invitedByUserId,
    //   projectId: invitation.projectId.value,
    //   projectName: 'Project', // TODO: Get actual project name
    //   updateMessage: 'Invitation to ${invitation.invitedEmail} was declined',
    // );
  }
}
