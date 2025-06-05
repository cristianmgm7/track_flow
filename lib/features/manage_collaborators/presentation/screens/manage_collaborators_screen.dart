import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/entities/user_role.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_event.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_state.dart';
import 'package:trackflow/features/manage_collaborators/presentation/widgets/add_collaborator_dialog.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

class ManageCollaboratorsScreen extends StatefulWidget {
  final Project? project;
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
      LoadCollaborators(project: widget.project!),
    );
  }

  void _addCollaborator(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddCollaboratorDialog(projectId: widget.project!.id);
      },
    );
  }

  void _removeCollaborator(BuildContext context, UserId userId) {
    context.read<ManageCollaboratorsBloc>().add(RemoveCollaborator(userId));
  }

  void _updateCollaborator(
    BuildContext context,
    UserId userId,
    UserRole newRole,
  ) {
    context.read<ManageCollaboratorsBloc>().add(
      UpdateCollaboratorRole(userId: userId, newRole: newRole),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Collaborators'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'add_collaborator':
                  _addCollaborator(context);
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'add_collaborator',
                    child: Text('Add Collaborator'),
                  ),
                ],
          ),
        ],
      ),
      body: BlocBuilder<ManageCollaboratorsBloc, ManageCollaboratorsState>(
        builder: (context, state) {
          if (state is ManageCollaboratorsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ManageCollaboratorsLoaded) {
            return ListView.builder(
              itemCount: state.collaborators.length,
              itemBuilder: (context, index) {
                final userProfile = state.collaborators[index];
                return ListTile(
                  title: Text(userProfile.name),
                  subtitle: Text(userProfile.email),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      _removeCollaborator(context, userProfile.id);
                    },
                  ),
                );
              },
            );
          } else if (state is ManageCollaboratorsError) {
            return Center(
              child: Text(state.message, style: TextStyle(color: Colors.red)),
            );
          }
          return const Center(child: Text('No collaborators available'));
        },
      ),
    );
  }
}
