import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../ui/navigation/app_scaffold.dart';
import '../../../ui/navigation/app_bar.dart';
import '../../../../core/entities/unique_id.dart';
import '../components/header/audio_comment_header.dart';
import '../components/header/waveform.dart';
import '../../../audio_track/domain/entities/audio_track.dart';
import '../components/comments_section.dart';
import '../components/comment_input_modal.dart';

/// Arguments for the audio comments screen
class AudioCommentsScreenArgs {
  final ProjectId projectId;
  final AudioTrack track;

  AudioCommentsScreenArgs({required this.projectId, required this.track});
}

/// Audio comments screen following TrackFlow design system
/// Replaces hardcoded values with design system constants
class AppAudioCommentsScreen extends StatefulWidget {
  final ProjectId projectId;
  final AudioTrack track;

  const AppAudioCommentsScreen({
    super.key,
    required this.projectId,
    required this.track,
  });

  @override
  State<AppAudioCommentsScreen> createState() => _AppAudioCommentsScreenState();
}

class _AppAudioCommentsScreenState extends State<AppAudioCommentsScreen> {


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppAppBar(title: 'Comments'),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Waveform header
                _buildWaveformHeader(),

                // Comments list
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.screenMarginSmall,
                    ),
                    child: CommentsSection(trackId: widget.track.id),
                  ),
                ),

                // Space for input when visible
                SizedBox(height: Dimensions.space80),
              ],
            ),

            // Floating comment input
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CommentInputModal(
                projectId: widget.projectId,
                trackId: widget.track.id,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveformHeader() {
    return Container(
      margin: EdgeInsets.all(Dimensions.screenMarginSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: AppBorders.large,
        boxShadow: AppShadows.medium,
        border: AppBorders.subtleBorder(context),
      ),
      child: ClipRRect(
        borderRadius: AppBorders.large,
        child: AudioCommentHeader(
          waveform: AudioCommentWaveformDisplay(trackId: widget.track.id),
          trackId: widget.track.id,
        ),
      ),
    );
  }

}
