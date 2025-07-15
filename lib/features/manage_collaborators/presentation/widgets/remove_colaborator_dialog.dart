import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_event.dart';
import 'package:trackflow/features/ui/dialogs/app_dialog.dart';

class RemoveCollaboratorDialog extends StatelessWidget {
  final ProjectId projectId;
  final String collaboratorId;
  final String collaboratorName;

  const RemoveCollaboratorDialog({
    super.key,
    required this.projectId,
    required this.collaboratorId,
    required this.collaboratorName,
  });

  @override
  Widget build(BuildContext context) {
    return AppConfirmationDialog(
      title: 'Confirm Removal',
      message:
          'Are you sure you want to remove collaborator $collaboratorName?',
      confirmText: 'Yes',
      cancelText: 'Cancel',
      isDestructive: true,
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: () {
        context.read<ManageCollaboratorsBloc>().add(
          RemoveCollaborator(
            projectId: projectId,
            userId: UserId.fromUniqueString(collaboratorId),
          ),
        );
        Navigator.of(context).pop();
      },
    );
  }
}
