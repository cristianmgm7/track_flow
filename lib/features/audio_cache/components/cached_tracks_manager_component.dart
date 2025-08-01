import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../shared/domain/services/cache_maintenance_service.dart';
import '../shared/domain/entities/cached_audio.dart';

/// Component for managing cached tracks
class CachedTracksManagerComponent extends StatefulWidget {
  const CachedTracksManagerComponent({super.key});

  @override
  State<CachedTracksManagerComponent> createState() =>
      _CachedTracksManagerComponentState();
}

class _CachedTracksManagerComponentState
    extends State<CachedTracksManagerComponent> {
  late final CacheMaintenanceService _cacheMaintenanceService;

  List<CachedAudio> _cachedTracks = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cacheMaintenanceService = sl<CacheMaintenanceService>();
    _loadCachedTracks();
  }

  Future<void> _loadCachedTracks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _cacheMaintenanceService.getAllCachedAudios();
      result.fold(
        (failure) {
          setState(() {
            _errorMessage = failure.message;
            _isLoading = false;
          });
        },
        (tracks) {
          setState(() {
            _cachedTracks = tracks;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load cached tracks: $e';
        _isLoading = false;
      });
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cached Tracks Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCachedTracks,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCachedTracks,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_cachedTracks.isEmpty) {
      return const Center(child: Text('No cached tracks found'));
    }

    return ListView.builder(
      itemCount: _cachedTracks.length,
      itemBuilder: (context, index) {
        final track = _cachedTracks[index];
        return ListTile(
          title: Text(track.trackId),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Size: ${_formatBytes(track.fileSizeBytes)}'),
              Text('Created: ${track.cachedAt.toString()}'),
              Text('Status: ${track.status.name}'),
              Text('Quality: ${track.quality.name}'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () => _playTrack(track),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteTrack(track),
              ),
            ],
          ),
        );
      },
    );
  }

  void _playTrack(CachedAudio track) {
    // TODO: Implement track playback
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Playing ${track.trackId}')));
  }

  Future<void> _deleteTrack(CachedAudio track) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Track'),
            content: Text('Are you sure you want to delete ${track.trackId}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      // Note: deleteAudioFile is still in CacheStorageRepository
      // You'll need to inject it separately or use a different approach
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete functionality needs to be updated')),
      );
    }
  }
}
