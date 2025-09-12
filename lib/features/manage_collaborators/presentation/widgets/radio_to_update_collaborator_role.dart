import 'package:flutter/material.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_event.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';
import 'package:trackflow/features/ui/buttons/secondary_button.dart';
import 'package:trackflow/features/manage_collaborators/presentation/widgets/role_option_tile.dart';

class RadioToUpdateCollaboratorRole extends StatefulWidget {
  final ProjectId projectId;
  final UserId userId;
  final ProjectRoleType initialRole;
  final void Function(ProjectRole) onSave;
  final ManageCollaboratorsBloc manageCollaboratorsBloc;

  const RadioToUpdateCollaboratorRole({
    super.key,
    required this.projectId,
    required this.userId,
    required this.initialRole,
    required this.onSave,
    required this.manageCollaboratorsBloc,
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
    widget.manageCollaboratorsBloc.add(
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
        padding: EdgeInsets.all(Dimensions.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock,
              size: Dimensions.iconLarge,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: Dimensions.space16),
            Text(
              'The owner role cannot be changed from here.',
              textAlign: TextAlign.center,
              style: AppTextStyle.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: Dimensions.space24),
            SecondaryButton(
              text: 'Close',
              onPressed: () => Navigator.of(context).pop(),
              size: ButtonSize.medium,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(Dimensions.space16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Update Collaborator Role',
            style: AppTextStyle.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: Dimensions.space8),
          Text(
            'Select a new role for this collaborator',
            style: AppTextStyle.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: Dimensions.space24),
          ...assignableRoles.map(
            (role) => RoleOptionTile(
              role: role,
              selectedRole: selectedRole,
              onRoleSelected: (selectedRole) {
                setState(() {
                  this.selectedRole = selectedRole;
                });
              },
            ),
          ),
          SizedBox(height: Dimensions.space24),
          Center(
            child: PrimaryButton(
              text: 'Save Changes',
              onPressed: isChanged ? _handleSave : null,
              isDisabled: !isChanged,
              size: ButtonSize.medium,
            ),
          ),
        ],
      ),
    );
  }
}
