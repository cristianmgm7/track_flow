import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../ui/navigation/app_scaffold.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../audio_track/domain/entities/audio_track.dart';
import '../components/audio_comment_header.dart';
import '../components/comments_section.dart';
import '../components/comment_input_modal.dart';
import '../components/audio_comment_mini_player.dart';

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
      appBar: null,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: true,
                floating: false,
                snap: false,
                automaticallyImplyLeading: true,
                leading: const BackButton(),
                expandedHeight: 350,
                collapsedHeight: 64,
                backgroundColor: theme.colorScheme.surface,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.fadeTitle,
                  ],
                  background: AudioCommentHeader(track: widget.track),
                  titlePadding: EdgeInsets.zero,
                  title: AudioCommentMiniPlayer(track: widget.track),
                ),
              ),
            ];
          },
          body: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.screenMarginSmall,
            ),
            child: CommentsSection(
              projectId: widget.projectId,
              trackId: widget.track.id,
            ),
          ),
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
