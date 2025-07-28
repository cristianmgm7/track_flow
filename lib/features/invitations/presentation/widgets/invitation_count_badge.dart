import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';

/// Badge widget to display invitation count
class InvitationCountBadge extends StatelessWidget {
  final int count;
  final double? size;
  final Color? backgroundColor;
  final Color? textColor;

  const InvitationCountBadge({
    super.key,
    required this.count,
    this.size,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      width: size ?? Dimensions.space20,
      height: size ?? Dimensions.space20,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.warning,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: AppTextStyle.caption.copyWith(
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: count > 99 ? 8 : 10,
          ),
        ),
      ),
    );
  }
}

/// Notification count badge for core notifications
class NotificationCountBadge extends StatelessWidget {
  final int count;
  final double? size;
  final Color? backgroundColor;
  final Color? textColor;

  const NotificationCountBadge({
    super.key,
    required this.count,
    this.size,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      width: size ?? Dimensions.space20,
      height: size ?? Dimensions.space20,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.error,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: AppTextStyle.caption.copyWith(
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: count > 99 ? 8 : 10,
          ),
        ),
      ),
    );
  }
}
