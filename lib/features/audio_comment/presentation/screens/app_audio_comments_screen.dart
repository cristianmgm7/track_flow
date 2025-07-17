import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../ui/navigation/app_scaffold.dart';
import '../../../ui/navigation/app_bar.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../audio_track/domain/entities/audio_track.dart';
import '../components/audio_comment_header.dart';
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
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return AppScaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppAppBar(title: 'Comments'),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Header section with waveform, play controls, and time
                AudioCommentHeader(trackId: widget.track.id),

                // Comments list section
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.screenMarginSmall,
                    ),
                    child: CommentsSection(trackId: widget.track.id),
                  ),
                ),
                SizedBox(height: Dimensions.space32),
              ],
            ),

            // Input modal positioned at bottom, above keyboard
            Positioned(
              left: 0,
              right: 0,
              bottom: keyboardHeight,
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
}
