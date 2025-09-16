import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_state.dart';

class SearchErrorIndicator extends StatelessWidget {
  final ManageCollaboratorsState state;

  const SearchErrorIndicator({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is UserSearchError) {
      final errorState = state as UserSearchError;
      return Column(
        children: [
          SizedBox(height: Dimensions.space8),
          Container(
            padding: EdgeInsets.all(Dimensions.space8),
            decoration: BoxDecoration(
              color: _blendOnSurface(AppColors.error),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(color: AppColors.error),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: Dimensions.iconSmall,
                ),
                SizedBox(width: Dimensions.space8),
                Expanded(
                  child: Text(
                    errorState.message,
                    style: AppTextStyle.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
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
