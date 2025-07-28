import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';
import 'package:trackflow/features/ui/buttons/secondary_button.dart';
import 'package:trackflow/features/invitations/domain/entities/project_invitation.dart';

/// Action buttons for invitation actions (Accept/Decline)
class InvitationActionButtons extends StatelessWidget {
  final ProjectInvitation invitation;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final bool isLoading;
  final bool isAcceptLoading;
  final bool isDeclineLoading;

  const InvitationActionButtons({
    super.key,
    required this.invitation,
    this.onAccept,
    this.onDecline,
    this.isLoading = false,
    this.isAcceptLoading = false,
    this.isDeclineLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Only show action buttons for pending invitations
    if (invitation.status != InvitationStatus.pending) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            text: 'Decline',
            onPressed: isLoading || isDeclineLoading ? null : onDecline,
            isLoading: isDeclineLoading,
            icon: Icons.close,
            size: ButtonSize.small,
          ),
        ),
        SizedBox(width: Dimensions.space12),
        Expanded(
          child: PrimaryButton(
            text: 'Accept',
            onPressed: isLoading || isAcceptLoading ? null : onAccept,
            isLoading: isAcceptLoading,
            icon: Icons.check,
            size: ButtonSize.small,
          ),
        ),
      ],
    );
  }
}

/// Action buttons for sent invitations (Cancel)
class SentInvitationActionButtons extends StatelessWidget {
  final ProjectInvitation invitation;
  final VoidCallback? onCancel;
  final bool isLoading;

  const SentInvitationActionButtons({
    super.key,
    required this.invitation,
    this.onCancel,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Only show cancel button for pending invitations
    if (invitation.status != InvitationStatus.pending) {
      return const SizedBox.shrink();
    }

    return PrimaryButton(
      text: 'Cancel Invitation',
      onPressed: isLoading ? null : onCancel,
      isLoading: isLoading,
      icon: Icons.cancel,
      size: ButtonSize.small,
      isDestructive: true,
    );
  }
}
