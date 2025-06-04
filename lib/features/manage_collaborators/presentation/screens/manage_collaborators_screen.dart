import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/entities/user_role.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/load_user_profile_collaborators_usecase.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_event.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

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
      LoadCollaborators(
        projectWithCollaborators: ProjectWithCollaborators(
          projectId: widget.project!.id,
          collaborators: [],
        ),
      ),
    );
  }

  void _addCollaborator(BuildContext context) {
    // Logic to add collaborator
  }

  void _removeCollaborator(BuildContext context) {
    // Logic to remove collaborator
  }

  void _updateCollaborator(BuildContext context) {
    // Logic to update collaborator
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
                case 'remove_collaborator':
                  _removeCollaborator(context);
                  break;
                case 'update_collaborator':
                  _updateCollaborator(context);
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(child: Text('Add Collaborator'), onTap: () {}),
                ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          final userProfile = UserProfile(
            id: UserId.fromUniqueString('123'),
            name: 'John Doe',
            email: 'john.doe@example.com',
            avatarUrl: 'https://example.com/avatar.png',
            createdAt: DateTime.now(),
            role: UserRole.admin,
          );
          return ListTile(
            title: Text(userProfile.name),
            subtitle: Text(userProfile.email),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () {
                // Logic to remove collaborator
              },
            ),
          );
        },
      ),
    );
  }
}
