import 'package:flutter/material.dart';

/// Handles all animation logic for track cache icons
class TrackCacheAnimationHandler {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;

  TrackCacheAnimationHandler({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    _animationController = AnimationController(
      duration: duration,
      vsync: vsync,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  /// Trigger tap animation with forward and reverse
  Future<void> animateTap() async {
    await _animationController.forward();
    _animationController.reverse();
  }

  /// Build animated widget wrapper
  Widget buildAnimatedWidget({
    required Widget child,
    required AnimationController controller,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: child,
          ),
        );
      },
    );
  }

  /// Get the animation controller
  AnimationController get controller => _animationController;

  /// Dispose resources
  void dispose() {
    _animationController.dispose();
  }
}