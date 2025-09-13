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

class TrackActions {
  static List<AppBottomSheetAction> forTrack(
    BuildContext context,
    ProjectId projectId,
    AudioTrack track,
  ) => [
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
    AppBottomSheetAction(
      icon: Icons.download,
      title: 'Download',
      subtitle: 'Save this track to your device',
      onTap: () async {
        final bloc = context.read<TrackCacheBloc>();
        final messenger = ScaffoldMessenger.of(context);

        // 1) Try to get a cached path immediately
        final completer = Completer<String?>();
        late final StreamSubscription sub;
        sub = bloc.stream.listen((state) {
          if (state is TrackCachePathLoaded &&
              state.trackId == track.id.value) {
            completer.complete(state.filePath);
            sub.cancel();
          } else if (state is TrackCacheOperationFailure &&
              state.trackId == track.id.value) {
            completer.complete(null);
            sub.cancel();
          }
        });
        bloc.add(GetCachedTrackPathRequested(track.id.value));

        final filePath = await completer.future.timeout(
          const Duration(seconds: 2),
          onTimeout: () => null,
        );

        if (filePath != null && filePath.isNotEmpty) {
          // 2) Share the cached file so user can choose destination
          await Share.shareXFiles([
            XFile(filePath),
          ], text: 'Export ${track.name}');
        } else {
          // 3) Not cached yet → start caching and inform user to retry export when ready
          bloc.add(
            CacheTrackRequested(
              trackId: track.id.value,
              audioUrl: track.url,
              versionId: track.activeVersionId?.value ?? '',
            ),
          );
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Downloading ${track.name}... Tap Download again to save when ready',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
    ),
  ];
}
