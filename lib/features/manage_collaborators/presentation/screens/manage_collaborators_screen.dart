import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_event.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_state.dart';
import 'package:trackflow/features/manage_collaborators/presentation/components/collaborator_component.dart';
import 'package:trackflow/features/manage_collaborators/presentation/widgets/remove_colaborator_dialog.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

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

  void _removeCollaborator(
    BuildContext context,
    UserId userId,
    String collaboratorName,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RemoveCollaboratorDialog(
          projectId: widget.project.id,
          collaboratorId: userId.value,
          collaboratorName: collaboratorName,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ManageCollaboratorsBloc, ManageCollaboratorsState>(
        builder: (context, state) {
          if (state is ManageCollaboratorsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ManageCollaboratorsLoaded) {
            final collaborators = state.userProfiles;

            return ListView.builder(
              itemCount: collaborators.length,
              itemBuilder: (context, index) {
                final collaborator = collaborators[index];
                // Find the collaborator's role from the project
                final projectCollaborator = widget.project.collaborators
                    .firstWhere((c) => c.userId == collaborator.id);

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
