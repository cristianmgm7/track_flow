import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';

/// Dedicated widget for displaying audio comment header with user name and creation date
class AudioCommentHeader extends StatelessWidget {
  final String displayName;
  final String formattedDate;

  const AudioCommentHeader({
    super.key,
    required this.displayName,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(

      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            displayName,
            style: AppTextStyle.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: Dimensions.space8),
        Text(
          formattedDate,
          style: AppTextStyle.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}
