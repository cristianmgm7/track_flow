import 'package:flutter/material.dart';

class VoiceMemoProgressBar extends StatelessWidget {
  final Duration position;
  final Duration totalDuration;

  const VoiceMemoProgressBar({
    super.key,
    required this.position,
    required this.totalDuration,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalDuration.inMilliseconds > 0
        ? position.inMilliseconds / totalDuration.inMilliseconds
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Background bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Progress bar
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Playhead circle
            if (progress > 0)
              Positioned(
                left: (progress * maxWidth).clamp(0.0, maxWidth - 12),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
