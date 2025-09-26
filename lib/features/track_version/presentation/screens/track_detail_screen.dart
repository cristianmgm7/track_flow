import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/track_version/presentation/components/version_header_component.dart';
import 'package:trackflow/features/ui/navigation/app_bar.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../ui/navigation/app_scaffold.dart';
import '../../../ui/modals/app_form_sheet.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../audio_track/domain/entities/audio_track.dart';
import '../../../audio_comment/presentation/components/comments_section.dart';
import '../../../audio_comment/presentation/components/comment_input_modal.dart';
import '../../../waveform/presentation/widgets/audio_comment_player.dart';
import '../blocs/track_versions/track_versions_bloc.dart';
import '../blocs/track_versions/track_versions_event.dart';
import '../blocs/track_versions/track_versions_state.dart';
import '../cubit/track_detail_cubit.dart';
import '../components/versions_section_component.dart';
import '../widgets/upload_version_form.dart';

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
    context.read<AudioPlayerBloc>().add(
      PlayVersionRequested(widget.track.activeVersionId!),
    );
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
        child: Column(
          children: [
            // Versions Section
            VersionsSectionComponent(trackId: widget.track.id),
            VersionHeaderComponent(trackId: widget.track.id),
            // Audio Player
            Builder(
              builder: (context) {
                final selectedFromCubit = context
                    .select<TrackDetailCubit, TrackVersionId?>(
                      (cubit) => cubit.state.activeVersionId,
                    );
                final selectedFromBloc = context
                    .select<TrackVersionsBloc, TrackVersionId?>((bloc) {
                      final s = bloc.state;
                      return s is TrackVersionsLoaded
                          ? s.activeVersionId
                          : null;
                    });
                final effectiveVersionId =
                    selectedFromCubit ?? selectedFromBloc ?? widget.versionId;
                return AudioCommentPlayer(
                  track: widget.track,
                  versionId: effectiveVersionId,
                );
              },
            ),

            // Comments Section
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.screenMarginSmall,
                ),
                child: Builder(
                  builder: (context) {
                    final selectedFromCubit = context
                        .select<TrackDetailCubit, TrackVersionId?>(
                          (cubit) => cubit.state.activeVersionId,
                        );
                    final selectedFromBloc = context
                        .select<TrackVersionsBloc, TrackVersionId?>((bloc) {
                          final s = bloc.state;
                          return s is TrackVersionsLoaded
                              ? s.activeVersionId
                              : null;
                        });
                    final effectiveVersionId =
                        selectedFromCubit ??
                        selectedFromBloc ??
                        widget.versionId;
                    return CommentsSection(
                      projectId: widget.projectId,
                      trackId: widget.track.id,
                      versionId: effectiveVersionId,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      persistentFooterWidget: SafeArea(
        top: false,
        child: Builder(
          builder: (context) {
            final selectedFromCubit = context
                .select<TrackDetailCubit, TrackVersionId?>(
                  (cubit) => cubit.state.activeVersionId,
                );
            final selectedFromBloc = context
                .select<TrackVersionsBloc, TrackVersionId?>((bloc) {
                  final s = bloc.state;
                  return s is TrackVersionsLoaded ? s.activeVersionId : null;
                });
            final effectiveVersionId =
                selectedFromCubit ?? selectedFromBloc ?? widget.versionId;
            return CommentInputModal(
              projectId: widget.projectId,
              versionId: effectiveVersionId,
            );
          },
        ),
      ),
    );
  }
}
