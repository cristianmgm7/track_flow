import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';
import 'package:trackflow/features/project_detail/presentation/components/collaborator_card.dart';
import 'package:trackflow/features/project_detail/presentation/components/invite_collaborator_button.dart';
import 'package:trackflow/features/manage_collaborators/presentation/widgets/send_invitation_form.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/features/ui/modals/app_form_sheet.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart';

class ProjectDetailCollaboratorsComponent extends StatelessWidget {
  final ProjectDetailState state;
  const ProjectDetailCollaboratorsComponent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.people),
                const SizedBox(width: 8),
                Text(
                  'Collaborators (${state.collaborators.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (state.isLoadingCollaborators) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
                IconButton(
                  alignment: Alignment.centerRight,
                  onPressed: () {
                    context.push(
                      AppRoutes.manageCollaborators,
                      extra: state.project,
                    );
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
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
                    // Invite collaborator button
                    InviteCollaboratorButton(
                      onTap: () => _showInviteCollaboratorForm(context),
                    ),
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
                      );
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showInviteCollaboratorForm(BuildContext context) {
    showAppFormSheet(
      title: 'Invite Collaborator',
      context: context,
      useRootNavigator: false,
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
