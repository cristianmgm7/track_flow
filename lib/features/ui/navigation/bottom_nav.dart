import 'package:flutter/material.dart';
import 'dart:ui';
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      decoration: BoxDecoration(
        boxShadow:
            showShadow
                ? [
                  BoxShadow(
                    color: AppColors.grey900.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ]
                : null,
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
          child: Container(
            height: 90 + bottomPadding, // Add bottom padding to height
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surface.withValues(alpha: 0.8),
                  AppColors.background.withValues(alpha: 0.9),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: AppColors.textPrimary.withValues(alpha: 0.05),
                  width: 0.5,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: Dimensions.space8,
                right: Dimensions.space8,
                top: Dimensions.space4,
                bottom: Dimensions.space4 + bottomPadding,
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
                            selectedItemColor:
                                selectedItemColor ?? AppColors.primary,
                            unselectedItemColor:
                                unselectedItemColor ?? AppColors.textSecondary,
                            showLabel: showLabels,
                          ),
                        );
                      }).toList(),
                ),
            ),
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
    with TickerProviderStateMixin {
  late AnimationController _tapAnimationController;
  late AnimationController _selectionAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _backgroundOpacityAnimation;
  late Animation<double> _selectionAnimation;

  @override
  void initState() {
    super.initState();

    // Tap animation controller
    _tapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    // Selection animation controller
    _selectionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _tapAnimationController, curve: Curves.easeInOut),
    );

    _backgroundOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _selectionAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _selectionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _selectionAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Initialize selection state
    if (widget.isSelected) {
      _selectionAnimationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AppBottomNavigationItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _selectionAnimationController.forward();
      } else {
        _selectionAnimationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _tapAnimationController.dispose();
    _selectionAnimationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _tapAnimationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _tapAnimationController.reverse();
  }

  void _onTapCancel() {
    _tapAnimationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _tapAnimationController,
        _selectionAnimationController,
      ]),
      builder: (context, child) {
        final selectedColor = widget.selectedItemColor;
        final unselectedColor = widget.unselectedItemColor;

        // Interpolate colors based on selection state
        final iconColor =
            Color.lerp(
              unselectedColor,
              selectedColor,
              _selectionAnimation.value,
            )!;

        final textColor =
            Color.lerp(
              unselectedColor,
              selectedColor,
              _selectionAnimation.value,
            )!;

        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.space12,
                vertical: Dimensions.space8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with selection background
                  Container(
                    padding: EdgeInsets.all(Dimensions.space6),
                    decoration: BoxDecoration(
                      color:
                          widget.isSelected
                              ? selectedColor.withValues(
                                alpha: 0.1 * _backgroundOpacityAnimation.value,
                              )
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusLarge,
                      ),
                    ),
                    child: Stack(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (
                            Widget child,
                            Animation<double> animation,
                          ) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: Icon(
                            widget.isSelected && widget.item.activeIcon != null
                                ? widget.item.activeIcon!
                                : widget.item.icon,
                            key: ValueKey(widget.isSelected),
                            size: 26, // Slightly larger for iOS feel
                            color: iconColor,
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
                  ),

                  // Label
                  if (widget.showLabel) ...[
                    SizedBox(height: Dimensions.space4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: AppTextStyle.caption.copyWith(
                        color: textColor,
                        fontWeight:
                            widget.isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                        fontSize: 11, // Slightly smaller for iOS feel
                      ),
                      child: Text(
                        widget.item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
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
