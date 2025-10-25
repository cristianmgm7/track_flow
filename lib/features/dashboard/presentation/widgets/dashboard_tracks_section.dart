import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/audio_track/presentation/models/audio_track_ui_model.dart';
import 'package:trackflow/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:trackflow/features/dashboard/presentation/widgets/dashboard_track_card.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/track_version/presentation/models/track_detail_screen_args.dart';

class DashboardTracksSection extends StatelessWidget {
  final List<AudioTrackUiModel> tracks;

  const DashboardTracksSection({
    super.key,
    required this.tracks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          title: 'Tracks',
          onSeeAll:  () => context.go(AppRoutes.trackList), // New route
        ),
        SizedBox(height: Dimensions.space12),
        if (tracks.isEmpty)
          _buildEmptyState(context)
        else
          _buildTracksGrid(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Dimensions.space24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.music_note_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: Dimensions.space12),
            Text(
              textAlign: TextAlign.center,
              'No tracks yet. Create a project to get started!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.warning,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTracksGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
        childAspectRatio: 3,
      ),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final trackUi = tracks[index];
        return DashboardTrackCard(track: trackUi, onTap: () {
          context.push(
            AppRoutes.trackDetail,
            extra: TrackDetailScreenArgs(
              projectId: trackUi.track.projectId,
              track: trackUi.track,
              versionId: trackUi.track.activeVersionId!,
            ),
          );
        });
      },
    );
  }
}


