import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/features/cache_management/presentation/bloc/cache_management_bloc.dart';
import 'package:trackflow/features/cache_management/presentation/bloc/cache_management_event.dart';
import 'package:trackflow/features/cache_management/presentation/bloc/cache_management_state.dart';
import 'package:trackflow/features/ui/navigation/app_scaffold.dart';
import 'package:trackflow/features/ui/navigation/app_bar.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/theme/app_colors.dart';

import '../widgets/storage_usage_summary.dart';
import '../widgets/track_list_view.dart';
// Cleanup panel compacted into header quick action

class CacheManagementScreen extends StatelessWidget {
  const CacheManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => sl<CacheManagementBloc>()..add(const CacheManagementStarted()),
      child: AppScaffold(
        appBar: const AppAppBar(
          title: 'Storage Management',
          centerTitle: true,
          showShadow: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(Dimensions.space12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compact header: usage + small cleanup row
              BlocBuilder<CacheManagementBloc, CacheManagementState>(
                buildWhen:
                    (p, n) =>
                        p.storageUsageBytes != n.storageUsageBytes ||
                        p.storageStats != n.storageStats,
                builder: (context, state) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: StorageUsageSummary(
                          usageBytes: state.storageUsageBytes,
                          stats: state.storageStats,
                        ),
                      ),
                      SizedBox(width: Dimensions.space12),
                      // Compact cleanup (button-only)
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<CacheManagementBloc>().add(
                                  const CacheManagementCleanupRequested(
                                    removeCorrupted: true,
                                    removeOrphaned: true,
                                    removeTemporary: true,
                                  ),
                                );
                              },
                              child: const Text('Quick Cleanup'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: Dimensions.space12),
              Text(
                'Cached Tracks',
                style: AppTextStyle.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: Dimensions.space8),
              Expanded(
                child: BlocBuilder<CacheManagementBloc, CacheManagementState>(
                  builder: (context, state) {
                    return TrackListView(state: state);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
