import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_animations.dart';
import 'package:trackflow/core/theme/app_borders.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_shadows.dart';

class BaseCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final bool enableHover;
  final bool enableTapAnimation;

  const BaseCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.enableHover = true,
    this.enableTapAnimation = true,
  });

  @override
  State<BaseCard> createState() => _BaseCardState();
}

class _BaseCardState extends State<BaseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
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
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.enableTapAnimation || widget.onTap == null) return;
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.enableTapAnimation || widget.onTap == null) return;
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    if (!widget.enableTapAnimation || widget.onTap == null) return;
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onHover(bool hovering) {
    if (!widget.enableHover) return;
    setState(() => _isHovered = hovering);
  }

  List<BoxShadow> get _currentShadow {
    if (widget.boxShadow != null) return widget.boxShadow!;
    
    if (_isHovered && widget.onTap != null) {
      return AppShadows.cardHover;
    }
    return AppShadows.card;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPressed ? _scaleAnimation.value : AppAnimations.scaleNormal,
          child: Container(
            width: widget.width,
            height: widget.height,
            margin: widget.margin ?? EdgeInsets.all(Dimensions.cardMargin),
            child: MouseRegion(
              onEnter: (_) => _onHover(true),
              onExit: (_) => _onHover(false),
              child: GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: AppAnimations.fast,
                  constraints: BoxConstraints(
                    minHeight: Dimensions.cardMinHeight,
                  ),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? AppColors.surface,
                    borderRadius: widget.borderRadius ?? AppBorders.medium,
                    boxShadow: _currentShadow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: widget.borderRadius ?? AppBorders.medium,
                      onTap: widget.onTap,
                      child: Container(
                        padding: widget.padding ?? EdgeInsets.all(Dimensions.cardPadding),
                        child: widget.child,
                      ),
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