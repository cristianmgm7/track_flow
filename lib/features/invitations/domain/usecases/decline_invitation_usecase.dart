import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/invitations/domain/entities/project_invitation.dart';
import 'package:trackflow/features/invitations/domain/entities/invitation_id.dart';
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:trackflow/core/notifications/domain/services/notification_service.dart';

/// Use case to decline a project invitation
@lazySingleton
class DeclineInvitationUseCase {
  final InvitationRepository _invitationRepository;
  final ProjectsRepository _projectRepository;
  final UserProfileRepository _userProfileRepository;
  final NotificationService _notificationService;

  DeclineInvitationUseCase({
    required InvitationRepository invitationRepository,
    required ProjectsRepository projectRepository,
    required UserProfileRepository userProfileRepository,
    required NotificationService notificationService,
  }) : _invitationRepository = invitationRepository,
       _projectRepository = projectRepository,
       _userProfileRepository = userProfileRepository,
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
    // This would typically query notifications by invitation ID and mark them as read
    // For now, we'll implement this as a TODO until the notification repository has the method
    // TODO: Implement when NotificationRepository has markNotificationsByInvitationId method
    print(
      'Marking notifications as read for invitation: ${invitationId.value}',
    );
  }

  /// Notify project owner about decline using core notification service
  Future<void> _notifyProjectOwnerAboutDecline(
    ProjectInvitation invitation,
  ) async {
    // Get project details
    final projectResult = await _projectRepository.getProjectById(
      invitation.projectId,
    );

    projectResult.fold(
      (failure) => print('Failed to get project for notification: $failure'),
      (project) async {
        // Get declined user profile (if it exists)
        String declinedUserName = invitation.invitedEmail;
        if (invitation.invitedUserId != null) {
          final userProfileResult = await _userProfileRepository.getUserProfile(
            invitation.invitedUserId!,
          );

          userProfileResult.fold(
            (failure) => print('Failed to get user profile: $failure'),
            (profile) {
              if (profile != null) {
                declinedUserName = profile.name;
              }
            },
          );
        }

        // Create notification for project owner using core notification service
        await _notificationService.createProjectUpdateNotification(
          recipientId: invitation.invitedByUserId,
          projectId: invitation.projectId.value,
          projectName: project.name.value.getOrElse(() => 'Project'),
          updateMessage: 'Invitation to $declinedUserName was declined',
        );
      },
    );
  }
}
