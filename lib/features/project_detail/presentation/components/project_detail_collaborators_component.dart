import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';
import 'package:trackflow/features/project_detail/presentation/components/collaborator_card.dart';
import 'package:trackflow/features/project_detail/presentation/components/invite_collaborator_button.dart';
import 'package:trackflow/features/manage_collaborators/presentation/widgets/send_invitation_form.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/features/ui/modals/app_form_sheet.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_permission.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/entities/project_collaborator.dart';

class ProjectDetailCollaboratorsComponent extends StatelessWidget {
  final ProjectDetailState state;
  const ProjectDetailCollaboratorsComponent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.space16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Collaborators (${state.collaborators.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  alignment: Alignment.centerRight,
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    context.push(
                      AppRoutes.manageCollaborators,
                      extra: state.project,
                    );
                  },
                ),
              ],
            ),
          ),
          if (state.collaboratorsError != null) ...[
            const SizedBox(height: 8),
            Text(
              'Error loading collaborators: ${state.collaboratorsError}',
              style: const TextStyle(color: Colors.red),
            ),
          ],
          if (state.collaborators.isEmpty &&
              !state.isLoadingCollaborators &&
              state.collaboratorsError == null) ...[
            const SizedBox(height: 16),
            const Text('No collaborators found'),
          ],
          if (state.collaborators.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 240.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  // Existing collaborators
                  ...state.collaborators.map((collaborator) {
                    // Find the role from project collaborators
                    final projectCollaborator = state.project?.collaborators
                        .firstWhere(
                          (pc) => pc.userId == collaborator.id,
                          orElse:
                              () =>
                                  throw StateError('Collaborator not found'),
                        );
      
                    return CollaboratorCard(
                      name: collaborator.name,
                      email: collaborator.email,
                      avatarUrl: collaborator.avatarUrl,
                      role: projectCollaborator?.role ?? ProjectRole.viewer,
                      creativeRole: collaborator.creativeRole,
                      onTap: () {
                        context.push(
                          AppRoutes.artistProfile.replaceFirst(
                            ':id',
                            collaborator.id.value,
                          ),
                        );
                      },
                      id: collaborator.id.value,
                    );
                  }),
                  // Invite collaborator button at the end (permission-gated)
                  Builder(
                    builder: (context) {
                      final userState = context.watch<CurrentUserBloc>().state;
                      final String? currentUserId =
                          userState is CurrentUserLoaded ? userState.profile.id.value : null;
                      bool canInvite = false;
                      if (state.project != null && currentUserId != null) {
                        final me = state.project!.collaborators.firstWhere(
                          (c) => c.userId.value == currentUserId,
                          orElse: () => ProjectCollaborator.create(
                            userId: UserId.fromUniqueString(currentUserId),
                            role: ProjectRole.viewer,
                          ),
                        );
                        canInvite = me.hasPermission(ProjectPermission.addCollaborator);
                      }
                      if (!canInvite) return const SizedBox.shrink();
                      return InviteCollaboratorButton(
                        onTap: () => _showInviteCollaboratorForm(context),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showInviteCollaboratorForm(BuildContext context) {
    showAppFormSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.8,
      minChildSize: 0.8,
      title: 'Invite Collaborator',
      context: context,
      useRootNavigator: true,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ManageCollaboratorsBloc>.value(
            value: context.read<ManageCollaboratorsBloc>(),
          ),
          BlocProvider<ProjectInvitationActorBloc>(
            create: (context) => sl<ProjectInvitationActorBloc>(),
          ),
        ],
        child: SendInvitationForm(projectId: state.project!.id),
      ),
    );
  }
}
