import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/cache_management/domain/entities/cached_track_bundle.dart';
import 'package:trackflow/features/cache_management/presentation/bloc/cache_management_bloc.dart';
import 'package:trackflow/features/cache_management/presentation/bloc/cache_management_event.dart';
import 'package:trackflow/features/ui/cards/base_card.dart';

class CachedTrackTile extends StatelessWidget {
  const CachedTrackTile({
    super.key,
    required this.bundle,
    required this.isSelected,
  });

  final CachedTrackBundle bundle;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final trackName = bundle.track?.name ?? 'Unknown Track';

    // Include version info in title if available
    final versionSuffix =
        bundle.version != null
            ? ' (v${bundle.version!.versionNumber}${bundle.version!.label != null ? ' - ${bundle.version!.label}' : ''})'
            : ' (Version ${bundle.versionId})';

    final title = '$trackName$versionSuffix';

    final subtitlePieces = <String>[];
    if (bundle.projectName != null && bundle.projectName!.isNotEmpty) {
      subtitlePieces.add(bundle.projectName!);
    }
    if (bundle.uploader != null && bundle.uploader!.name.isNotEmpty) {
      subtitlePieces.add(bundle.uploader!.name);
    }
    final subtitle = subtitlePieces.join(' • ');

    return BaseCard(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.space16,
        vertical: Dimensions.space12,
      ),
      margin: EdgeInsets.only(bottom: Dimensions.space8),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged:
                (_) => context.read<CacheManagementBloc>().add(
                  CacheManagementToggleSelect(
                    AudioTrackId.fromUniqueString(bundle.trackId),
                  ),
                ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: Dimensions.space4),
                Text(
                  subtitle,
                  style: AppTextStyle.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Dimensions.space4),
                Text(
                  _buildMetaText(),
                  style: AppTextStyle.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.textSecondary,
            ),
            onPressed:
                () => context.read<CacheManagementBloc>().add(
                  CacheManagementDeleteTrackRequested(
                    AudioTrackId.fromUniqueString(bundle.trackId),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  String _buildMetaText() {
    final size = _formatBytes(bundle.cached.fileSizeBytes);
    final quality = bundle.cached.quality.name;
    final status = bundle.cached.status.name;
    final progress = bundle.activeDownload?.formattedProgress;

    // Add version information
    final versionInfo =
        bundle.version != null
            ? 'v${bundle.version!.versionNumber}${bundle.version!.label != null ? ' (${bundle.version!.label})' : ''}'
            : 'Version ${bundle.versionId}';

    final pieces = [
      versionInfo,
      size,
      quality,
      status,
      if (progress != null && progress.isNotEmpty) 'DL $progress',
    ];
    return pieces.join(' • ');
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
