import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/audio_cache/domain/usecases/get_cache_storage_stats_usecase.dart';

class StorageUsageSummary extends StatelessWidget {
  const StorageUsageSummary({
    super.key,
    required this.usageBytes,
    required this.stats,
  });

  final int usageBytes;
  final StorageStats? stats;

  @override
  Widget build(BuildContext context) {
    final total = stats?.formattedTotalSize ?? _formatBytes(usageBytes);
    final available = stats?.formattedAvailableSpace ?? '—';
    final usedPct = stats?.usedPercentage ?? 0.0;

    return Container(
      padding: EdgeInsets.all(Dimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Storage',
            style: AppTextStyle.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: Dimensions.space8),
          LinearProgressIndicator(
            value: (usedPct / 100).clamp(0.0, 1.0),
            backgroundColor: AppColors.grey700,
            color: AppColors.primary,
            minHeight: 8,
          ),
          SizedBox(height: Dimensions.space8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Used: $total', style: AppTextStyle.bodyMedium),
              Text('Free: $available', style: AppTextStyle.bodyMedium),
            ],
          ),
        ],
      ),
    );
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
