import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/invitations/presentation/blocs/events/invitation_events.dart';
import 'package:trackflow/features/invitations/presentation/blocs/states/invitation_states.dart';
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart';
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart';
import 'package:trackflow/features/invitations/presentation/components/send_invitation_form.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';
import 'package:trackflow/features/ui/feedback/app_feedback_system.dart';
import 'package:trackflow/core/di/injection.dart';
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
    print('DEBUG: Opening send invitation sheet');

    // Test with a very simple modal first
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Test Modal'),
            content: const Text('This is a test to see if modals work'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );

    print('DEBUG: Simple dialog opened');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectInvitationActorBloc, InvitationActorState>(
      listener: (context, state) {
        if (state is InvitationActorSuccess) {
          AppFeedbackSystem.showSnackBar(
            context,
            message: 'Invitation sent successfully!',
            type: FeedbackType.success,
          );
        } else if (state is InvitationActorError) {
          AppFeedbackSystem.showSnackBar(
            context,
            message: 'Failed to send invitation: ${state.message}',
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error loading invitations',
                          style: AppTextStyle.titleMedium,
                        ),
                        SizedBox(height: Dimensions.space8),
                        Text(
                          state.message,
                          style: AppTextStyle.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: Dimensions.space16),
                        PrimaryButton(
                          text: 'Retry',
                          onPressed: () {
                            context.read<ProjectInvitationWatcherBloc>().add(
                              const WatchPendingInvitations(),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }

                // For now, show empty state
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
                        'No pending invitations',
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
              },
            ),
            // Sent Invitations Tab
            BlocBuilder<ProjectInvitationWatcherBloc, InvitationWatcherState>(
              builder: (context, state) {
                if (state is InvitationWatcherLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is InvitationWatcherError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error loading invitations',
                          style: AppTextStyle.titleMedium,
                        ),
                        SizedBox(height: Dimensions.space8),
                        Text(
                          state.message,
                          style: AppTextStyle.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: Dimensions.space16),
                        PrimaryButton(
                          text: 'Retry',
                          onPressed: () {
                            context.read<ProjectInvitationWatcherBloc>().add(
                              const WatchSentInvitations(),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }

                // For now, show empty state
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send_outlined,
                        size: 64,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      SizedBox(height: Dimensions.space16),
                      Text(
                        'No sent invitations',
                        style: AppTextStyle.titleMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: Dimensions.space8),
                      Text(
                        'When you send invitations, they will appear here',
                        style: AppTextStyle.bodyMedium.copyWith(
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
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
}
