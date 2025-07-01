import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/presentation/widgets/trackflow_action_bottom_sheet.dart';
import 'package:trackflow/core/presentation/widgets/trackflow_form_bottom_sheet.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_event.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_state.dart';
import 'package:trackflow/features/manage_collaborators/presentation/components/collaborator_component.dart';
import 'package:trackflow/features/manage_collaborators/presentation/widgets/manage_collaborators_actions.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/add_collaborator_form.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class ManageCollaboratorsScreen extends StatefulWidget {
  final Project project;

  const ManageCollaboratorsScreen({super.key, required this.project});

  @override
  State<ManageCollaboratorsScreen> createState() =>
      _ManageCollaboratorsScreenState();
}

class _ManageCollaboratorsScreenState extends State<ManageCollaboratorsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ManageCollaboratorsBloc>().add(
      WatchCollaborators(project: widget.project),
    );
  }

  void _openCollaboratorActionsSheet(UserProfile collaborator) {
    showTrackFlowActionSheet(
      title: collaborator.name,
      context: context,
      actions: CollaboratorActions.forCollaborator(
        context: context,
        project: widget.project,
        collaborator: collaborator,
      ),
    );
  }

  void _openAddCollaboratorSheet() {
    showTrackFlowFormSheet(
      title: 'Invite Collaborator',
      context: context,
      child: AddCollaboratorForm(project: widget.project),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collaborators'),
        actions: [
          IconButton(
            onPressed: _openAddCollaboratorSheet,
            icon: const Icon(Icons.add),
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
          }
        },
        builder: (context, state) {
          if (state is ManageCollaboratorsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ManageCollaboratorsLoaded) {
            final collaborators = state.userProfiles;
            final project = state.project;

            return ListView.builder(
              itemCount: collaborators.length,
              itemBuilder: (context, index) {
                final collaborator = collaborators[index];
                // Find the collaborator's role from the project
                final projectCollaborator = project.collaborators.firstWhere(
                  (c) => c.userId == collaborator.id,
                );

                return CollaboratorComponent(
                  name: collaborator.name,
                  imageUrl: collaborator.avatarUrl,
                  role: projectCollaborator.role,
                  userId: collaborator.id,
                  onTap: () => _openCollaboratorActionsSheet(collaborator),
                );
              },
            );
          } else {
            // Instead of showing the error, just show a fallback
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
