import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/track_version/presentation/models/track_detail_screen_args.dart';
import 'package:trackflow/features/ui/modals/app_bottom_sheet.dart';
import 'package:trackflow/features/ui/modals/app_form_sheet.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/presentation/widgets/delete_audio_track_alert_dialog.dart';
import 'package:trackflow/features/audio_track/presentation/widgets/rename_audio_track_form_sheet.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/track_cache_bloc.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/track_cache_event.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/track_cache_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_permission.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';

class TrackActions {
  static List<AppBottomSheetAction> forTrack(
    BuildContext context,
    ProjectId projectId,
    AudioTrack track,
    Project? project,
  ) {
    // Check if user has download permission
    final userState = context.read<CurrentUserBloc>().state;
    final String? currentUserId =
        userState is CurrentUserLoaded ? userState.profile.id.value : null;
    bool canDownload = false;
    if (currentUserId != null && project != null) {
      try {
        final me = project.collaborators.firstWhere(
          (c) => c.userId.value == currentUserId,
        );
        canDownload = me.hasPermission(ProjectPermission.downloadTrack);
      } catch (_) {
        canDownload = false;
      }
    }

    return [
    AppBottomSheetAction(
      icon: Icons.comment,
      title: 'Comment',
      subtitle: 'Add feedback or notes to this track',
      onTap: () {
        context.push(
          AppRoutes.trackDetail,
          extra: TrackDetailScreenArgs(
            projectId: track.projectId,
            track: track,
            versionId: track.activeVersionId ?? TrackVersionId(),
          ),
        );
      },
    ),
    AppBottomSheetAction(
      icon: Icons.edit,
      title: 'Rename',
      subtitle: 'Change the track’s title',
      onTap: () {
        showAppFormSheet(
          minChildSize: 0.7,
          initialChildSize: 0.7,
          maxChildSize: 0.7,
          useRootNavigator: true,
          context: context,
          title: 'Rename Track',
          child: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<AudioTrackBloc>()),
            ],
            child: RenameTrackForm(track: track),
          ),
        );
      },
    ),
    AppBottomSheetAction(
      icon: Icons.delete,
      title: 'Delete Track',
      subtitle: 'Remove from the project',
      onTap: () {
        showDialog(
          context: context,
          useRootNavigator: false,
          builder:
              (context) => DeleteAudioTrackAlertDialog(
                projectId: projectId,
                track: track,
              ),
        );
      },
    ),
    if (canDownload)
      AppBottomSheetAction(
        icon: Icons.download,
        title: 'Download',
        subtitle: 'Save this track to your device',
        onTap: () async {
          final bloc = context.read<TrackCacheBloc>();
          final messenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);

          // Close bottom sheet first
          navigator.pop();

          // Request download (will check permissions and generate friendly filename)
          bloc.add(DownloadTrackRequested(
            trackId: track.id.value,
            versionId: null, // null = active version
          ));

          // Listen for download result
          final subscription = bloc.stream.listen((state) {
            if (state is TrackDownloadReady && state.trackId == track.id.value) {
              // Download ready - open share sheet
              Share.shareXFiles([
                XFile(state.filePath),
              ], text: 'Download ${track.name}');
            } else if (state is TrackDownloadFailure && state.trackId == track.id.value) {
              // Download failed
              final message = state.isPermissionError
                  ? 'You do not have permission to download this track'
                  : state.error;

              messenger.showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: state.isPermissionError ? Colors.red : Colors.orange,
                  duration: const Duration(seconds: 3),
                ),
              );
            } else if (state is TrackCacheOperationInProgress &&
                       state.trackId == track.id.value) {
              // Show preparing message
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Preparing ${track.name} for download...'),
                  backgroundColor: Colors.blue,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          });

          // Auto-cancel subscription after 10 seconds
          Future.delayed(const Duration(seconds: 10), () {
            subscription.cancel();
          });
        },
      ),
    ];
  }
}
