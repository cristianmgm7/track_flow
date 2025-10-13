import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';

/// Dedicated widget for displaying audio comment timestamp badge
class AudioCommentTimestampBadge extends StatelessWidget {
  final String formattedTimestamp;

  const AudioCommentTimestampBadge({
    super.key,
    required this.formattedTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.space8,
          vertical: Dimensions.space4,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        child: Text(
          formattedTimestamp,
          style: AppTextStyle.labelSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
