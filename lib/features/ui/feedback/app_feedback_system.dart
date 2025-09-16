import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_borders.dart';
import '../../../core/theme/app_shadows.dart';

/// Unified Feedback System for TrackFlow
///
/// Provides consistent user feedback across the application
/// including toasts, snackbars, tooltips, and banners.
class AppFeedbackSystem {
  // Toast notifications
  static void showToast(
    BuildContext context, {
    required String message,
    FeedbackType type = FeedbackType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder:
          (context) => AppToast(
            message: message,
            type: type,
            duration: duration,
            onDismiss: () => overlayEntry.remove(),
          ),
    );
    overlay.insert(overlayEntry);
  }

  // SnackBar notifications
  static void showSnackBar(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    FeedbackType type = FeedbackType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      AppSnackBar(
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
        type: type,
        duration: duration,
      ),
    );
  }

  // Tooltip
  static void showTooltip(
    BuildContext context, {
    required String message,
    required Widget child,
    FeedbackType type = FeedbackType.info,
  }) {
    // Implementation for tooltip
  }

  // Banner
  static void showBanner(
    BuildContext context, {
    required String title,
    required String message,
    FeedbackType type = FeedbackType.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      AppBanner(
        title: title,
        message: message,
        type: type,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }
}

enum FeedbackType { success, error, warning, info }

/// Toast notification component
class AppToast extends StatefulWidget {
  final String message;
  final FeedbackType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const AppToast({
    super.key,
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<AppToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );

    _controller.forward();
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case FeedbackType.success:
        return AppColors.success;
      case FeedbackType.error:
        return AppColors.error;
      case FeedbackType.warning:
        return AppColors.warning;
      case FeedbackType.info:
        return AppColors.info;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case FeedbackType.success:
        return AppIcons.success;
      case FeedbackType.error:
        return AppIcons.error;
      case FeedbackType.warning:
        return AppIcons.warning;
      case FeedbackType.info:
        return AppIcons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + Dimensions.space16,
          left: Dimensions.space16,
          right: Dimensions.space16,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value * 100),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                padding: EdgeInsets.all(Dimensions.space16),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  borderRadius: AppBorders.medium,
                  boxShadow: AppShadows.medium,
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIcon(),
                      color: Colors.white,
                      size: AppIcons.sizeMedium,
                    ),
                    SizedBox(width: Dimensions.space12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: AppTextStyle.bodyMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        AppIcons.close,
                        color: Colors.white,
                        size: AppIcons.sizeSmall,
                      ),
                      onPressed: () {
                        _controller.reverse().then((_) => widget.onDismiss());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// SnackBar component
class AppSnackBar extends SnackBar {
  AppSnackBar({
    super.key,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    required FeedbackType type,
    Duration? duration,
  }) : super(
         content: Row(
           children: [
             Icon(
               _getIcon(type),
               color: Colors.white,
               size: AppIcons.sizeMedium,
             ),
             SizedBox(width: Dimensions.space12),
             Expanded(
               child: Text(
                 message,
                 style: AppTextStyle.bodyMedium.copyWith(color: Colors.white),
               ),
             ),
           ],
         ),
         backgroundColor: _getBackgroundColor(type),
         duration: duration ?? const Duration(seconds: 4),
         action:
             actionLabel != null && onAction != null
                 ? SnackBarAction(
                   label: actionLabel,
                   textColor: Colors.white,
                   onPressed: onAction,
                 )
                 : null,
         behavior: SnackBarBehavior.floating,
         shape: RoundedRectangleBorder(borderRadius: AppBorders.medium),
       );

  static Color _getBackgroundColor(FeedbackType type) {
    switch (type) {
      case FeedbackType.success:
        return AppColors.success;
      case FeedbackType.error:
        return AppColors.error;
      case FeedbackType.warning:
        return AppColors.warning;
      case FeedbackType.info:
        return AppColors.info;
    }
  }

  static IconData _getIcon(FeedbackType type) {
    switch (type) {
      case FeedbackType.success:
        return AppIcons.success;
      case FeedbackType.error:
        return AppIcons.error;
      case FeedbackType.warning:
        return AppIcons.warning;
      case FeedbackType.info:
        return AppIcons.info;
    }
  }
}

/// Banner component
class AppBanner extends MaterialBanner {
  AppBanner({
    super.key,
    required String title,
    required String message,
    required FeedbackType type,
    String? actionLabel,
    VoidCallback? onAction,
  }) : super(
         content: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           mainAxisSize: MainAxisSize.min,
           children: [
             Row(
               children: [
                 Icon(
                   _getIcon(type),
                   color: Colors.white,
                   size: AppIcons.sizeMedium,
                 ),
                 SizedBox(width: Dimensions.space12),
                 Expanded(
                   child: Text(
                     title,
                     style: AppTextStyle.titleMedium.copyWith(
                       color: Colors.white,
                     ),
                   ),
                 ),
               ],
             ),
             SizedBox(height: Dimensions.space8),
             Text(
               message,
               style: AppTextStyle.bodyMedium.copyWith(
                 color: Colors.white.withValues(alpha: 0.9),
               ),
             ),
           ],
         ),
         backgroundColor: _getBackgroundColor(type),
         actions:
             actionLabel != null && onAction != null
                 ? [
                   TextButton(
                     onPressed: onAction,
                     child: Text(
                       actionLabel,
                       style: AppTextStyle.labelMedium.copyWith(
                         color: Colors.white,
                       ),
                     ),
                   ),
                 ]
                 : [],
         leadingPadding: EdgeInsets.zero,
       );

  static Color _getBackgroundColor(FeedbackType type) {
    switch (type) {
      case FeedbackType.success:
        return AppColors.success;
      case FeedbackType.error:
        return AppColors.error;
      case FeedbackType.warning:
        return AppColors.warning;
      case FeedbackType.info:
        return AppColors.info;
    }
  }

  static IconData _getIcon(FeedbackType type) {
    switch (type) {
      case FeedbackType.success:
        return AppIcons.success;
      case FeedbackType.error:
        return AppIcons.error;
      case FeedbackType.warning:
        return AppIcons.warning;
      case FeedbackType.info:
        return AppIcons.info;
    }
  }
}
