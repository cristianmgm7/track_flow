import 'package:flutter/material.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/waveform/presentation/widgets/enhanced_waveform_display.dart';

class AudioCommentWaveformDisplay extends StatelessWidget {
  final AudioTrackId trackId;

  const AudioCommentWaveformDisplay({
    super.key, 
    required this.trackId,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedWaveformDisplay(trackId: trackId);
  }
}
