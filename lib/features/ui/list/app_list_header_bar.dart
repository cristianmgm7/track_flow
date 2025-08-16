import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_borders.dart';
import 'package:trackflow/core/theme/app_text_style.dart';

/// Compact list header bar to show selected filter/sort and an action on the right.
class AppListHeaderBar extends StatelessWidget {
  final String leadingText; // e.g., "Sort: Last activity • 12"
  final Widget? trailing; // e.g., popup menu trigger

  const AppListHeaderBar({super.key, required this.leadingText, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.space12,
          vertical: Dimensions.space6,
        ),
        child: Row(
          children: [
            // Leading container (text/info)
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  left: Dimensions.space6,
                  right: Dimensions.space12,
                  top: Dimensions.space8,
                  bottom: Dimensions.space8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppBorders.medium,
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Text(
                  leadingText,
                  style: AppTextStyle.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(width: Dimensions.space12),
            // Trailing container (icon/action)
            if (trailing != null)
              Container(
                width: Dimensions.space40,
                height: Dimensions.space40,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppBorders.medium,
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Center(child: trailing!),
              ),
          ],
        ),
      ),
    );
  }
}
