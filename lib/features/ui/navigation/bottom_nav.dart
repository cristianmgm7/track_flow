import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:trackflow/core/theme/app_animations.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavigationItem> items;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final bool showLabels;
  final bool showShadow;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.showLabels = true,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          height: Dimensions.bottomNavHeight,
          decoration: BoxDecoration(
            color: (backgroundColor ?? AppColors.surface).withValues(
              alpha: 0.1,
            ),
            border: Border(
              top: BorderSide(
                color: AppColors.textPrimary.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            boxShadow:
                showShadow
                    ? [
                      BoxShadow(
                        color: AppColors.grey900.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            children:
                items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == currentIndex;

                  return Expanded(
                    child: _AppBottomNavigationItemWidget(
                      item: item,
                      isSelected: isSelected,
                      onTap: () => onTap(index),
                      selectedItemColor: selectedItemColor ?? AppColors.primary,
                      unselectedItemColor:
                          unselectedItemColor ?? AppColors.textSecondary,
                      showLabel: showLabels,
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}

class AppBottomNavigationItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final Widget? badge;

  const AppBottomNavigationItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.badge,
  });
}

class _AppBottomNavigationItemWidget extends StatefulWidget {
  final AppBottomNavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedItemColor;
  final Color unselectedItemColor;
  final bool showLabel;

  const _AppBottomNavigationItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.selectedItemColor,
    required this.unselectedItemColor,
    required this.showLabel,
  });

  @override
  State<_AppBottomNavigationItemWidget> createState() =>
      _AppBottomNavigationItemWidgetState();
}

class _AppBottomNavigationItemWidgetState
    extends State<_AppBottomNavigationItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: AppAnimations.scaleNormal,
      end: AppAnimations.scaleDown,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.isSelected
            ? widget.selectedItemColor
            : widget.unselectedItemColor;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPressed ? _scaleAnimation.value : AppAnimations.scaleNormal,
          child: Opacity(
            opacity: _isPressed ? _opacityAnimation.value : 1.0,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: widget.onTap,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.space8,
                      vertical: Dimensions.space8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            AnimatedSwitcher(
                              duration: AppAnimations.fast,
                              child: Icon(
                                widget.isSelected &&
                                        widget.item.activeIcon != null
                                    ? widget.item.activeIcon!
                                    : widget.item.icon,
                                key: ValueKey(widget.isSelected),
                                size: Dimensions.iconMedium,
                                color: color,
                              ),
                            ),
                            if (widget.item.badge != null)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: widget.item.badge!,
                              ),
                          ],
                        ),
                        if (widget.showLabel) ...[
                          SizedBox(height: Dimensions.space4),
                          AnimatedDefaultTextStyle(
                            duration: AppAnimations.fast,
                            style: AppTextStyle.caption.copyWith(
                              color: color,
                              fontWeight:
                                  widget.isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                            ),
                            child: Text(
                              widget.item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AppBadge extends StatelessWidget {
  final int? count;
  final bool showDot;
  final Color? backgroundColor;
  final Color? textColor;

  const AppBadge({
    super.key,
    this.count,
    this.showDot = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!showDot && (count == null || count! <= 0)) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: BoxConstraints(
        minWidth: showDot ? 8 : 16,
        minHeight: showDot ? 8 : 16,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.error,
        borderRadius: BorderRadius.circular(showDot ? 4 : 8),
      ),
      child:
          showDot
              ? null
              : Center(
                child: Text(
                  count! > 99 ? '99+' : count.toString(),
                  style: AppTextStyle.caption.copyWith(
                    color: textColor ?? AppColors.onPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
    );
  }
}
