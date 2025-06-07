import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_event.dart';

class AddCollaboratorDialog extends StatelessWidget {
  final Project project;

  const AddCollaboratorDialog({super.key, required this.project});

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
            context.read<ManageCollaboratorsBloc>().add(
              AddCollaborator(
                projectId: project.id,
                collaboratorId: UserId.fromUniqueString(userIdController.text),
              ),
            );
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
