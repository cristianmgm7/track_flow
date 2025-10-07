import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/ui/cards/base_card.dart';
import 'package:trackflow/features/ui/track/track_cover_art.dart';
import 'package:trackflow/features/audio_cache/presentation/widgets/smart_track_cache_icon.dart';
import 'package:trackflow/features/audio_track/presentation/widgets/track_upload_status_badge.dart';
import 'package:trackflow/core/sync/presentation/bloc/sync_bloc.dart';
import 'package:trackflow/core/sync/presentation/bloc/sync_event.dart';
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

    return BaseCard(
      onTap: () {
        if (widget.onPlay != null) {
          widget.onPlay!();
        } else {
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
          TrackCoverArt(track: track, size: Dimensions.avatarLarge),
          SizedBox(width: Dimensions.space12),
          TrackInfoSection(
            track: track,
            statusBadge: TrackUploadStatusBadge(
              trackId: track.id,
              onRetry: () => context.read<SyncBloc>().add(const UpstreamSyncRequested()),
            ),
          ),
          SizedBox(width: Dimensions.space8),
          TrackDurationText(duration: widget.vm.displayedDuration),
          SizedBox(width: Dimensions.space8),
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
          TrackMenuButton(
            track: track,
            projectId: widget.projectId,
            size: Dimensions.iconMedium,
          ),
        ],
      ),
    );
  }
}
