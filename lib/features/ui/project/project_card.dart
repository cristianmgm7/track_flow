import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_borders.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_shadows.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/ui/cards/base_card.dart';

class AppProjectCard extends StatelessWidget {
  final String title;
  final String? description;
  final DateTime createdAt;
  final VoidCallback onTap;
  final Widget? trailing;
  final Widget? leading;
  final List<Widget>? actions;

  const AppProjectCard({
    super.key,
    required this.title,
    this.description,
    required this.createdAt,
    required this.onTap,
    this.trailing,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      onTap: onTap,
      margin: EdgeInsets.zero,
      borderRadius: BorderRadius.zero,
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.space16,
        vertical: Dimensions.space8,
      ),
      child: Row(
        children: [
          // Cover art on the left
          if (leading != null) ...[
            leading!,
            SizedBox(width: Dimensions.space12),
          ],
          // Content stacked vertically on the right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyle.titleMedium.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Dimensions.space2),
                Text(
                  description?.isNotEmpty == true
                      ? description!
                      : 'Project • ${_getFormattedDuration(createdAt)} ago',
                  style: AppTextStyle.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Trailing actions/icons on the far right
          if (trailing != null) ...[
            SizedBox(width: Dimensions.space8),
            trailing!,
          ],
          if (actions != null) ...[
            SizedBox(width: Dimensions.space8),
            Row(mainAxisSize: MainAxisSize.min, children: actions!),
          ],
        ],
      ),
    );
  }

  String _getFormattedDuration(DateTime createdAt) {
    final duration = DateTime.now().difference(createdAt);
    if (duration.inDays > 0) {
      return '${duration.inDays}d';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return 'just now';
    }
  }
}

class AppProjectList extends StatelessWidget {
  final List<Widget> projects;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollController? controller;

  const AppProjectList({
    super.key,
    required this.projects,
    this.padding,
    this.shrinkWrap = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      shrinkWrap: shrinkWrap,
      padding: padding ?? EdgeInsets.zero,
      children: projects,
    );
  }
}

class AppProjectEmptyState extends StatelessWidget {
  final String message;
  final String? subtitle;
  final Widget? icon;
  final VoidCallback? onAction;
  final String? actionText;

  const AppProjectEmptyState({
    super.key,
    required this.message,
    this.subtitle,
    this.icon,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Dimensions.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, SizedBox(height: Dimensions.space24)],
            Text(
              message,
              style: AppTextStyle.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: Dimensions.space8),
              Text(
                subtitle!,
                style: AppTextStyle.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionText != null) ...[
              SizedBox(height: Dimensions.space24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.space24,
                    vertical: Dimensions.space12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorders.medium,
                  ),
                ),
                child: Text(
                  actionText!,
                  style: AppTextStyle.labelLarge.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppProjectLoadingState extends StatelessWidget {
  final int itemCount;

  const AppProjectLoadingState({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(Dimensions.space16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return _ProjectShimmerCard();
      },
    );
  }
}

class _ProjectShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.space16),
      padding: EdgeInsets.all(Dimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorders.medium,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.grey600,
              borderRadius: AppBorders.small,
            ),
          ),
          SizedBox(height: Dimensions.space8),
          Container(
            height: 16,
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              color: AppColors.grey600,
              borderRadius: AppBorders.small,
            ),
          ),
          SizedBox(height: Dimensions.space12),
          Container(
            height: 12,
            width: MediaQuery.of(context).size.width * 0.4,
            decoration: BoxDecoration(
              color: AppColors.grey600,
              borderRadius: AppBorders.small,
            ),
          ),
        ],
      ),
    );
  }
}

class AppProjectErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryText;

  const AppProjectErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Dimensions.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: Dimensions.iconXLarge,
              color: AppColors.error,
            ),
            SizedBox(height: Dimensions.space16),
            Text(
              message,
              style: AppTextStyle.headlineSmall.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: Dimensions.space24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.onPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.space24,
                    vertical: Dimensions.space12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorders.medium,
                  ),
                ),
                child: Text(
                  retryText ?? 'Retry',
                  style: AppTextStyle.labelLarge.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppProjectSuccessState extends StatelessWidget {
  final String message;
  final VoidCallback? onContinue;
  final String? continueText;

  const AppProjectSuccessState({
    super.key,
    required this.message,
    this.onContinue,
    this.continueText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Dimensions.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: Dimensions.iconXLarge,
              color: AppColors.success,
            ),
            SizedBox(height: Dimensions.space16),
            Text(
              message,
              style: AppTextStyle.headlineSmall.copyWith(
                color: AppColors.success,
              ),
              textAlign: TextAlign.center,
            ),
            if (onContinue != null) ...[
              SizedBox(height: Dimensions.space24),
              ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.onPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.space24,
                    vertical: Dimensions.space12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorders.medium,
                  ),
                ),
                child: Text(
                  continueText ?? 'Continue',
                  style: AppTextStyle.labelLarge.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
