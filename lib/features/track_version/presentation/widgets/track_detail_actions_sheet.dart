import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/track_version/presentation/widgets/delete_version_dialog.dart';
import 'package:trackflow/features/track_version/presentation/widgets/rename_version_form.dart';
import 'package:trackflow/features/ui/modals/app_bottom_sheet.dart';
import 'package:trackflow/features/ui/modals/app_form_sheet.dart';
import '../../../../core/entities/unique_id.dart';
import '../blocs/track_versions/track_versions_bloc.dart';
import '../blocs/track_versions/track_versions_event.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_permission.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/track_cache_bloc.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/track_cache_event.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/track_cache_state.dart';
import 'package:share_plus/share_plus.dart';

class TrackDetailActions {
  static List<AppBottomSheetAction> forVersion(
    BuildContext context,
    AudioTrackId trackId,
    TrackVersionId versionId,
    AudioTrack track,
    Project? project,
  ) {
    // Check download permission
    final userState = context.read<UserProfileBloc>().state;
    final String? currentUserId =
        userState is UserProfileLoaded ? userState.profile.id.value : null;
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
      icon: Icons.check_circle,
      title: 'Set as Active',
      subtitle: 'Make this version the active one',
      onTap: () {
        context.read<TrackVersionsBloc>().add(
          SetActiveTrackVersionRequested(trackId, versionId),
        );
      },
    ),
    if (canDownload)
      AppBottomSheetAction(
        icon: Icons.download,
        title: 'Download Version',
        subtitle: 'Save this version to your device',
        onTap: () async {
          final bloc = context.read<TrackCacheBloc>();
          final messenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);

          // Close bottom sheet first
          navigator.pop();

          // Request download for specific version
          bloc.add(DownloadTrackRequested(
            trackId: trackId.value,
            versionId: versionId.value, // ← Specific version
          ));

          // Listen for download result
          final subscription = bloc.stream.listen((state) {
            if (state is TrackDownloadReady && state.trackId == trackId.value) {
              // Download ready - open share sheet
              Share.shareXFiles([
                XFile(state.filePath),
              ], text: 'Download ${track.name}');
            } else if (state is TrackDownloadFailure && state.trackId == trackId.value) {
              // Download failed
              final message = state.isPermissionError
                  ? 'You do not have permission to download this version'
                  : state.error;

              messenger.showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: state.isPermissionError ? Colors.red : Colors.orange,
                  duration: const Duration(seconds: 3),
                ),
              );
            } else if (state is TrackCacheOperationInProgress &&
                       state.trackId == trackId.value) {
              // Show preparing message
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Preparing version for download...'),
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
    AppBottomSheetAction(
      icon: Icons.edit,
      title: 'Rename Label',
      subtitle: 'Change the version label',
      onTap: () {
        showAppFormSheet(
          minChildSize: 0.7,
          initialChildSize: 0.7,
          maxChildSize: 0.7,
          useRootNavigator: true,
          context: context,
          title: 'Rename Version',
          child: BlocProvider.value(
            value: context.read<TrackVersionsBloc>(),
            child: RenameVersionForm(versionId: versionId),
          ),
        );
      },
    ),
    AppBottomSheetAction(
      icon: Icons.delete,
      title: 'Delete Version',
      subtitle: 'Remove this version permanently',
      onTap: () {
        showDialog(
          context: context,
          useRootNavigator: false,
          builder:
              (dialogContext) => BlocProvider.value(
                value: context.read<TrackVersionsBloc>(),
                child: DeleteVersionDialog(versionId: versionId),
              ),
        );
      },
    ),
    ];
  }
}
