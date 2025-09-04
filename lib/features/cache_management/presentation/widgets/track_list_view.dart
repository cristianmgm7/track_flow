import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/cache_management/presentation/bloc/cache_management_bloc.dart';
import 'package:trackflow/features/cache_management/presentation/bloc/cache_management_event.dart';
import 'package:trackflow/features/cache_management/presentation/bloc/cache_management_state.dart';
import 'cached_track_tile.dart';

class TrackListView extends StatelessWidget {
  const TrackListView({super.key, required this.state});
  final CacheManagementState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == CacheManagementStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == CacheManagementStatus.failure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.errorMessage ?? 'Failed to load cache',
              style: AppTextStyle.bodyLarge,
            ),
            SizedBox(height: Dimensions.space12),
            ElevatedButton(
              onPressed:
                  () => context.read<CacheManagementBloc>().add(
                    const CacheManagementRefreshRequested(),
                  ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.bundles.isEmpty) {
      return Center(
        child: Text(
          'No cached tracks yet',
          style: AppTextStyle.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Text(
              '${state.bundles.length} items',
              style: AppTextStyle.bodyMedium,
            ),
            const Spacer(),
            TextButton(
              onPressed:
                  () => context.read<CacheManagementBloc>().add(
                    const CacheManagementSelectAll(),
                  ),
              child: const Text('Select All'),
            ),
            TextButton(
              onPressed:
                  () => context.read<CacheManagementBloc>().add(
                    const CacheManagementClearSelection(),
                  ),
              child: const Text('Clear'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed:
                  state.selected.isEmpty
                      ? null
                      : () => context.read<CacheManagementBloc>().add(
                        const CacheManagementDeleteSelectedRequested(),
                      ),
              icon: const Icon(Icons.delete_outline),
              label: Text('Delete (${state.selected.length})'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: state.bundles.length,
            itemBuilder: (context, index) {
              final b = state.bundles[index];
              final isSelected = state.selected.any(
                (id) => id.value == b.trackId,
              );
              return CachedTrackTile(bundle: b, isSelected: isSelected);
            },
          ),
        ),
      ],
    );
  }
}
