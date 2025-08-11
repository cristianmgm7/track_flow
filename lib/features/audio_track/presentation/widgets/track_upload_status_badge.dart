import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/audio_track/presentation/cubit/track_upload_status_cubit.dart';
import 'package:trackflow/features/audio_track/domain/usecases/watch_track_upload_status_usecase.dart';

class TrackUploadStatusBadge extends StatelessWidget {
  final AudioTrackId trackId;
  final VoidCallback? onRetry;

  const TrackUploadStatusBadge({
    super.key,
    required this.trackId,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackUploadStatusCubit, TrackUploadStatusState>(
      builder: (context, state) {
        switch (state.status) {
          case TrackUploadStatus.none:
            return const SizedBox.shrink();
          case TrackUploadStatus.pending:
            return _Badge(
              icon: const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              label: 'Uploading…',
              color: AppColors.warning,
            );
          case TrackUploadStatus.failed:
            return GestureDetector(
              onTap: onRetry,
              child: _Badge(
                icon: Icon(
                  Icons.error_outline,
                  size: 16,
                  color: AppColors.error,
                ),
                label: 'Failed. Tap to retry',
                color: AppColors.error,
              ),
            );
        }
      },
    );
  }
}

class _Badge extends StatelessWidget {
  final Widget icon;
  final String label;
  final Color color;

  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.space8,
        vertical: Dimensions.space4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
