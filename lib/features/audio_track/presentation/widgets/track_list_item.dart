import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/track_version/presentation/models/track_detail_screen_args.dart';
import 'package:trackflow/features/ui/cards/base_card.dart';
import 'package:trackflow/features/ui/track/track_cover_art.dart';

class TrackListItem extends StatelessWidget {
  final AudioTrack track;

  const TrackListItem({
    super.key,
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      margin: EdgeInsets.zero,
      borderRadius: BorderRadius.zero,
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.space16,
        vertical: Dimensions.space8,
      ),
      onTap: track.activeVersionId != null
          ? () {
              context.push(
                AppRoutes.trackDetail,
                extra: TrackDetailScreenArgs(
                  projectId: track.projectId,
                  track: track,
                  versionId: track.activeVersionId!,
                ),
              );
            }
          : null,
      child: Padding(
        padding: EdgeInsets.all(Dimensions.space0),
        child: Row(
          children: [
            // Cover art
            TrackCoverArt(track: track, size: Dimensions.avatarMedium),
            SizedBox(width: Dimensions.space12),
            // Track info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Dimensions.space4),
                  Text(
                    _formatDuration(track.duration),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

