import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/entities/user_role.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_event.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_state.dart';
import 'package:trackflow/features/manage_collaborators/presentation/widgets/add_collaborator_dialog.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class ManageCollaboratorsScreen extends StatefulWidget {
  final Project? project;
  final List<UserProfile> collaborators;
  const ManageCollaboratorsScreen({
    super.key,
    required this.project,
    required this.collaborators,
  });

  @override
  State<ManageCollaboratorsScreen> createState() =>
      _ManageCollaboratorsScreenState();
}

class _ManageCollaboratorsScreenState extends State<ManageCollaboratorsScreen> {
  @override
  void initState() {
    super.initState();
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
    context.read<ManageCollaboratorsBloc>().add(
      RemoveCollaborator(projectId: widget.project!.id, userId: userId),
    );
  }

  void _updateCollaborator(
    BuildContext context,
    UserId userId,
    UserRole newRole,
  ) {
    context.read<ManageCollaboratorsBloc>().add(
      UpdateCollaboratorRole(
        projectId: widget.project!.id,
        userId: userId,
        newRole: newRole,
      ),
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
          if (state is ManageCollaboratorsInitial) {
            return const Center(child: Text('No collaborators available'));
          } else if (state is ManageCollaboratorsError) {
            return Center(
              child: Text(state.message, style: TextStyle(color: Colors.red)),
            );
          } else if (state is AddCollaboratorSuccess ||
              state is UpdateCollaboratorRoleSuccess ||
              state is RemoveCollaboratorSuccess ||
              state is JoinProjectSuccess) {
            return ListView.builder(
              itemCount: widget.collaborators.length,
              itemBuilder: (context, index) {
                final userProfile = widget.collaborators[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: ListTile(
                    title: Text(userProfile.name),
                    subtitle: Text(userProfile.email),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        _removeCollaborator(context, userProfile.id);
                      },
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
