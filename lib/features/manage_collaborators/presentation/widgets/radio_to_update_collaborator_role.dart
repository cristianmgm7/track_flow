import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_event.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';

class RadioToUpdateCollaboratorRole extends StatefulWidget {
  final ProjectId projectId;
  final UserId userId;
  final ProjectRoleType initialRole;
  final void Function(ProjectRole) onSave;

  const RadioToUpdateCollaboratorRole({
    super.key,
    required this.projectId,
    required this.userId,
    required this.initialRole,
    required this.onSave,
  });

  @override
  State<RadioToUpdateCollaboratorRole> createState() =>
      _RadioToUpdateCollaboratorRoleState();
}

class _RadioToUpdateCollaboratorRoleState
    extends State<RadioToUpdateCollaboratorRole> {
  late ProjectRoleType selectedRole;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.initialRole;
  }

  void _handleSave() {
    late ProjectRole newRole;
    switch (selectedRole) {
      case ProjectRoleType.owner:
        newRole = ProjectRole.owner;
        break;
      case ProjectRoleType.admin:
        newRole = ProjectRole.admin;
        break;
      case ProjectRoleType.editor:
        newRole = ProjectRole.editor;
        break;
      case ProjectRoleType.viewer:
        newRole = ProjectRole.viewer;
        break;
    }
    widget.onSave(newRole);
    context.read<ManageCollaboratorsBloc>().add(
      UpdateCollaboratorRole(
        projectId: widget.projectId,
        userId: widget.userId,
        newRole: newRole,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isChanged = selectedRole != widget.initialRole;
    // Filter assignable roles (without owner)
    final assignableRoles = ProjectRoleType.values.where(
      (role) => role != ProjectRoleType.owner,
    );

    // If the user is owner, only show message
    if (widget.initialRole == ProjectRoleType.owner) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.lock, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'the owner role cannot be changed from here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 0.2),
        ...assignableRoles.map(
          (role) => RadioListTile<ProjectRoleType>(
            title: Text(role.name),
            value: role,
            groupValue: selectedRole,
            onChanged: (value) {
              setState(() {
                selectedRole = value!;
              });
            },
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: isChanged ? _handleSave : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
