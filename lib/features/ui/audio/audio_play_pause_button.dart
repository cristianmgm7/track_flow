import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_animations.dart';
import 'package:trackflow/core/theme/app_borders.dart';
import 'package:trackflow/core/theme/app_shadows.dart';

/// A circular play/pause button for audio controls, supporting loading/buffering state.
///
/// - [isPlaying]: Whether audio is currently playing.
/// - [isBuffering]: Whether audio is buffering/loading.
/// - [onPressed]: Callback for play/pause toggle.
/// - [size]: Diameter of the button.
/// - [iconSize]: Size of the play/pause icon.
/// - [backgroundColor]: Button background color.
/// - [iconColor]: Icon color.
class AudioPlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final bool isBuffering;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;

  const AudioPlayPauseButton({
    super.key,
    required this.isPlaying,
    required this.isBuffering,
    required this.onPressed,
    this.size = 56.0,
    this.iconSize = 32.0,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = backgroundColor ?? AppColors.primary;
    final Color fg = iconColor ?? AppColors.onPrimary;

    return AnimatedContainer(
      duration: AppAnimations.fast,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: AppShadows.button,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: isBuffering ? null : onPressed,
          child: Center(
            child:
                isBuffering
                    ? SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(fg),
                      ),
                    )
                    : Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: iconSize,
                      color: fg,
                    ),
          ),
        ),
      ),
    );
  }
}
