import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';

class RoleOptionTile extends StatelessWidget {
  final ProjectRoleType role;
  final ProjectRoleType selectedRole;
  final ValueChanged<ProjectRoleType> onRoleSelected;

  const RoleOptionTile({
    super.key,
    required this.role,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  String _getRoleDisplayName(ProjectRoleType role) {
    switch (role) {
      case ProjectRoleType.owner:
        return 'Owner';
      case ProjectRoleType.admin:
        return 'Admin';
      case ProjectRoleType.editor:
        return 'Editor';
      case ProjectRoleType.viewer:
        return 'Viewer';
    }
  }

  String _getRoleDescription(ProjectRoleType role) {
    switch (role) {
      case ProjectRoleType.owner:
        return 'Full access to all project operations';
      case ProjectRoleType.admin:
        return 'Can manage collaborators and project settings';
      case ProjectRoleType.editor:
        return 'Can edit tracks and add comments';
      case ProjectRoleType.viewer:
        return 'Read-only access to the project';
    }
  }

  IconData _getRoleIcon(ProjectRoleType role) {
    switch (role) {
      case ProjectRoleType.owner:
        return Icons.admin_panel_settings;
      case ProjectRoleType.admin:
        return Icons.manage_accounts;
      case ProjectRoleType.editor:
        return Icons.edit;
      case ProjectRoleType.viewer:
        return Icons.visibility;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedRole == role;

    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.space8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
          onTap: () => onRoleSelected(role),
          child: Container(
            padding: EdgeInsets.all(Dimensions.space16),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surface,
              borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: Dimensions.iconMedium,
                  height: Dimensions.iconMedium,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getRoleIcon(role),
                    size: Dimensions.iconSmall,
                    color:
                        isSelected
                            ? AppColors.onPrimary
                            : AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: Dimensions.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getRoleDisplayName(role),
                        style: AppTextStyle.bodyLarge.copyWith(
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: Dimensions.space4),
                      Text(
                        _getRoleDescription(role),
                        style: AppTextStyle.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: Dimensions.iconMedium,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
