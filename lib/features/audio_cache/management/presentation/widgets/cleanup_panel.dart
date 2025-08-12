import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/audio_cache/management/presentation/bloc/cache_management_bloc.dart';
import 'package:trackflow/features/audio_cache/management/presentation/bloc/cache_management_event.dart';

class CleanupPanel extends StatefulWidget {
  const CleanupPanel({super.key});

  @override
  State<CleanupPanel> createState() => _CleanupPanelState();
}

class _CleanupPanelState extends State<CleanupPanel> {
  bool removeCorrupted = true;
  bool removeOrphaned = true;
  bool removeTemporary = true;
  final TextEditingController _targetBytesCtrl = TextEditingController();

  @override
  void dispose() {
    _targetBytesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cleanup', style: AppTextStyle.titleLarge),
        SizedBox(height: Dimensions.space8),
        Wrap(
          spacing: Dimensions.space12,
          runSpacing: Dimensions.space8,
          children: [
            FilterChip(
              label: const Text('Remove Corrupted'),
              selected: removeCorrupted,
              onSelected: (v) => setState(() => removeCorrupted = v),
            ),
            FilterChip(
              label: const Text('Remove Orphaned'),
              selected: removeOrphaned,
              onSelected: (v) => setState(() => removeOrphaned = v),
            ),
            FilterChip(
              label: const Text('Remove Temporary'),
              selected: removeTemporary,
              onSelected: (v) => setState(() => removeTemporary = v),
            ),
          ],
        ),
        SizedBox(height: Dimensions.space12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _targetBytesCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Free Bytes (optional)',
                ),
              ),
            ),
            SizedBox(width: Dimensions.space12),
            ElevatedButton(
              onPressed: () {
                final target = int.tryParse(_targetBytesCtrl.text);
                context.read<CacheManagementBloc>().add(
                  CacheManagementCleanupRequested(
                    removeCorrupted: removeCorrupted,
                    removeOrphaned: removeOrphaned,
                    removeTemporary: removeTemporary,
                    targetFreeBytes: target,
                  ),
                );
              },
              child: const Text('Run Cleanup'),
            ),
          ],
        ),
        SizedBox(height: Dimensions.space8),
      ],
    );
  }
}
