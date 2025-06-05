import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/entities/user_role.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_event.dart';

class AddCollaboratorDialog extends StatelessWidget {
  final ProjectId projectId;

  const AddCollaboratorDialog({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final TextEditingController userIdController = TextEditingController();

    return AlertDialog(
      title: const Text('Add Collaborator'),
      content: TextField(
        controller: userIdController,
        decoration: const InputDecoration(hintText: "Enter User ID"),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Add'),
          onPressed: () {
            final collaboratorId = UserId.fromUniqueString(
              userIdController.text,
            );
            context.read<ManageCollaboratorsBloc>().add(
              AddCollaborator(
                projectId: projectId,
                collaboratorId: collaboratorId,
                role: UserRole.member,
              ),
            );
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
