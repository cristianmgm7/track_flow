import 'package:flutter/material.dart';
import 'package:trackflow/features/ui/navigation/app_bar.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../ui/navigation/app_scaffold.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../audio_track/domain/entities/audio_track.dart';
import '../components/comments_section.dart';
import '../components/comment_input_modal.dart';
import '../components/audio_comment_player.dart';

/// Arguments for the audio comments screen
class AudioCommentsScreenArgs {
  final ProjectId projectId;
  final AudioTrack track;

  AudioCommentsScreenArgs({required this.projectId, required this.track});
}

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
  void didUpdateWidget(covariant AppAudioCommentsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.track.id != widget.track.id) {
      // Force header and comments section to rebuild with the new track
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppAppBar(title: widget.track.name),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // Fixed minimal player header
            AudioCommentPlayer(track: widget.track),
            // Scrollable comments
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.screenMarginSmall,
                ),
                child: CommentsSection(
                  projectId: widget.projectId,
                  trackId: widget.track.id,
                ),
              ),
            ),
          ],
        ),
      ),
      persistentFooterWidget: SafeArea(
        top: false,
        child: CommentInputModal(
          projectId: widget.projectId,
          trackId: widget.track.id,
        ),
      ),
    );
  }
}
