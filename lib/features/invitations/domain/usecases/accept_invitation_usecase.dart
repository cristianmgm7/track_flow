import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/features/invitations/domain/entities/project_invitation.dart';
import 'package:trackflow/features/invitations/domain/entities/invitation_id.dart';
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project_collaborator.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:trackflow/core/notifications/domain/services/notification_service.dart';

/// Use case to accept a project invitation
/// Handles the acceptance flow and adds user to project
@lazySingleton
class AcceptInvitationUseCase {
  final InvitationRepository _invitationRepository;
  final ProjectsRepository _projectRepository;
  final UserProfileRepository _userProfileRepository;
  final NotificationService _notificationService;

  AcceptInvitationUseCase({
    required InvitationRepository invitationRepository,
    required ProjectsRepository projectRepository,
    required UserProfileRepository userProfileRepository,
    required NotificationService notificationService,
  }) : _invitationRepository = invitationRepository,
       _projectRepository = projectRepository,
       _userProfileRepository = userProfileRepository,
       _notificationService = notificationService;

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
          await _addUserToProject(acceptedInvitation);

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
    // Get the project
    final projectResult = await _projectRepository.getProjectById(
      invitation.projectId,
    );

    projectResult.fold(
      (failure) => AppLogger.error(
        'Failed to get project: $failure',
        tag: 'AcceptInvitationUseCase',
      ),
      (project) async {
        if (invitation.invitedUserId != null) {
          // Create new collaborator with the proposed role
          final newCollaborator = ProjectCollaborator.create(
            userId: invitation.invitedUserId!,
            role: invitation.proposedRole,
          );

          // Add collaborator to project using domain logic
          final updatedProject = project.addCollaborator(newCollaborator);

          // Save updated project
          final saveResult = await _projectRepository.updateProject(
            updatedProject,
          );

          saveResult.fold(
            (failure) => AppLogger.error(
              'Failed to save updated project: $failure',
              tag: 'AcceptInvitationUseCase',
            ),
            (_) => AppLogger.info(
              'Successfully added user to project',
              tag: 'AcceptInvitationUseCase',
            ),
          );
        }
      },
    );
  }

  /// Mark invitation notifications as read
  Future<void> _markInvitationNotificationsAsRead(
    InvitationId invitationId,
  ) async {
    // This would typically query notifications by invitation ID and mark them as read
    // For now, we'll implement this as a TODO until the notification repository has the method
    // TODO: Implement when NotificationRepository has markNotificationsByInvitationId method
    AppLogger.info(
      'Marking notifications as read for invitation: ${invitationId.value}',
      tag: 'AcceptInvitationUseCase',
    );
  }

  /// Notify project owner about acceptance using core notification service
  Future<void> _notifyProjectOwner(ProjectInvitation invitation) async {
    // Get project details
    final projectResult = await _projectRepository.getProjectById(
      invitation.projectId,
    );

    projectResult.fold(
      (failure) => AppLogger.error(
        'Failed to get project for notification: $failure',
        tag: 'AcceptInvitationUseCase',
      ),
      (project) async {
        if (invitation.invitedUserId != null) {
          // Get accepted user profile
          final acceptedUserProfile = await _getUserProfile(
            invitation.invitedUserId!,
          );

          final acceptedUserName = acceptedUserProfile.fold(
            (failure) => 'A user',
            (profile) => profile?.name ?? 'A user',
          );

          // Create notification for project owner using core notification service
          await _notificationService.createCollaboratorJoinedNotification(
            recipientId: invitation.invitedByUserId,
            projectId: invitation.projectId,
            projectName: project.name.value.getOrElse(() => 'Project'),
            collaboratorName: acceptedUserName,
          );
        }
      },
    );
  }

  /// Get user profile
  Future<Either<Failure, UserProfile?>> _getUserProfile(UserId userId) async {
    // Use UserProfileRepository to get user profile
    return await _userProfileRepository.getUserProfile(userId);
  }
}
