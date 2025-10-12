
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PulsingCircleAnimator extends StatefulWidget {
  final double amplitude; // 0.0 to 1.0
  final bool isRecording;

  const PulsingCircleAnimator({
    super.key,
    required this.amplitude,
    required this.isRecording,
  });

  @override
  State<PulsingCircleAnimator> createState() => _PulsingCircleAnimatorState();
}

class _PulsingCircleAnimatorState extends State<PulsingCircleAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scale based on amplitude (0.8 to 1.2 range)
    final amplitudeScale = 0.8 + (widget.amplitude * 0.4);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final totalScale = widget.isRecording
            ? _animation.value * amplitudeScale
            : 1.0;

        return Transform.scale(
          scale: totalScale,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(0.8),
                  AppColors.primary.withOpacity(0.4),
                  AppColors.primary.withOpacity(0.1),
                ],
                stops: const [0.3, 0.6, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                widget.isRecording ? Icons.mic : Icons.pause,
                size: 80,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        );
      },
    );
  }
}
