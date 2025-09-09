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
import '../../../ui/modals/app_form_sheet.dart';
import '../widgets/upload_version_form.dart';
import '../../../ui/menus/app_popup_menu.dart';
import '../../../ui/dialogs/app_dialog.dart';
import '../../../ui/forms/app_form_field.dart';
import '../../../audio_player/presentation/bloc/audio_player_bloc.dart';
import '../../../audio_player/presentation/bloc/audio_player_event.dart';
import '../cubit/track_detail_cubit.dart';

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

    return BlocListener<TrackVersionsBloc, TrackVersionsState>(
      listener: (context, state) {
        if (state is TrackVersionsLoaded) {
          // Keep cubit in sync when TrackVersionsBloc changes active version
          if (state.activeVersionId != null) {
            context.read<TrackDetailCubit>().setActiveVersion(
              state.activeVersionId!,
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
                      // Stop current playback when switching versions
                      context.read<AudioPlayerBloc>().add(
                        const StopAudioRequested(),
                      );
                      // Update cubit immediately for UI responsiveness
                      context.read<TrackDetailCubit>().setActiveVersion(
                        versionId,
                      );
                      // Also update BLoC active version
                      context.read<TrackVersionsBloc>().add(
                        SetActiveTrackVersionRequested(
                          widget.track.id,
                          versionId,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.space8),
          _VersionHeader(trackId: widget.track.id),
        ],
      ),
    );
  }

  void _showUploadVersionDialog() {
    showAppFormSheet(
      context: context,
      title: 'Upload Version',
      child: UploadVersionForm(
        trackId: widget.track.id,
        projectId: widget.projectId,
      ),
      // Keep BLoCs available inside the sheet
      reprovideBlocs: [context.read<TrackVersionsBloc>()],
    ).then((result) {
      if (result is UploadVersionResult) {
        context.read<TrackVersionsBloc>().add(
          AddTrackVersionRequested(
            trackId: widget.track.id,
            file: result.file,
            label: result.label,
          ),
        );
      }
    });
  }
}

class _VersionHeader extends StatelessWidget {
  final AudioTrackId trackId;
  const _VersionHeader({required this.trackId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<TrackDetailCubit, TrackDetailState>(
      builder: (context, cubitState) {
        return BlocBuilder<TrackVersionsBloc, TrackVersionsState>(
          builder: (context, blocState) {
            if (blocState is! TrackVersionsLoaded) {
              return const SizedBox.shrink();
            }
            final activeId =
                cubitState.activeVersionId ?? blocState.activeVersionId;
            final active =
                activeId != null
                    ? blocState.versions.firstWhere(
                      (v) => v.id == activeId,
                      orElse: () => blocState.versions.first,
                    )
                    : blocState.versions.first;

            final label = active.label ?? 'v${active.versionNumber}';
            final isActive = activeId == active.id;

            return Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (isActive)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.check_circle,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AppPopupMenuButton<String>(
                  tooltip: 'Version actions',
                  items: const [
                    AppPopupMenuItem(
                      value: 'set_active',
                      label: 'Set as active',
                    ),
                    AppPopupMenuItem(value: 'rename', label: 'Rename label'),
                    AppPopupMenuItem(value: 'delete', label: 'Delete version'),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'set_active':
                        // The cubit is provided by the router and will be updated
                        context.read<TrackVersionsBloc>().add(
                          SetActiveTrackVersionRequested(trackId, active.id),
                        );
                        break;
                      case 'rename':
                        _showRenameDialog(context, active.id, active.label);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(context, active.id);
                        break;
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRenameDialog(
    BuildContext context,
    TrackVersionId versionId,
    String? currentLabel,
  ) {
    final controller = TextEditingController(text: currentLabel);

    showDialog(
      context: context,
      builder:
          (context) => AppDialog(
            title: 'Rename Version',
            content: 'Enter a new label for this version',
            customContent: AppFormField(
              label: 'Version Label',
              controller: controller,
              hint: 'Version label',
            ),
            primaryButtonText: 'Save',
            secondaryButtonText: 'Cancel',
            onPrimaryPressed: () {
              final newLabel =
                  controller.text.trim().isEmpty
                      ? null
                      : controller.text.trim();
              context.read<TrackVersionsBloc>().add(
                RenameTrackVersionRequested(
                  versionId: versionId,
                  newLabel: newLabel,
                ),
              );
              Navigator.of(context).pop();
            },
          ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TrackVersionId versionId) {
    showDialog(
      context: context,
      builder:
          (context) => AppDialog(
            title: 'Delete Version',
            content:
                'Are you sure you want to delete this version? This action cannot be undone.',
            primaryButtonText: 'Delete',
            secondaryButtonText: 'Cancel',
            isDestructive: true,
            onPrimaryPressed: () {
              context.read<TrackVersionsBloc>().add(
                DeleteTrackVersionRequested(versionId),
              );
              Navigator.of(context).pop();
            },
          ),
    );
  }
}
