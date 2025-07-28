import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/ui/loading/app_loading.dart';
import 'package:trackflow/features/invitations/domain/entities/project_invitation.dart';
import 'package:trackflow/features/invitations/presentation/components/invitation_card.dart';

/// List component to display invitations
class InvitationList extends StatelessWidget {
  final List<ProjectInvitation> invitations;
  final bool isLoading;
  final bool isEmpty;
  final String? emptyMessage;
  final VoidCallback? onInvitationTap;
  final Function(ProjectInvitation)? onAccept;
  final Function(ProjectInvitation)? onDecline;
  final Function(ProjectInvitation)? onCancel;
  final Map<String, bool> loadingStates; // invitationId -> isLoading

  const InvitationList({
    super.key,
    required this.invitations,
    this.isLoading = false,
    this.isEmpty = false,
    this.emptyMessage,
    this.onInvitationTap,
    this.onAccept,
    this.onDecline,
    this.onCancel,
    this.loadingStates = const {},
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
        final isLoading = loadingStates[invitation.id.value] ?? false;

        return InvitationCard(
          invitation: invitation,
          onTap: onInvitationTap != null ? () => onInvitationTap!() : null,
          onAccept: onAccept != null ? () => onAccept!(invitation) : null,
          onDecline: onDecline != null ? () => onDecline!(invitation) : null,
          onCancel: onCancel != null ? () => onCancel!(invitation) : null,
          isLoading: isLoading,
          isAcceptLoading: isLoading && onAccept != null,
          isDeclineLoading: isLoading && onDecline != null,
          isCancelLoading: isLoading && onCancel != null,
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
            color: AppColors.textSecondary.withOpacity(0.5),
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
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// List component specifically for pending invitations
class PendingInvitationsList extends StatelessWidget {
  final List<ProjectInvitation> invitations;
  final bool isLoading;
  final VoidCallback? onInvitationTap;
  final Function(ProjectInvitation)? onAccept;
  final Function(ProjectInvitation)? onDecline;
  final Map<String, bool> loadingStates;

  const PendingInvitationsList({
    super.key,
    required this.invitations,
    this.isLoading = false,
    this.onInvitationTap,
    this.onAccept,
    this.onDecline,
    this.loadingStates = const {},
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
      onAccept: onAccept,
      onDecline: onDecline,
      loadingStates: loadingStates,
    );
  }
}

/// List component specifically for sent invitations
class SentInvitationsList extends StatelessWidget {
  final List<ProjectInvitation> invitations;
  final bool isLoading;
  final VoidCallback? onInvitationTap;
  final Function(ProjectInvitation)? onCancel;
  final Map<String, bool> loadingStates;

  const SentInvitationsList({
    super.key,
    required this.invitations,
    this.isLoading = false,
    this.onInvitationTap,
    this.onCancel,
    this.loadingStates = const {},
  });

  @override
  Widget build(BuildContext context) {
    return InvitationList(
      invitations: invitations,
      isLoading: isLoading,
      isEmpty: invitations.isEmpty,
      emptyMessage: 'No sent invitations',
      onInvitationTap: onInvitationTap,
      onCancel: onCancel,
      loadingStates: loadingStates,
    );
  }
}
