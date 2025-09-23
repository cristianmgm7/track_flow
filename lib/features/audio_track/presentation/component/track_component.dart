import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/ui/cards/base_card.dart';
import 'package:trackflow/features/ui/track/track_cover_art.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/track_cache_bloc.dart';
import 'package:trackflow/features/audio_cache/presentation/widgets/smart_track_cache_icon.dart';
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart';
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_event.dart';
// removed unused direct AudioTrack import
import 'package:trackflow/features/audio_track/presentation/cubit/track_upload_status_cubit.dart';
import 'package:trackflow/features/audio_track/presentation/widgets/track_upload_status_badge.dart';
import 'package:trackflow/core/sync/presentation/cubit/sync_status_cubit.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';
import 'package:trackflow/features/playlist/presentation/models/track_row_view_model.dart';

import 'track_duration_formatter.dart';
import 'track_info_section.dart';
import 'track_menu_button.dart';

class TrackComponent extends StatefulWidget {
  final TrackRowViewModel vm;
  final VoidCallback? onPlay;
  final VoidCallback? onComment;
  final ProjectId projectId;

  const TrackComponent({
    super.key,
    required this.vm,
    this.onPlay,
    this.onComment,
    required this.projectId,
  });

  @override
  State<TrackComponent> createState() => _TrackComponentState();
}

class _TrackComponentState extends State<TrackComponent> {
  @override
  Widget build(BuildContext context) {
    final track = widget.vm.track;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<TrackCacheBloc>()),
        BlocProvider(
          create:
              (context) =>
                  sl<AudioContextBloc>()
                    ..add(LoadTrackContextRequested(track.id)),
        ),
        BlocProvider(
          create: (context) => sl<TrackUploadStatusCubit>()..watch(track.id),
        ),
      ],
      child: BaseCard(
        onTap: () {
          if (widget.onPlay != null) {
            widget.onPlay!();
          } else {
            // Sensible default: play this single track if no handler provided
            context.read<AudioPlayerBloc>().add(
              PlayPlaylistRequested(tracks: [track], startIndex: 0),
            );
          }
        },
        margin: EdgeInsets.zero,
        borderRadius: BorderRadius.zero,
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.space16,
          vertical: Dimensions.space8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Track cover art with dynamic icons
            TrackCoverArt(
              track: track,
              size: Dimensions.avatarLarge,
              // Future: imageUrl: track.coverArtUrl,
            ),
            SizedBox(width: Dimensions.space12),
            TrackInfoSection(
              track: track,
              statusBadge: TrackUploadStatusBadge(
                trackId: track.id,
                onRetry: () => context.read<SyncStatusCubit>().retryUpstream(),
              ),
            ),
            SizedBox(width: Dimensions.space8),
            // Duration provided by VM (already resolved)
            TrackDurationText(duration: widget.vm.displayedDuration),
            SizedBox(width: Dimensions.space8),
            // Cache icon (version-based) without injecting usecase
            if (widget.vm.activeVersionId != null &&
                widget.vm.status == TrackVersionStatus.ready &&
                widget.vm.cacheableRemoteUrl != null)
              SmartTrackCacheIcon(
                trackId: track.id.value,
                versionId: widget.vm.activeVersionId!,
                remoteUrl: widget.vm.cacheableRemoteUrl!,
                size: Dimensions.iconMedium,
              ),
            SizedBox(width: Dimensions.space8),
            // Menu button
            TrackMenuButton(
              track: track,
              projectId: widget.projectId,
              size: Dimensions.iconMedium,
            ),
          ],
        ),
      ),
    );
  }
}
