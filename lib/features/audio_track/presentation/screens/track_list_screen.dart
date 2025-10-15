import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:trackflow/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:trackflow/features/audio_track/presentation/widgets/track_list_item.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/ui/navigation/app_scaffold.dart';
import 'package:trackflow/features/ui/navigation/app_bar.dart';
import 'package:trackflow/features/ui/list/app_list_header_bar.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';

class TrackListScreen extends StatelessWidget {
  const TrackListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(
        title: 'All Tracks',
        centerTitle: true,
        showShadow: true,
        leading: AppIconButton(
          icon: Icons.arrow_back_ios_rounded,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.dashboard);
            }
          },
          tooltip: 'Back',
        ),
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            return Center(
              child: Text(
                state.message,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          if (state is DashboardLoaded) {
            // Access full track list from the bloc
            // Note: DashboardBloc only has preview (6 tracks)
            // We need to fetch full list - for now, just show preview with note
            final tracks = state.trackPreview;

            if (tracks.isEmpty) {
              return _buildEmptyState(context);
            }

            return Column(
              children: [
                AppListHeaderBar(
                  leadingText: 'Sorted by: Created • ${tracks.length}',
                ),
                Expanded(
                  child: ListView.separated(
                    
                    padding: EdgeInsets.all(Dimensions.space0),
                    itemCount: tracks.length,
                    separatorBuilder: (context, index) => SizedBox(
                      height: Dimensions.space12,
                    ),
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      return TrackListItem(track: track);
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: Dimensions.space16),
          Text(
            'No tracks yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

}


