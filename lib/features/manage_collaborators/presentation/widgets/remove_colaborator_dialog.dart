import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_event.dart';

class RemoveCollaboratorDialog extends StatelessWidget {
  final ProjectId projectId;
  final String collaboratorId;

  const RemoveCollaboratorDialog({
    super.key,
    required this.projectId,
    required this.collaboratorId,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Removal'),
      content: Text(
        'Are you sure you want to remove collaborator $collaboratorId?',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            context.read<ManageCollaboratorsBloc>().add(
              RemoveCollaborator(
                projectId: projectId,
                userId: UserId.fromUniqueString(collaboratorId),
              ),
            );
            Navigator.of(context).pop();
          },
          child: const Text('Yes'),
        ),
      ],
    );
  }
}
