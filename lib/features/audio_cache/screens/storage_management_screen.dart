import 'package:flutter/material.dart';
import 'package:trackflow/features/audio_cache/components/storage_stats_component.dart';
import 'package:trackflow/features/audio_cache/components/cached_tracks_manager_component.dart';

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
            StorageStatsWidgetComponent(),

            SizedBox(height: 16),

            // TODO: Reimplement active downloads widget
            // DownloadQueueWidget(),
            SizedBox(height: 16),

            // Cached tracks management
            CachedTracksManagerComponent(),
          ],
        ),
      ),
    );
  }
}
