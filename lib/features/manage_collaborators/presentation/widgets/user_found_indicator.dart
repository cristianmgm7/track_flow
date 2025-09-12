import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_state.dart';

class UserFoundIndicator extends StatelessWidget {
  final ManageCollaboratorsState state;

  const UserFoundIndicator({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is UserSearchSuccess &&
        (state as UserSearchSuccess).user != null) {
      final user = (state as UserSearchSuccess).user!;
      return Column(
        children: [
          SizedBox(height: Dimensions.space12),
          Container(
            padding: EdgeInsets.all(Dimensions.space12),
            decoration: BoxDecoration(
              color: _blendOnSurface(AppColors.success),
              borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
              border: Border.all(color: AppColors.success),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: AppTextStyle.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
                SizedBox(width: Dimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: AppTextStyle.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        user.email,
                        style: AppTextStyle.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Existing user found',
                        style: AppTextStyle.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Color _blendOnSurface(Color base, {double opacity = 0.12}) {
    final overlay = base.withAlpha((opacity * 255).round());
    return Color.alphaBlend(overlay, AppColors.surface);
  }
}
