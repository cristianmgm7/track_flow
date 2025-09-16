import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_borders.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_shadows.dart';
import 'package:trackflow/core/theme/app_text_style.dart';

class AppTrackList extends StatelessWidget {
  final List<Widget> tracks;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  const AppTrackList({
    super.key,
    required this.tracks,
    this.padding,
    this.shrinkWrap = false,
    this.controller,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding ?? EdgeInsets.zero,
      children: tracks,
    );
  }
}

class AppTrackEmptyState extends StatelessWidget {
  final String message;
  final String? subtitle;
  final Widget? icon;
  final VoidCallback? onAction;
  final String? actionText;

  const AppTrackEmptyState({
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

class AppTrackLoadingState extends StatelessWidget {
  final int itemCount;

  const AppTrackLoadingState({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(Dimensions.space16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return AppTrackShimmerCard();
      },
    );
  }
}

class AppTrackShimmerCard extends StatelessWidget {
  const AppTrackShimmerCard({super.key});

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
      child: Row(
        children: [
          Container(
            width: Dimensions.avatarLarge,
            height: Dimensions.avatarLarge,
            decoration: BoxDecoration(
              color: AppColors.grey600,
              borderRadius: AppBorders.small,
            ),
          ),
          SizedBox(width: Dimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.grey600,
                    borderRadius: AppBorders.small,
                  ),
                ),
                SizedBox(height: Dimensions.space4),
                Container(
                  height: 12,
                  width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                    color: AppColors.grey600,
                    borderRadius: AppBorders.small,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: Dimensions.space8),
          Container(
            height: 12,
            width: 30,
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
