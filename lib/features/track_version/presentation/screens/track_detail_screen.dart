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
import '../cubit/track_detail_cubit.dart';
import '../../../audio_player/presentation/bloc/audio_player_bloc.dart';
import '../../../audio_player/presentation/bloc/audio_player_event.dart';
import '../components/version_header_component.dart';
import '../widgets/rename_version_dialog.dart';
import '../widgets/delete_version_dialog.dart';
import '../actions/upload_version_actions.dart';

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
      WatchTrackVersionsRequested(
        widget.track.id,
        widget.track.activeVersionId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<TrackVersionsBloc, TrackVersionsState>(
      listener: (context, state) {
        if (state is TrackVersionsLoaded) {
          // Keep cubit in sync when TrackVersionsBloc changes active version
          if (state.activeVersionId != null) {
            context.read<TrackDetailCubit>().setActiveVersion(
              state.activeVersionId!,
            );
            // Auto-play the version specified in the route, or the active version if none specified
            final versionToPlay = widget.versionId;
            context.read<AudioPlayerBloc>().add(
              PlayVersionRequested(versionToPlay),
            );
          }
        }
      },
      child: AppScaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppAppBar(
          title: widget.track.name,
          actions: [
            AppIconButton(
              icon: Icons.add,
              onPressed: _showUploadVersionDialog,
              tooltip: 'Upload new version',
            ),
          ],
        ),
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // Versions Section
              _buildVersionsSection(theme),

              // Audio Player
              BlocBuilder<TrackDetailCubit, TrackDetailState>(
                builder:
                    (context, state) => AudioCommentPlayer(
                      track: widget.track,
                      versionId: state.activeVersionId ?? widget.versionId,
                    ),
              ),

              // Comments Section
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.screenMarginSmall,
                  ),
                  child: BlocBuilder<TrackDetailCubit, TrackDetailState>(
                    builder:
                        (context, state) => CommentsSection(
                          projectId: widget.projectId,
                          trackId: widget.track.id,
                          versionId: state.activeVersionId ?? widget.versionId,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
        persistentFooterWidget: SafeArea(
          top: false,
          child: BlocBuilder<TrackDetailCubit, TrackDetailState>(
            builder:
                (context, state) => CommentInputModal(
                  projectId: widget.projectId,
                  versionId: state.activeVersionId ?? widget.versionId,
                ),
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
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: VersionsList(
                    trackId: widget.track.id,
                    onVersionSelected: (versionId) {
                      // Play the new version directly (seamless transition)
                      context.read<AudioPlayerBloc>().add(
                        PlayVersionRequested(versionId),
                      );
                      // Update cubit immediately for UI responsiveness
                      context.read<TrackDetailCubit>().setActiveVersion(
                        versionId,
                      );
                      // Do not persist active version here. That happens via header menu.
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.space8),
          VersionHeaderComponent(
            trackId: widget.track.id,
            onRenamePressed: _showRenameDialog,
            onDeletePressed: _showDeleteConfirmation,
          ),
        ],
      ),
    );
  }

  void _showUploadVersionDialog() {
    UploadVersionActions.showUploadVersionDialog(
      context: context,
      trackId: widget.track.id,
      projectId: widget.projectId,
    );
  }

  void _showRenameDialog() {
    // Get current active version info from the state
    final cubitState = context.read<TrackDetailCubit>().state;
    final blocState = context.read<TrackVersionsBloc>().state;

    if (blocState is TrackVersionsLoaded && blocState.versions.isNotEmpty) {
      final activeId = cubitState.activeVersionId ?? blocState.activeVersionId;
      final active =
          activeId != null
              ? blocState.versions.firstWhere(
                (v) => v.id == activeId,
                orElse: () => blocState.versions.first,
              )
              : blocState.versions.first;

      RenameVersionDialog.show(
        context,
        versionId: active.id,
        currentLabel: active.label,
      );
    }
  }

  void _showDeleteConfirmation() {
    // Get current active version info from the state
    final cubitState = context.read<TrackDetailCubit>().state;
    final blocState = context.read<TrackVersionsBloc>().state;

    if (blocState is TrackVersionsLoaded && blocState.versions.isNotEmpty) {
      final activeId = cubitState.activeVersionId ?? blocState.activeVersionId;
      final active =
          activeId != null
              ? blocState.versions.firstWhere(
                (v) => v.id == activeId,
                orElse: () => blocState.versions.first,
              )
              : blocState.versions.first;

      DeleteVersionDialog.show(context, versionId: active.id);
    }
  }
}
