import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef PositionFromX = Duration Function(double localX, double width);

/// Gesture layer that translates user input into positions. No painting here.
class WaveformGestures extends StatelessWidget {
  final PositionFromX positionFromX;
  final VoidCallback onScrubStarted;
  final ValueChanged<Duration> onScrubUpdated;
  final VoidCallback onScrubCancelled;
  final ValueChanged<Duration> onScrubCommitted;

  const WaveformGestures({
    super.key,
    required this.positionFromX,
    required this.onScrubStarted,
    required this.onScrubUpdated,
    required this.onScrubCancelled,
    required this.onScrubCommitted,
  });

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        PanGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
              () => PanGestureRecognizer(),
              (PanGestureRecognizer instance) {
                Duration? _lastPreview;
                instance
                  ..onStart = (details) {
                    onScrubStarted();
                  }
                  ..onUpdate = (details) {
                    final box = context.findRenderObject() as RenderBox?;
                    if (box == null) return;
                    final local = box.globalToLocal(details.globalPosition);
                    final pos = positionFromX(local.dx, box.size.width);
                    _lastPreview = pos;
                    onScrubUpdated(pos);
                  }
                  ..onEnd = (details) {
                    if (_lastPreview != null) {
                      onScrubCommitted(_lastPreview!);
                    } else {
                      onScrubCancelled();
                    }
                  };
              },
            ),
        TapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
              () => TapGestureRecognizer(),
              (TapGestureRecognizer instance) {
                instance.onTapUp = (details) {
                  final box = context.findRenderObject() as RenderBox?;
                  if (box == null) return;
                  final local = box.globalToLocal(details.globalPosition);
                  final pos = positionFromX(local.dx, box.size.width);
                  onScrubCommitted(pos);
                };
              },
            ),
      },
      behavior: HitTestBehavior.opaque, // widen hit target
      child: const SizedBox.expand(),
    );
  }
}
