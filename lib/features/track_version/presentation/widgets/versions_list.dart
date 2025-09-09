import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_bloc.dart';
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_state.dart';
import 'package:trackflow/features/track_version/presentation/cubit/track_detail_cubit.dart';

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
    return BlocBuilder<TrackDetailCubit, TrackDetailState>(
      builder: (context, detailState) {
        return BlocBuilder<TrackVersionsBloc, TrackVersionsState>(
          builder: (context, state) {
            if (state is TrackVersionsInitial ||
                state is TrackVersionsLoading) {
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
                  final selectedId =
                      detailState.activeVersionId ?? loaded.activeVersionId;
                  final isSelected = selectedId == v.id;
                  final isGloballyActive = loaded.activeVersionId == v.id;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'v${v.versionNumber}${v.label != null ? ' • ${v.label}' : ''}',
                        ),
                        if (isGloballyActive) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle, size: 16),
                        ],
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      // Only update local selection via cubit
                      context.read<TrackDetailCubit>().setActiveVersion(v.id);
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
      },
    );
  }
}
