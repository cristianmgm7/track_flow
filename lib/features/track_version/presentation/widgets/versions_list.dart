import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_bloc.dart';
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_state.dart';
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_event.dart';

class VersionsList extends StatelessWidget {
  final AudioTrackId trackId;
  final void Function(TrackVersionId versionId)? onVersionSelected;

  const VersionsList({
    super.key,
    required this.trackId,
    this.onVersionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackVersionsBloc, TrackVersionsState>(
      builder: (context, state) {
        if (state is TrackVersionsInitial || state is TrackVersionsLoading) {
          return const SizedBox(
            height: 56,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is TrackVersionsError) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              state.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        final loaded = state as TrackVersionsLoaded;
        if (loaded.versions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'No versions yet',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        return SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) {
              final v = loaded.versions[index];
              final isActive = loaded.activeVersionId == v.id;
              return ChoiceChip(
                label: Text(
                  'v${v.versionNumber}${v.label != null ? ' • ${v.label}' : ''}',
                ),
                selected: isActive,
                onSelected: (_) {
                  context.read<TrackVersionsBloc>().add(
                    SetActiveTrackVersionRequested(trackId, v.id),
                  );
                  onVersionSelected?.call(v.id);
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: loaded.versions.length,
          ),
        );
      },
    );
  }
}
