import 'package:flutter/material.dart';
import '../../../audio_cache/components/cached_tracks_manager_component.dart';

class StorageManagementScreen extends StatelessWidget {
  const StorageManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storage Management')),
      body: const CachedTracksManagerComponent(),
    );
  }
}
