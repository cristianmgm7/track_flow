import 'package:flutter/material.dart';
import 'package:trackflow/core/sync/domain/entities/sync_state.dart';
import 'package:trackflow/core/sync/presentation/cubit/sync_status_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';

class GlobalSyncIndicator extends StatefulWidget {
  const GlobalSyncIndicator({super.key});

  @override
  State<GlobalSyncIndicator> createState() => _GlobalSyncIndicatorState();
}

class _GlobalSyncIndicatorState extends State<GlobalSyncIndicator> {
  SyncState _state = SyncState.initial;
  int _pending = 0;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<SyncStatusCubit>();
    cubit.start();
    _state = cubit.state.syncState;
    _pending = cubit.state.pendingCount;
    cubit.stream.listen((s) {
      if (!mounted) return;
      setState(() {
        _state = s.syncState;
        _pending = s.pendingCount;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_state.status == SyncStatus.syncing) {
      return _buildChip(
        child: Row(
          children: [
            SizedBox(
              height: 14,
              width: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: _state.progress == 0 ? null : _state.progress,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text('Syncing… ${(100 * _state.progress).toInt()}%'),
          ],
        ),
      );
    }

    if (_pending > 0) {
      return _buildChip(
        child: Text('$_pending item${_pending == 1 ? '' : 's'} to sync'),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildChip({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(
        left: Dimensions.space16,
        right: Dimensions.space16,
        bottom: Dimensions.space8,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.space12,
        vertical: Dimensions.space6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(color: AppColors.border),
      ),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.labelMedium!,
        child: child,
      ),
    );
  }
}
