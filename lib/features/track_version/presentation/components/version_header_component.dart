import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../ui/menus/app_popup_menu.dart';
import '../blocs/track_versions/track_versions_bloc.dart';
import '../blocs/track_versions/track_versions_event.dart';
import '../blocs/track_versions/track_versions_state.dart';
import '../cubit/track_detail_cubit.dart';

/// Header component for displaying active version information and actions
class VersionHeaderComponent extends StatelessWidget {
  final AudioTrackId trackId;
  final VoidCallback? onRenamePressed;
  final VoidCallback? onDeletePressed;

  const VersionHeaderComponent({
    super.key,
    required this.trackId,
    this.onRenamePressed,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<TrackDetailCubit, TrackDetailState>(
      builder: (context, cubitState) {
        return BlocBuilder<TrackVersionsBloc, TrackVersionsState>(
          builder: (context, blocState) {
            if (blocState is! TrackVersionsLoaded) {
              return const SizedBox.shrink();
            }
            final activeId =
                cubitState.activeVersionId ?? blocState.activeVersionId;
            final active =
                activeId != null
                    ? blocState.versions.firstWhere(
                      (v) => v.id == activeId,
                      orElse: () => blocState.versions.first,
                    )
                    : blocState.versions.first;

            final label = active.label ?? 'v${active.versionNumber}';
            final isActive = activeId == active.id;

            return Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (isActive)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.check_circle,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AppPopupMenuButton<String>(
                  tooltip: 'Version actions',
                  items: const [
                    AppPopupMenuItem(
                      value: 'set_active',
                      label: 'Set as active',
                    ),
                    AppPopupMenuItem(value: 'rename', label: 'Rename label'),
                    AppPopupMenuItem(value: 'delete', label: 'Delete version'),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'set_active':
                        // The cubit is provided by the router and will be updated
                        context.read<TrackVersionsBloc>().add(
                          SetActiveTrackVersionRequested(trackId, active.id),
                        );
                        break;
                      case 'rename':
                        onRenamePressed?.call();
                        break;
                      case 'delete':
                        onDeletePressed?.call();
                        break;
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
