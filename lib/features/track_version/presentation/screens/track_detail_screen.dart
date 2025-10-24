import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/track_version/presentation/components/version_header_component.dart';
import 'package:trackflow/features/ui/navigation/app_bar.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../ui/navigation/app_scaffold.dart';
import '../../../ui/modals/app_form_sheet.dart';
// duplicate import removed
import '../../../audio_track/domain/entities/audio_track.dart';
import '../../../audio_comment/presentation/components/comments_sliver_section.dart';
import '../../../audio_comment/presentation/components/comment_input_modal.dart';
import '../../../waveform/presentation/widgets/track_detail_player.dart';
import '../blocs/track_versions/track_versions_bloc.dart';
import '../blocs/track_versions/track_versions_event.dart';
import '../cubit/version_selector_cubit.dart';
import '../components/versions_section_component.dart';
import '../widgets/upload_version_form.dart';
import '../../../project_detail/presentation/bloc/project_detail_bloc.dart';
import '../../../project_detail/presentation/bloc/project_detail_event.dart';
import '../../../project_detail/presentation/bloc/project_detail_state.dart';
import '../../../user_profile/presentation/bloc/current_user/current_user_bloc.dart';
import '../../../user_profile/presentation/bloc/current_user/current_user_state.dart';
import '../../../projects/domain/entities/project_collaborator.dart';
import '../../../projects/domain/value_objects/project_role.dart';
import '../../../projects/domain/value_objects/project_permission.dart';
import '../../../../core/entities/unique_id.dart';

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

    // Initialize version selector cubit immediately with incoming versionId
    context.read<VersionSelectorCubit>().initialize(widget.versionId);

    // Load versions for this track (pass incoming versionId as initial active)
    context.read<TrackVersionsBloc>().add(
      WatchTrackVersionsRequested(
        widget.track.id,
        widget.versionId,
      ),
    );

    // Play the requested version
    context.read<AudioPlayerBloc>().add(
      PlayVersionRequested(widget.versionId),
    );

    // Watch project detail to drive permissions
    context.read<ProjectDetailBloc>().add(WatchProjectDetail(projectId: widget.projectId));
  }

  void _showUploadVersionForm() {
    showAppFormSheet(
      context: context,
      title: 'Upload Version',
      child: BlocProvider.value(
        value: context.read<TrackVersionsBloc>(),
        child: UploadVersionForm(
          trackId: widget.track.id,
          projectId: widget.projectId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<VersionSelectorCubit, VersionSelectorState>(
      builder: (context, selectorState) {
        final selectedVersionId = selectorState.selectedVersionId ?? widget.versionId;

        return AppScaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppAppBar(
            title: widget.track.name,
            actions: [
              AppIconButton(
                icon: Icons.add,
                onPressed: _showUploadVersionForm,
                tooltip: 'Upload new version',
              ),
            ],
          ),
          resizeToAvoidBottomInset: true,
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: VersionsSectionComponent(trackId: widget.track.id),
                ),
                SliverToBoxAdapter(
                  child: VersionHeaderComponent(
                    trackId: widget.track.id,
                    track: widget.track,
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedPlayerHeaderDelegate(
                    height: Dimensions.space160,
                    child: TrackDetailPlayer(
                      key: ValueKey('player_${selectedVersionId.value}'),
                      track: widget.track,
                      versionId: selectedVersionId,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.screenMarginSmall,
                  ),
                  sliver: CommentsSliverSection(
                    key: ValueKey('comments_${selectedVersionId.value}'),
                    projectId: widget.projectId,
                    trackId: widget.track.id,
                    versionId: selectedVersionId,
                  ),
                ),
              ],
            ),
          ),
          persistentFooterWidget: BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
            builder: (context, pdState) {
              final project = pdState.project;
              if (project == null) {
                return const SizedBox.shrink();
              }

              // Derive current user id from CurrentUserBloc
              final userState = context.watch<CurrentUserBloc>().state;
              final String? currentUserId =
                  userState is CurrentUserLoaded ? userState.profile.id.value : null;

              bool canAddComment = false;
              if (currentUserId != null) {
                final me = project.collaborators.firstWhere(
                  (c) => c.userId.value == currentUserId,
                  orElse: () => ProjectCollaborator.create(
                    userId: UserId.fromUniqueString(currentUserId),
                    role: ProjectRole.viewer,
                  ),
                );
                canAddComment = me.hasPermission(ProjectPermission.addComment);
              }

              if (!canAddComment) {
                return const SizedBox.shrink();
              }

              return SafeArea(
                top: false,
                child: CommentInputModal(
                  projectId: widget.projectId,
                  versionId: selectedVersionId,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _PinnedPlayerHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _PinnedPlayerHeaderDelegate({
    required this.height,
    required this.child,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedPlayerHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child.key != child.key;
  }
}
