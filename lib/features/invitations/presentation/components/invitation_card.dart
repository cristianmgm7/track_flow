import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/ui/cards/base_card.dart';
import 'package:trackflow/features/invitations/domain/entities/project_invitation.dart';
import 'package:trackflow/features/invitations/presentation/widgets/invitation_status_badge.dart';
import 'package:trackflow/features/invitations/presentation/components/invitation_action_buttons.dart';

/// Card widget to display individual invitation
/// Uses BLoC pattern for action handling
class InvitationCard extends StatelessWidget {
  final ProjectInvitation invitation;
  final VoidCallback? onTap;
  final VoidCallback? onActionSuccess;
  final VoidCallback? onActionError;
  final bool showReceivedActions;
  final bool showSentActions;

  const InvitationCard({
    super.key,
    required this.invitation,
    this.onTap,
    this.onActionSuccess,
    this.onActionError,
    this.showReceivedActions = false,
    this.showSentActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: Dimensions.space12),
          _buildContent(),
          if (_shouldShowActions()) ...[
            SizedBox(height: Dimensions.space16),
            _buildActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project ${invitation.projectId.value}', // TODO: Get project name from project service
                style: AppTextStyle.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: Dimensions.space4),
              Text(
                'Role: ${invitation.proposedRole.toShortString()}',
                style: AppTextStyle.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        InvitationStatusBadge(status: invitation.status),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          'From',
          'User ${invitation.invitedByUserId.value}',
        ), // TODO: Get user name from user service
        SizedBox(height: Dimensions.space8),
        _buildInfoRow('To', invitation.invitedEmail),
        SizedBox(height: Dimensions.space8),
        _buildInfoRow('Sent', _formatDate(invitation.createdAt)),
        ...[
          SizedBox(height: Dimensions.space8),
          _buildInfoRow('Expires', _formatDate(invitation.expiresAt)),
        ],
        if (invitation.message?.isNotEmpty == true) ...[
          SizedBox(height: Dimensions.space12),
          Container(
            padding: EdgeInsets.all(Dimensions.space12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Text(
              invitation.message!,
              style: AppTextStyle.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: AppTextStyle.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyle.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    // For pending invitations received by the user
    if (invitation.status == InvitationStatus.pending && showReceivedActions) {
      return InvitationActionButtons(
        invitation: invitation,
        onSuccess: onActionSuccess,
        onError: onActionError,
      );
    }

    // For pending invitations sent by the user
    if (invitation.status == InvitationStatus.pending && showSentActions) {
      return SentInvitationActionButtons(
        invitation: invitation,
        onSuccess: onActionSuccess,
        onError: onActionError,
      );
    }

    return const SizedBox.shrink();
  }

  bool _shouldShowActions() {
    return invitation.status == InvitationStatus.pending &&
        (showReceivedActions || showSentActions);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
