import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/invitations/domain/entities/project_invitation.dart';
import 'package:trackflow/features/invitations/domain/entities/invitation_id.dart';
import 'package:trackflow/features/invitations/domain/entities/notification_entity.dart';
import 'package:trackflow/features/invitations/domain/entities/notification_id.dart';
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart';
import 'package:trackflow/features/invitations/domain/repositories/notification_repository.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/core/entities/unique_id.dart';

/// Use case to accept a project invitation
/// Handles the acceptance flow and adds user to project
@lazySingleton
class AcceptInvitationUseCase {
  final InvitationRepository _invitationRepository;
  final NotificationRepository _notificationRepository;
  // TODO: Add ProjectRepository when it's created
  // final ProjectRepository _projectRepository;

  AcceptInvitationUseCase({
    required InvitationRepository invitationRepository,
    required NotificationRepository notificationRepository,
    // required ProjectRepository projectRepository,
  }) : _invitationRepository = invitationRepository,
       _notificationRepository = notificationRepository;
  // _projectRepository = projectRepository;

  /// Accept an invitation
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

        // 2. Validate invitation can be accepted
        if (!invitation.canBeAccepted) {
          return Left(ServerFailure('Invitation cannot be accepted'));
        }

        // 3. Accept the invitation
        final acceptResult = await _invitationRepository.acceptInvitation(
          invitationId,
        );

        return acceptResult.fold((failure) => Left(failure), (
          acceptedInvitation,
        ) async {
          // 4. Add user to project (TODO: Implement when ProjectRepository is available)
          // await _addUserToProject(acceptedInvitation);

          // 5. Mark related notifications as read
          await _markInvitationNotificationsAsRead(invitationId);

          // 6. Create notification for project owner
          await _notifyProjectOwner(acceptedInvitation);

          return Right(acceptedInvitation);
        });
      });
    } catch (e) {
      return Left(ServerFailure('Failed to accept invitation: $e'));
    }
  }

  /// Add user to project
  Future<void> _addUserToProject(ProjectInvitation invitation) async {
    // TODO: Implement when ProjectRepository is available
    // Get the project
    // final projectResult = await _projectRepository.getProject(invitation.projectId);

    // projectResult.fold(
    //   (failure) => print('Failed to get project: $failure'),
    //   (project) async {
    //     if (project != null) {
    //       // Add collaborator to project
    //       final updatedProject = project.addCollaborator(
    //         userId: invitation.invitedUserId!,
    //         role: invitation.proposedRole,
    //       );

    //       // Save updated project
    //       await _projectRepository.updateProject(updatedProject);
    //     }
    //   },
    // );
  }

  /// Mark invitation notifications as read
  Future<void> _markInvitationNotificationsAsRead(
    InvitationId invitationId,
  ) async {
    // This would typically query notifications by invitation ID
    // For now, we'll implement this in the notification repository
    // TODO: Implement notification marking as read
  }

  /// Notify project owner about acceptance
  Future<void> _notifyProjectOwner(ProjectInvitation invitation) async {
    // TODO: Get project details when ProjectRepository is available
    // final projectResult = await _projectRepository.getProject(invitation.projectId);

    // projectResult.fold(
    //   (failure) => print('Failed to get project for notification: $failure'),
    //   (project) async {
    //     if (project != null) {
    //       // Get accepted user profile
    //       final acceptedUserProfile = await _getUserProfile(invitation.invitedUserId!);

    //       final acceptedUserName = acceptedUserProfile.fold(
    //         (failure) => 'A user',
    //         (profile) => profile?.name ?? 'A user',
    //       );

    //       // Create notification for project owner
    //       final notification = NotificationEntityFactory.createCollaboratorJoined(
    //         id: NotificationId(),
    //         recipientUserId: invitation.invitedByUserId,
    //         projectId: invitation.projectId.value,
    //         projectName: project.name,
    //         collaboratorName: acceptedUserName,
    //       );

    //       await _notificationRepository.createNotification(notification);
    //     }
    //   },
    // );
  }

  /// Get user profile
  Future<Either<Failure, UserProfile?>> _getUserProfile(UserId userId) async {
    // This would typically use a UserProfileRepository method
    // For now, we'll return a simple result
    return Right(null);
  }
}
