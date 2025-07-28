import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/invitations/domain/entities/project_invitation.dart';
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart';
import 'package:trackflow/features/invitations/domain/value_objects/send_invitation_params.dart';
import 'package:trackflow/features/user_profile/domain/usecases/find_user_by_email_usecase.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart';
import 'package:trackflow/core/notifications/domain/services/notification_service.dart';

/// Use case to send an invitation to a user
/// Handles both existing users and new users
@lazySingleton
class SendInvitationUseCase {
  final InvitationRepository _invitationRepository;
  final NotificationService _notificationService;
  final FindUserByEmailUseCase _findUserByEmail;
  final MagicLinkRepository _magicLinkRepository;

  SendInvitationUseCase({
    required InvitationRepository invitationRepository,
    required NotificationService notificationService,
    required FindUserByEmailUseCase findUserByEmail,
    required MagicLinkRepository magicLinkRepository,
  }) : _invitationRepository = invitationRepository,
       _notificationService = notificationService,
       _findUserByEmail = findUserByEmail,
       _magicLinkRepository = magicLinkRepository;

  /// Send an invitation to a user
  /// Returns the created invitation
  Future<Either<Failure, ProjectInvitation>> call(
    SendInvitationParams params,
  ) async {
    try {
      // 1. Search for existing user by email
      final userSearchResult = await _findUserByEmail(params.invitedEmail);

      UserProfile? existingUser;
      userSearchResult.fold(
        (failure) {
          // If search fails, assume user doesn't exist (for new user flow)
          existingUser = null;
        },
        (user) {
          existingUser = user;
        },
      );

      // 2. Create invitation with appropriate parameters
      final invitationParams = SendInvitationParams(
        projectId: params.projectId,
        invitedByUserId: params.invitedByUserId,
        invitedUserId: existingUser?.id, // null for new users
        invitedEmail: params.invitedEmail,
        proposedRole: params.proposedRole,
        message: params.message,
        expirationDuration:
            params.expirationDuration ?? const Duration(days: 30),
      );

      // 3. Create the invitation
      final invitationResult = await _invitationRepository.sendInvitation(
        invitationParams,
      );

      return invitationResult.fold((failure) => Left(failure), (
        invitation,
      ) async {
        // 4. Create notification for the invited user (if existing user)
        if (existingUser != null) {
          await _createNotificationForExistingUser(invitation, existingUser!);
        } else {
          // 5. Create magic link for new user
          await _createMagicLinkForNewUser(invitation);
        }

        return Right(invitation);
      });
    } catch (e) {
      return Left(ServerFailure('Failed to send invitation: $e'));
    }
  }

  /// Create notification for existing user using core notification service
  Future<void> _createNotificationForExistingUser(
    ProjectInvitation invitation,
    UserProfile existingUser,
  ) async {
    // Get inviter profile for notification
    final inviterProfileResult = await _getInviterProfile(
      invitation.invitedByUserId,
    );

    final inviterName = inviterProfileResult.fold(
      (failure) => 'Someone',
      (profile) => profile?.name ?? 'Someone',
    );

    // Get project name for notification
    final projectName = await _getProjectName(invitation.projectId);

    // Create notification using core notification service
    await _notificationService.createProjectInvitationNotification(
      recipientId: existingUser.id,
      invitationId: invitation.id.value,
      projectId: invitation.projectId.value,
      projectName: projectName,
      inviterName: inviterName,
      inviterEmail:
          invitation
              .invitedEmail, // This should be inviter's email, but we'll use invited email for now
    );
  }

  /// Create magic link for new user
  Future<void> _createMagicLinkForNewUser(ProjectInvitation invitation) async {
    // Generate magic link for invitation
    final magicLinkResult = await _magicLinkRepository.generateMagicLink(
      projectId: invitation.projectId,
      userId: invitation.invitedByUserId,
    );

    // TODO: Send email with magic link
    // This will be implemented in the email integration phase
    magicLinkResult.fold(
      (failure) => print('Failed to generate magic link: $failure'),
      (magicLink) => print('Magic link generated: ${magicLink.url}'),
    );
  }

  /// Get inviter profile
  Future<Either<Failure, UserProfile?>> _getInviterProfile(
    UserId inviterId,
  ) async {
    // This would typically use a UserProfileRepository method
    // For now, we'll return a simple result
    return Right(null);
  }

  /// Get project name
  Future<String> _getProjectName(ProjectId projectId) async {
    // This would typically use a ProjectRepository method
    // For now, we'll return a placeholder
    return 'Project';
  }
}
