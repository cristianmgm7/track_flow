import 'package:flutter/material.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/ui/cards/base_card.dart';

class UploadTrackButton extends StatelessWidget {
  final ProjectId projectId;
  final VoidCallback? onTap;

  const UploadTrackButton({super.key, required this.projectId, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      backgroundColor: AppColors.background,
      onTap: onTap,
      margin: EdgeInsets.zero,
      borderRadius: BorderRadius.zero,
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.space16
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Upload icon instead of track cover art
          Container(
            width: Dimensions.avatarLarge,
            height: Dimensions.avatarLarge,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(128),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Icon(
              Icons.add,
              color: AppColors.onPrimary,
              size: Dimensions.iconLarge,
            ),
          ),
          SizedBox(width: Dimensions.space12),
          // Track info section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Upload Track',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Add an audio file to your project',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
