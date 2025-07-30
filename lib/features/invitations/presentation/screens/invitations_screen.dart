import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/invitations/presentation/blocs/events/invitation_events.dart';
import 'package:trackflow/features/invitations/presentation/blocs/states/invitation_states.dart';
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart';
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/widgets/send_invitation_form.dart';
import 'package:trackflow/features/invitations/presentation/components/invitation_card.dart';
import 'package:trackflow/features/invitations/domain/entities/project_invitation.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';
import 'package:trackflow/features/ui/feedback/app_feedback_system.dart';
import 'package:trackflow/core/entities/unique_id.dart';

/// Main invitations screen
class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({super.key});

  @override
  State<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Start watching invitations
    context.read<ProjectInvitationWatcherBloc>().add(
      const WatchPendingInvitations(),
    );
    context.read<ProjectInvitationWatcherBloc>().add(
      const WatchSentInvitations(),
    );
    context.read<ProjectInvitationWatcherBloc>().add(
      const WatchInvitationCount(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openSendInvitationSheet() {
    // TODO: Get actual project ID from context or navigation parameter
    final testProjectId = ProjectId.fromUniqueString('test-project-id');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radiusLarge),
                topRight: Radius.circular(Dimensions.radiusLarge),
              ),
            ),
            padding: EdgeInsets.only(
              left: Dimensions.space16,
              right: Dimensions.space16,
              top: Dimensions.space16,
              bottom:
                  MediaQuery.of(context).viewInsets.bottom + Dimensions.space16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: Dimensions.space16),
                Text(
                  'Invite Collaborator',
                  style: AppTextStyle.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Dimensions.space20),
                SendInvitationForm(projectId: testProjectId),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectInvitationActorBloc, InvitationActorState>(
      listener: (context, state) {
        if (state is SendInvitationSuccess) {
          AppFeedbackSystem.showSnackBar(
            context,
            message: 'Invitation sent successfully!',
            type: FeedbackType.success,
          );
        } else if (state is AcceptInvitationSuccess) {
          AppFeedbackSystem.showSnackBar(
            context,
            message: 'Invitation accepted successfully!',
            type: FeedbackType.success,
          );
        } else if (state is DeclineInvitationSuccess) {
          AppFeedbackSystem.showSnackBar(
            context,
            message: 'Invitation declined successfully!',
            type: FeedbackType.success,
          );
        } else if (state is CancelInvitationSuccess) {
          AppFeedbackSystem.showSnackBar(
            context,
            message: 'Invitation cancelled successfully!',
            type: FeedbackType.success,
          );
        } else if (state is InvitationActorError) {
          AppFeedbackSystem.showSnackBar(
            context,
            message: 'Action failed: ${state.message}',
            type: FeedbackType.error,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Invitations'),
          backgroundColor: AppColors.surface,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'Pending'), Tab(text: 'Sent')],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Pending Invitations Tab
            BlocBuilder<ProjectInvitationWatcherBloc, InvitationWatcherState>(
              builder: (context, state) {
                if (state is InvitationWatcherLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is InvitationWatcherError) {
                  return _buildErrorState(
                    'Error loading pending invitations',
                    state.message,
                    () => context.read<ProjectInvitationWatcherBloc>().add(
                      const WatchPendingInvitations(),
                    ),
                  );
                }

                // Handle specific pending invitations state
                if (state is PendingInvitationsWatcherState) {
                  if (state.pendingInvitations.isEmpty) {
                    return _buildEmptyState(
                      Icons.inbox_outlined,
                      'No pending invitations',
                      'When you receive invitations, they will appear here',
                    );
                  }
                  return _buildPendingInvitationsList(state.pendingInvitations);
                }

                // Handle general success state
                if (state is InvitationWatcherSuccess) {
                  final pendingInvitations =
                      state.invitations
                          .where(
                            (inv) => inv.status == InvitationStatus.pending,
                          )
                          .toList();

                  if (pendingInvitations.isEmpty) {
                    return _buildEmptyState(
                      Icons.inbox_outlined,
                      'No pending invitations',
                      'When you receive invitations, they will appear here',
                    );
                  }
                  return _buildPendingInvitationsList(pendingInvitations);
                }

                // Default empty state
                return _buildEmptyState(
                  Icons.inbox_outlined,
                  'No pending invitations',
                  'When you receive invitations, they will appear here',
                );
              },
            ),
            // Sent Invitations Tab
            BlocBuilder<ProjectInvitationWatcherBloc, InvitationWatcherState>(
              builder: (context, state) {
                if (state is InvitationWatcherLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is InvitationWatcherError) {
                  return _buildErrorState(
                    'Error loading sent invitations',
                    state.message,
                    () => context.read<ProjectInvitationWatcherBloc>().add(
                      const WatchSentInvitations(),
                    ),
                  );
                }

                // Handle specific sent invitations state
                if (state is SentInvitationsWatcherState) {
                  if (state.sentInvitations.isEmpty) {
                    return _buildEmptyState(
                      Icons.send_outlined,
                      'No sent invitations',
                      'When you send invitations, they will appear here',
                    );
                  }
                  return _buildSentInvitationsList(state.sentInvitations);
                }

                // Handle general success state
                if (state is InvitationWatcherSuccess) {
                  // For sent invitations, we need to check if current user is the inviter
                  // For now, we'll show all invitations - this should be filtered by user
                  if (state.invitations.isEmpty) {
                    return _buildEmptyState(
                      Icons.send_outlined,
                      'No sent invitations',
                      'When you send invitations, they will appear here',
                    );
                  }
                  return _buildSentInvitationsList(state.invitations);
                }

                // Default empty state
                return _buildEmptyState(
                  Icons.send_outlined,
                  'No sent invitations',
                  'When you send invitations, they will appear here',
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openSendInvitationSheet,
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: AppColors.onPrimary),
        ),
      ),
    );
  }

  Widget _buildErrorState(String title, String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: AppTextStyle.titleMedium),
          SizedBox(height: Dimensions.space8),
          Text(
            message,
            style: AppTextStyle.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: Dimensions.space16),
          PrimaryButton(text: 'Retry', onPressed: onRetry),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          SizedBox(height: Dimensions.space16),
          Text(
            title,
            style: AppTextStyle.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Dimensions.space8),
          Text(
            subtitle,
            style: AppTextStyle.bodyMedium.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingInvitationsList(List<ProjectInvitation> invitations) {
    return ListView.builder(
      padding: EdgeInsets.all(Dimensions.space16),
      itemCount: invitations.length,
      itemBuilder: (context, index) {
        final invitation = invitations[index];
        return Padding(
          padding: EdgeInsets.only(bottom: Dimensions.space12),
          child: InvitationCard(
            invitation: invitation,
            showReceivedActions: true,
            onActionSuccess: () {
              // Optional: Refresh the list or show success feedback
              // The BLoC listener already handles global feedback
            },
            onActionError: () {
              // Optional: Handle specific error cases
              // The BLoC listener already handles global error feedback
            },
          ),
        );
      },
    );
  }

  Widget _buildSentInvitationsList(List<ProjectInvitation> invitations) {
    return ListView.builder(
      padding: EdgeInsets.all(Dimensions.space16),
      itemCount: invitations.length,
      itemBuilder: (context, index) {
        final invitation = invitations[index];
        return Padding(
          padding: EdgeInsets.only(bottom: Dimensions.space12),
          child: InvitationCard(
            invitation: invitation,
            showSentActions: invitation.status == InvitationStatus.pending,
            onActionSuccess: () {
              // Optional: Refresh the list or show success feedback
              // The BLoC listener already handles global feedback
            },
            onActionError: () {
              // Optional: Handle specific error cases
              // The BLoC listener already handles global error feedback
            },
          ),
        );
      },
    );
  }
}
