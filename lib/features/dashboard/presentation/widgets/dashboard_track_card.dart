import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/track_version/presentation/models/track_detail_screen_args.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/ui/cards/base_card.dart';
import 'package:trackflow/features/ui/track/track_cover_art.dart';

class DashboardTrackCard extends StatelessWidget {
  final AudioTrack track;

  const DashboardTrackCard({
    super.key,
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      onTap: track.activeVersionId != null ? () {
        // Navigate to track detail screen
        context.push(
          AppRoutes.trackDetail,
          extra: TrackDetailScreenArgs(
            projectId: track.projectId,
            track: track,
            versionId: track.activeVersionId!,
          ),
        );
      } : null,
      margin: EdgeInsets.zero,
      borderRadius: BorderRadius.zero,
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.space16,
        vertical: Dimensions.space8,
      ),
      child: Row(
        children: [
          // Cover art on the left
          TrackCoverArt(track: track, size: Dimensions.avatarLarge),
          SizedBox(width: Dimensions.space12),
          // Content stacked vertically on the right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  track.name,
                  style: AppTextStyle.titleMedium.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Dimensions.space2),
                
              ],
            ),
          ),
        ],
      ),
    );
  }

}

