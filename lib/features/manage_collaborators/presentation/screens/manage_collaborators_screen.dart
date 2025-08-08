import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/ui/modals/app_bottom_sheet.dart';
import 'package:trackflow/features/ui/modals/app_form_sheet.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_event.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_state.dart';
import 'package:trackflow/features/manage_collaborators/presentation/components/collaborator_component.dart';
import 'package:trackflow/features/manage_collaborators/presentation/widgets/manage_collaborators_actions.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/manage_collaborators/presentation/widgets/send_invitation_form.dart';
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/core/di/injection.dart';

class ManageCollaboratorsScreen extends StatefulWidget {
  final Project project;

  const ManageCollaboratorsScreen({super.key, required this.project});

  @override
  State<ManageCollaboratorsScreen> createState() =>
      _ManageCollaboratorsScreenState();
}

class _ManageCollaboratorsScreenState extends State<ManageCollaboratorsScreen> {
  ManageCollaboratorsLoaded? _lastLoadedState;

  @override
  void initState() {
    super.initState();
    context.read<ManageCollaboratorsBloc>().add(
      WatchCollaborators(project: widget.project),
    );
  }

  void _openCollaboratorActionsSheet(
    UserProfile collaborator,
    Project currentProject,
  ) {
    showAppActionSheet(
      title: collaborator.name,
      context: context,
      actions: CollaboratorActions.forCollaborator(
        context: context,
        project: currentProject,
        collaborator: collaborator,
      ),
    );
  }

  void _openAddCollaboratorSheet(Project currentProject) {
    showAppFormSheet(
      title: 'Invite Collaborator',
      context: context,
      useRootNavigator: false, // Mantener en false para no perder contexto
      child: BlocProvider(
        create: (context) => sl<ProjectInvitationActorBloc>(),
        child: SendInvitationForm(projectId: currentProject.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProjectInvitationActorBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Collaborators'),
          actions: [
            BlocBuilder<ManageCollaboratorsBloc, ManageCollaboratorsState>(
              builder: (context, state) {
                final currentProject =
                    state is ManageCollaboratorsLoaded
                        ? state.project
                        : widget.project;
                return IconButton(
                  onPressed: () => _openAddCollaboratorSheet(currentProject),
                  icon: const Icon(Icons.add),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<ManageCollaboratorsBloc, ManageCollaboratorsState>(
          listener: (context, state) {
            if (state is ManageCollaboratorsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is UpdateCollaboratorRoleSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Role updated to ${state.newRole}'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          builder: (context, state) {
            // Get the current project and collaborators from the most appropriate state
            Project currentProject;
            List<UserProfile> currentCollaborators;
            bool isLoading = false;

            if (state is ManageCollaboratorsLoaded) {
              currentProject = state.project;
              currentCollaborators = state.userProfiles;
            } else if (state is UpdateCollaboratorRoleSuccess) {
              currentProject = state.project;
              // For success state, we need to get collaborators from the last loaded state
              // or use a fallback
              currentCollaborators = _lastLoadedState?.userProfiles ?? [];
            } else if (state is RemoveCollaboratorSuccess) {
              currentProject = state.project;
              currentCollaborators = _lastLoadedState?.userProfiles ?? [];
            } else if (state is ManageCollaboratorsLoading) {
              // During loading, show the last known state
              currentProject = _lastLoadedState?.project ?? widget.project;
              currentCollaborators = _lastLoadedState?.userProfiles ?? [];
              isLoading = true;
            } else {
              // Fallback to initial project
              currentProject = widget.project;
              currentCollaborators = [];
            }

            // Update last loaded state for future reference
            if (state is ManageCollaboratorsLoaded) {
              _lastLoadedState = state;
            }

            return Stack(
              children: [
                // Main content
                ListView.builder(
                  itemCount: currentCollaborators.length,
                  itemBuilder: (context, index) {
                    final collaborator = currentCollaborators[index];
                    // Find the collaborator's role from the project
                    final projectCollaborator = currentProject.collaborators
                        .firstWhere(
                          (c) => c.userId == collaborator.id,
                          orElse:
                              () =>
                                  throw Exception(
                                    'Collaborator not found in project',
                                  ),
                        );

                    return CollaboratorComponent(
                      name: collaborator.name,
                      imageUrl: collaborator.avatarUrl,
                      role: projectCollaborator.role,
                      userId: collaborator.id,
                      onTap:
                          () => _openCollaboratorActionsSheet(
                            collaborator,
                            currentProject,
                          ),
                    );
                  },
                ),
                // Loading overlay
                if (isLoading)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Updating...',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
