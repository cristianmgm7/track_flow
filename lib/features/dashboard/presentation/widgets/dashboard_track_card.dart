import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_borders.dart';
import 'package:trackflow/features/audio_track/presentation/models/audio_track_ui_model.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/ui/cards/base_card.dart';
import 'package:trackflow/features/ui/track/track_cover_art.dart';

class DashboardTrackCard extends StatelessWidget {
  final AudioTrackUiModel track;
  final VoidCallback? onTap;

  const DashboardTrackCard({
    super.key,
    required this.track,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      onTap: onTap,
      margin: EdgeInsets.zero,
      borderRadius: BorderRadius.zero,
      padding: EdgeInsets.only(right: Dimensions.space16,left: Dimensions.space16),
      child: Row(
        children: [
          // Cover art on the left
          TrackCoverArt(track: track.track, imageUrl: track.coverUrl, size: Dimensions.avatarXLarge, borderRadius: AppBorders.medium),
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

