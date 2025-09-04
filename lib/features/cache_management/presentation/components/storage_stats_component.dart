import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../audio_cache/domain/services/cache_maintenance_service.dart';
import '../../../audio_cache/domain/entities/cached_audio.dart';

/// Component for displaying cache storage statistics
class StorageStatsComponent extends StatefulWidget {
  const StorageStatsComponent({super.key});

  @override
  State<StorageStatsComponent> createState() => _StorageStatsComponentState();
}

class _StorageStatsComponentState extends State<StorageStatsComponent> {
  late final CacheMaintenanceService _cacheMaintenanceService;

  List<CachedAudio> _cachedTracks = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cacheMaintenanceService = sl<CacheMaintenanceService>();
    _loadStats();
  }

  Future<void> _loadStats() async {
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
        _errorMessage = 'Failed to load stats: $e';
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

  Map<String, int> _getQualityStats() {
    final stats = <String, int>{};
    for (final track in _cachedTracks) {
      final quality = track.quality.name;
      stats[quality] = (stats[quality] ?? 0) + 1;
    }
    return stats;
  }

  Map<String, int> _getStatusStats() {
    final stats = <String, int>{};
    for (final track in _cachedTracks) {
      final status = track.status.name;
      stats[status] = (stats[status] ?? 0) + 1;
    }
    return stats;
  }

  int _getTotalSize() {
    return _cachedTracks.fold(0, (sum, track) => sum + track.fileSizeBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Statistics'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStats),
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
            ElevatedButton(onPressed: _loadStats, child: const Text('Retry')),
          ],
        ),
      );
    }

    final totalSize = _getTotalSize();
    final qualityStats = _getQualityStats();
    final statusStats = _getStatusStats();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(totalSize),
          const SizedBox(height: 16),
          _buildQualityStatsCard(qualityStats),
          const SizedBox(height: 16),
          _buildStatusStatsCard(statusStats),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int totalSize) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Total tracks: ${_cachedTracks.length}'),
            Text('Total size: ${_formatBytes(totalSize)}'),
            Text(
              'Average size: ${_cachedTracks.isNotEmpty ? _formatBytes(totalSize ~/ _cachedTracks.length) : '0 B'}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityStatsCard(Map<String, int> qualityStats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quality Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...qualityStats.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key.toUpperCase()),
                    Text('${entry.value} tracks'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStatsCard(Map<String, int> statusStats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...statusStats.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key.toUpperCase()),
                    Text('${entry.value} tracks'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
