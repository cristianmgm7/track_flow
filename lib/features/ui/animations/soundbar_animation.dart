import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';

class SoundbarAnimation extends StatefulWidget {
  final bool isPlaying;
  final double size;
  final Color? color;

  const SoundbarAnimation({
    super.key,
    required this.isPlaying,
    this.size = 12.0,
    this.color,
  });

  @override
  State<SoundbarAnimation> createState() => _SoundbarAnimationState();
}

class _SoundbarAnimationState extends State<SoundbarAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: Duration(milliseconds: 300 + (index * 100)),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.3,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();

    if (widget.isPlaying) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted && widget.isPlaying) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopAnimation() {
    for (final controller in _controllers) {
      controller.stop();
      controller.reset();
    }
  }

  @override
  void didUpdateWidget(SoundbarAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barColor = widget.color ?? AppColors.primary;
    final barWidth = widget.size / 6;
    final barHeight = widget.size;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              final animationValue = widget.isPlaying 
                  ? _animations[index].value 
                  : 0.3;
              
              return Container(
                width: barWidth,
                height: barHeight * animationValue,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(barWidth / 2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}