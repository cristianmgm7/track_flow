import 'package:flutter/material.dart';
import 'package:trackflow/features/audio_cache/presentation/components/storage_stats_widget.dart';
import 'package:trackflow/features/audio_cache/presentation/components/cached_tracks_manager.dart';
import 'package:trackflow/features/audio_cache/presentation/components/download_queue_widget.dart';

class StorageManagementScreen extends StatelessWidget {
  const StorageManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Management'),
        elevation: 0,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Storage usage overview
            StorageStatsWidget(),
            
            SizedBox(height: 16),
            
            // Active downloads
            DownloadQueueWidget(),
            
            SizedBox(height: 16),
            
            // Cached tracks management
            CachedTracksManager(),
          ],
        ),
      ),
    );
  }
}