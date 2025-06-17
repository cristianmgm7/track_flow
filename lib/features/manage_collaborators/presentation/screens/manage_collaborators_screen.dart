import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_event.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_state.dart';
import 'package:trackflow/features/manage_collaborators/presentation/components/collaborator_component.dart';
import 'package:trackflow/features/manage_collaborators/presentation/widgets/remove_colaborator_dialog.dart';

class ManageCollaboratorsScreen extends StatefulWidget {
  final ProjectId projectId;

  const ManageCollaboratorsScreen({super.key, required this.projectId});

  @override
  State<ManageCollaboratorsScreen> createState() =>
      _ManageCollaboratorsScreenState();
}

class _ManageCollaboratorsScreenState extends State<ManageCollaboratorsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ManageCollaboratorsBloc>().add(
      GetProjectWithUserProfiles(projectId: widget.projectId),
    );
  }

  void _removeCollaborator(
    BuildContext context,
    UserId userId,
    String collaboratorName,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RemoveCollaboratorDialog(
          projectId: widget.projectId,
          collaboratorId: userId.value,
          collaboratorName: collaboratorName,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Collaborators')),
      body: BlocBuilder<ManageCollaboratorsBloc, ManageCollaboratorsState>(
        builder: (context, state) {
          if (state is ManageCollaboratorsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ManageCollaboratorsLoaded) {
            final project = state.projectWithUserProfiles.value1;
            final collaborators = state.projectWithUserProfiles.value2;

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
                  onRemove:
                      () => _removeCollaborator(
                        context,
                        collaborator.id,
                        collaborator.name,
                      ),
                );
              },
            );
          } else if (state is ManageCollaboratorsError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
