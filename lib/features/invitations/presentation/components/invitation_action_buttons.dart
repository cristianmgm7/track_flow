import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';
import 'package:trackflow/features/ui/buttons/secondary_button.dart';
import 'package:trackflow/features/invitations/domain/entities/project_invitation.dart';
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart';
import 'package:trackflow/features/invitations/presentation/blocs/events/invitation_events.dart';
import 'package:trackflow/features/invitations/presentation/blocs/states/invitation_states.dart';

/// Action buttons for invitation actions (Accept/Decline)
/// Uses BLoC pattern for state management and event handling
class InvitationActionButtons extends StatelessWidget {
  final ProjectInvitation invitation;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const InvitationActionButtons({
    super.key,
    required this.invitation,
    this.onSuccess,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    // Only show action buttons for pending invitations
    if (invitation.status != InvitationStatus.pending) {
      return const SizedBox.shrink();
    }

    return BlocConsumer<ProjectInvitationActorBloc, InvitationActorState>(
      listener: (context, state) {
        if (state is AcceptInvitationSuccess || state is DeclineInvitationSuccess) {
          onSuccess?.call();
        } else if (state is InvitationActorError) {
          onError?.call();
        }
      },
      builder: (context, state) {
        final isLoading = state is InvitationActorLoading;
        
        return Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'Decline',
                onPressed: isLoading ? null : () => _handleDecline(context),
                isLoading: isLoading,
                icon: Icons.close,
                size: ButtonSize.small,
              ),
            ),
            SizedBox(width: Dimensions.space12),
            Expanded(
              child: PrimaryButton(
                text: 'Accept',
                onPressed: isLoading ? null : () => _handleAccept(context),
                isLoading: isLoading,
                icon: Icons.check,
                size: ButtonSize.small,
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleAccept(BuildContext context) {
    context.read<ProjectInvitationActorBloc>().add(
      AcceptInvitation(invitation.id),
    );
  }

  void _handleDecline(BuildContext context) {
    context.read<ProjectInvitationActorBloc>().add(
      DeclineInvitation(invitation.id),
    );
  }
}

/// Action buttons for sent invitations (Cancel)
/// Uses BLoC pattern for state management and event handling
class SentInvitationActionButtons extends StatelessWidget {
  final ProjectInvitation invitation;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const SentInvitationActionButtons({
    super.key,
    required this.invitation,
    this.onSuccess,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    // Only show cancel button for pending invitations
    if (invitation.status != InvitationStatus.pending) {
      return const SizedBox.shrink();
    }

    return BlocConsumer<ProjectInvitationActorBloc, InvitationActorState>(
      listener: (context, state) {
        if (state is CancelInvitationSuccess) {
          onSuccess?.call();
        } else if (state is InvitationActorError) {
          onError?.call();
        }
      },
      builder: (context, state) {
        final isLoading = state is InvitationActorLoading;
        
        return PrimaryButton(
          text: 'Cancel Invitation',
          onPressed: isLoading ? null : () => _handleCancel(context),
          isLoading: isLoading,
          icon: Icons.cancel,
          size: ButtonSize.small,
          isDestructive: true,
        );
      },
    );
  }

  void _handleCancel(BuildContext context) {
    context.read<ProjectInvitationActorBloc>().add(
      CancelInvitation(invitation.id),
    );
  }
}
