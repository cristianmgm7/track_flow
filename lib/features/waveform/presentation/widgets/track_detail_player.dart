import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_gradients.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/waveform/presentation/widgets/enhanced_waveform_display.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/waveform/presentation/widgets/audio_comment_controls.dart';

class TrackDetailPlayer extends StatelessWidget {
  final AudioTrack track;
  final TrackVersionId? versionId;

  const TrackDetailPlayer({super.key, required this.track, this.versionId});

  @override
  Widget build(BuildContext context) {

    // Determine which versionId to use
    final TrackVersionId? effectiveVersionId =
        versionId ?? track.activeVersionId;

    return SafeArea(
      top: true,
      bottom: false,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.overlay,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.screenMarginSmall,
          vertical: 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 96,
              child: EnhancedWaveformDisplay(
                track: track,
                versionId:
                    versionId, // ✅ Pass versionId for version-specific waveforms
                height: 96,
              ),
            ),
            const SizedBox(height: 8),
            AudioCommentControls(
              track: track,
              versionId: effectiveVersionId,
              buttonSize: Dimensions.buttonHeightSmall,
              iconSize: Dimensions.iconMedium,
            ),
          ],
        ),
      ),
    );
  }
}



