import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/theme/app_borders.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class CreativeRoleSelector extends StatelessWidget {
  final CreativeRole selectedRole;
  final ValueChanged<CreativeRole> onRoleChanged;

  const CreativeRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Creative Role',
          style: AppTextStyle.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Dimensions.space8),
        Text(
          'Select the role that best describes your primary expertise',
          style: AppTextStyle.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: Dimensions.space12),
        Wrap(
          spacing: Dimensions.space8,
          runSpacing: Dimensions.space8,
          children: CreativeRole.values.map((role) {
            final isSelected = selectedRole == role;
            return _RoleChip(
              role: role,
              isSelected: isSelected,
              onTap: () => onRoleChanged(role),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  final CreativeRole role;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  String _getRoleDisplayName(CreativeRole role) {
    return switch (role) {
      CreativeRole.producer => 'Producer',
      CreativeRole.composer => 'Composer',
      CreativeRole.mixingEngineer => 'Mixing Engineer',
      CreativeRole.masteringEngineer => 'Mastering Engineer',
      CreativeRole.vocalist => 'Vocalist',
      CreativeRole.instrumentalist => 'Instrumentalist',
      CreativeRole.other => 'Other',
    };
  }

  IconData _getRoleIcon(CreativeRole role) {
    return switch (role) {
      CreativeRole.producer => Icons.play_arrow,
      CreativeRole.composer => Icons.music_note,
      CreativeRole.mixingEngineer => Icons.equalizer,
      CreativeRole.masteringEngineer => Icons.tune,
      CreativeRole.vocalist => Icons.mic,
      CreativeRole.instrumentalist => Icons.piano,
      CreativeRole.other => Icons.more_horiz,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.medium,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
            borderRadius: AppBorders.medium,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.space12,
              vertical: Dimensions.space8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getRoleIcon(role),
                  size: Dimensions.iconSmall,
                  color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
                ),
                SizedBox(width: Dimensions.space6),
                Text(
                  _getRoleDisplayName(role),
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}