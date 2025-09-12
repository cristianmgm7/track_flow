import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_state.dart';

class NewUserIndicator extends StatelessWidget {
  final String email;
  final ManageCollaboratorsState state;

  const NewUserIndicator({super.key, required this.email, required this.state});

  @override
  Widget build(BuildContext context) {
    if (email.isNotEmpty &&
        state is UserSearchSuccess &&
        (state as UserSearchSuccess).user == null) {
      return Column(
        children: [
          SizedBox(height: Dimensions.space12),
          Container(
            padding: EdgeInsets.all(Dimensions.space12),
            decoration: BoxDecoration(
              color: _blendOnSurface(AppColors.info),
              borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
              border: Border.all(color: AppColors.info),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_add,
                  color: AppColors.info,
                  size: Dimensions.iconMedium,
                ),
                SizedBox(width: Dimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New user',
                        style: AppTextStyle.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                      Text(
                        'Is going to be sent a magic link to register',
                        style: AppTextStyle.bodySmall.copyWith(
                          color: AppColors.textSecondary,
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
