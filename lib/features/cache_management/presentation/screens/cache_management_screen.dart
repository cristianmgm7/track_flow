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
import '../widgets/cleanup_panel.dart';

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
          padding: EdgeInsets.all(Dimensions.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<CacheManagementBloc, CacheManagementState>(
                buildWhen:
                    (p, n) =>
                        p.storageUsageBytes != n.storageUsageBytes ||
                        p.storageStats != n.storageStats,
                builder: (context, state) {
                  return StorageUsageSummary(
                    usageBytes: state.storageUsageBytes,
                    stats: state.storageStats,
                  );
                },
              ),
              SizedBox(height: Dimensions.space16),
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
              SizedBox(height: Dimensions.space8),
              const CleanupPanel(),
            ],
          ),
        ),
      ),
    );
  }
}
