import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/ui/loading/app_loading.dart';
import 'package:trackflow/features/invitations/domain/entities/project_invitation.dart';
import 'package:trackflow/features/invitations/presentation/components/invitation_card.dart';

/// List component to display invitations
/// Uses BLoC pattern for action handling
class InvitationList extends StatelessWidget {
  final List<ProjectInvitation> invitations;
  final bool isLoading;
  final bool isEmpty;
  final String? emptyMessage;
  final VoidCallback? onInvitationTap;
  final VoidCallback? onActionSuccess;
  final VoidCallback? onActionError;
  final bool showReceivedActions;
  final bool showSentActions;

  const InvitationList({
    super.key,
    required this.invitations,
    this.isLoading = false,
    this.isEmpty = false,
    this.emptyMessage,
    this.onInvitationTap,
    this.onActionSuccess,
    this.onActionError,
    this.showReceivedActions = false,
    this.showSentActions = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: AppLoading(message: 'Loading invitations...'));
    }

    if (isEmpty || invitations.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: EdgeInsets.all(Dimensions.space16),
      itemCount: invitations.length,
      separatorBuilder:
          (context, index) => SizedBox(height: Dimensions.space12),
      itemBuilder: (context, index) {
        final invitation = invitations[index];

        return InvitationCard(
          invitation: invitation,
          onTap: onInvitationTap,
          onActionSuccess: onActionSuccess,
          onActionError: onActionError,
          showReceivedActions: showReceivedActions,
          showSentActions: showSentActions,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          SizedBox(height: Dimensions.space16),
          Text(
            emptyMessage ?? 'No invitations found',
            style: AppTextStyle.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Dimensions.space8),
          Text(
            'When you receive invitations, they will appear here',
            style: AppTextStyle.bodyMedium.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// List component specifically for pending invitations
/// Uses BLoC pattern for action handling
class PendingInvitationsList extends StatelessWidget {
  final List<ProjectInvitation> invitations;
  final bool isLoading;
  final VoidCallback? onInvitationTap;
  final VoidCallback? onActionSuccess;
  final VoidCallback? onActionError;

  const PendingInvitationsList({
    super.key,
    required this.invitations,
    this.isLoading = false,
    this.onInvitationTap,
    this.onActionSuccess,
    this.onActionError,
  });

  @override
  Widget build(BuildContext context) {
    final pendingInvitations =
        invitations
            .where(
              (invitation) => invitation.status == InvitationStatus.pending,
            )
            .toList();

    return InvitationList(
      invitations: pendingInvitations,
      isLoading: isLoading,
      isEmpty: pendingInvitations.isEmpty,
      emptyMessage: 'No pending invitations',
      onInvitationTap: onInvitationTap,
      onActionSuccess: onActionSuccess,
      onActionError: onActionError,
      showReceivedActions: true,
    );
  }
}

/// List component specifically for sent invitations
/// Uses BLoC pattern for action handling
class SentInvitationsList extends StatelessWidget {
  final List<ProjectInvitation> invitations;
  final bool isLoading;
  final VoidCallback? onInvitationTap;
  final VoidCallback? onActionSuccess;
  final VoidCallback? onActionError;

  const SentInvitationsList({
    super.key,
    required this.invitations,
    this.isLoading = false,
    this.onInvitationTap,
    this.onActionSuccess,
    this.onActionError,
  });

  @override
  Widget build(BuildContext context) {
    return InvitationList(
      invitations: invitations,
      isLoading: isLoading,
      isEmpty: invitations.isEmpty,
      emptyMessage: 'No sent invitations',
      onInvitationTap: onInvitationTap,
      onActionSuccess: onActionSuccess,
      onActionError: onActionError,
      showSentActions: true,
    );
  }
}
