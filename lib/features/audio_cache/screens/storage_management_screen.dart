import 'package:flutter/material.dart';
import 'package:trackflow/features/audio_cache/widgets/storage_stats_widget.dart';
import 'package:trackflow/features/audio_cache/widgets/cached_tracks_manager.dart';

class StorageManagementScreen extends StatelessWidget {
  const StorageManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storage Management'), elevation: 0),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Storage usage overview
            StorageStatsWidget(),

            SizedBox(height: 16),

            // TODO: Reimplement active downloads widget
            // DownloadQueueWidget(),
            SizedBox(height: 16),

            // Cached tracks management
            CachedTracksManager(),
          ],
        ),
      ),
    );
  }
}
