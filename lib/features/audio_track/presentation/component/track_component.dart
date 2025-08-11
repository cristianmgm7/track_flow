import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/ui/cards/base_card.dart';
import 'package:trackflow/features/ui/track/track_cover_art.dart';
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart';
import 'package:trackflow/features/audio_cache/track/presentation/widgets/smart_track_cache_icon.dart';
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart';
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_event.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/presentation/cubit/track_upload_status_cubit.dart';
import 'package:trackflow/features/audio_track/presentation/widgets/track_upload_status_badge.dart';
import 'package:trackflow/core/sync/presentation/cubit/sync_status_cubit.dart';

import 'track_duration_formatter.dart';
import 'track_info_section.dart';
import 'track_menu_button.dart';

class TrackComponent extends StatefulWidget {
  final AudioTrack track;
  final VoidCallback? onPlay;
  final VoidCallback? onComment;
  final ProjectId projectId;

  const TrackComponent({
    super.key,
    required this.track,
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<TrackCacheBloc>()),
        BlocProvider(
          create:
              (context) =>
                  sl<AudioContextBloc>()
                    ..add(LoadTrackContextRequested(widget.track.id)),
        ),
        BlocProvider(
          create:
              (context) => sl<TrackUploadStatusCubit>()..watch(widget.track.id),
        ),
      ],
      child: BaseCard(
        onTap: () {
          if (widget.onPlay != null) {
            widget.onPlay!();
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
              track: widget.track,
              size: Dimensions.avatarLarge,
              // Future: imageUrl: track.coverArtUrl,
            ),
            SizedBox(width: Dimensions.space12),
            TrackInfoSection(
              track: widget.track,
              statusBadge: TrackUploadStatusBadge(
                trackId: widget.track.id,
                onRetry: () => context.read<SyncStatusCubit>().retryUpstream(),
              ),
            ),
            SizedBox(width: Dimensions.space8),
            // Duration
            TrackDurationText(duration: widget.track.duration),
            SizedBox(width: Dimensions.space8),
            // Cache icon
            SmartTrackCacheIcon(
              trackId: widget.track.id.value,
              audioUrl: widget.track.url,
              size: Dimensions.iconMedium,
            ),
            SizedBox(width: Dimensions.space8),
            // Menu button
            TrackMenuButton(
              track: widget.track,
              projectId: widget.projectId,
              size: Dimensions.iconMedium,
            ),
          ],
        ),
      ),
    );
  }
}
