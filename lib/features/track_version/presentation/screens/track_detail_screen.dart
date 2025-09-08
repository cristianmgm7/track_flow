import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/ui/navigation/app_bar.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../ui/navigation/app_scaffold.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../audio_track/domain/entities/audio_track.dart';
import '../../../audio_comment/presentation/components/comments_section.dart';
import '../../../audio_comment/presentation/components/comment_input_modal.dart';
import '../../../audio_comment/presentation/components/audio_comment_player.dart';
import '../widgets/versions_list.dart';
import '../blocs/track_versions/track_versions_bloc.dart';
import '../blocs/track_versions/track_versions_event.dart';
import '../blocs/track_versions/track_versions_state.dart';
import '../../../audio_track/presentation/widgets/upload_version_dialog.dart';

/// Arguments for the track detail screen
class TrackDetailScreenArgs {
  final ProjectId projectId;
  final AudioTrack track;
  final TrackVersionId versionId; // selected/active version

  TrackDetailScreenArgs({
    required this.projectId,
    required this.track,
    required this.versionId,
  });
}

class TrackDetailScreen extends StatefulWidget {
  final ProjectId projectId;
  final AudioTrack track;
  final TrackVersionId versionId;

  const TrackDetailScreen({
    super.key,
    required this.projectId,
    required this.track,
    required this.versionId,
  });

  @override
  State<TrackDetailScreen> createState() => _TrackDetailScreenState();
}

class _TrackDetailScreenState extends State<TrackDetailScreen> {
  TrackVersionId? _activeVersionId;

  @override
  void initState() {
    super.initState();
    _activeVersionId = widget.versionId;
    // Load versions for this track
    context.read<TrackVersionsBloc>().add(
      WatchTrackVersionsRequested(widget.track.id),
    );
  }

  @override
  void didUpdateWidget(covariant TrackDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.track.id != widget.track.id) {
      // Force header and comments section to rebuild with the new track
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<TrackVersionsBloc, TrackVersionsState>(
      listener: (context, state) {
        if (state is TrackVersionsLoaded) {
          // Update active version when TrackVersionsBloc changes it
          if (state.activeVersionId != null &&
              state.activeVersionId != _activeVersionId) {
            setState(() {
              _activeVersionId = state.activeVersionId;
            });
          }
        }
      },
      child: AppScaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppAppBar(title: widget.track.name),
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // Versions Section
              _buildVersionsSection(theme),

              // Audio Player
              AudioCommentPlayer(
                track: widget.track,
                versionId:
                    _activeVersionId ??
                    widget
                        .versionId, // ✅ Pass reactive versionId for version-specific playback
              ),

              // Comments Section
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.screenMarginSmall,
                  ),
                  child: CommentsSection(
                    projectId: widget.projectId,
                    trackId: widget.track.id,
                    versionId: _activeVersionId ?? widget.versionId,
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
            versionId: _activeVersionId ?? widget.versionId,
          ),
        ),
      ),
    );
  }

  Widget _buildVersionsSection(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.screenMarginSmall,
        vertical: Dimensions.space8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Versions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Upload New Version Button
              IconButton(
                onPressed: () => _showUploadVersionDialog(),
                icon: Icon(Icons.add, color: theme.colorScheme.primary),
                tooltip: 'Upload new version',
              ),
            ],
          ),
          SizedBox(height: Dimensions.space8),
          // Versions List
          VersionsList(
            trackId: widget.track.id,
            // Version selection is now handled reactively through BlocListener above
          ),
        ],
      ),
    );
  }

  void _showUploadVersionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => UploadVersionDialog(
            trackId: widget.track.id,
            projectId: widget.projectId,
          ),
    );
  }
}
