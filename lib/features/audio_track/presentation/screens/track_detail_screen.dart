import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/ui/navigation/app_bar.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../ui/navigation/app_scaffold.dart';
import '../../../../core/entities/unique_id.dart';
import '../../domain/entities/audio_track.dart';
import '../../../audio_comment/presentation/components/comments_section.dart';
import '../../../audio_comment/presentation/components/comment_input_modal.dart';
import '../../../audio_comment/presentation/components/audio_comment_player.dart';
import '../../../track_version/presentation/widgets/versions_list.dart';
import '../../../track_version/presentation/blocs/track_versions/track_versions_bloc.dart';
import '../../../track_version/presentation/blocs/track_versions/track_versions_event.dart';
import '../widgets/upload_version_dialog.dart';

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
  @override
  void initState() {
    super.initState();
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

    return AppScaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppAppBar(title: widget.track.name),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // Track Header with Cover Art
            _buildTrackHeader(theme),

            // Versions Section
            _buildVersionsSection(theme),

            // Audio Player
            AudioCommentPlayer(
              track: widget.track,
              versionId:
                  widget
                      .versionId, // ✅ Pass versionId for version-specific playback
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
                  versionId: widget.versionId,
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
          versionId: widget.versionId,
        ),
      ),
    );
  }

  Widget _buildTrackHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(Dimensions.screenMarginSmall),
      child: Row(
        children: [
          // Cover Art Placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Icon(
              Icons.music_note,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),

          SizedBox(width: Dimensions.space16),

          // Track Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.track.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Dimensions.space4),
                Text(
                  _formatDuration(widget.track.duration),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: Dimensions.space2),
                Text(
                  'Uploaded by ${widget.track.uploadedBy.value}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
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
            onVersionSelected: (versionId) {
              // TODO: Set active version
              print('Selected version: $versionId');
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
