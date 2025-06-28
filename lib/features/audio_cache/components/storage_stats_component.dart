import 'package:flutter/material.dart';
import 'package:trackflow/features/audio_cache/shared/domain/services/enhanced_storage_management_service.dart';
import 'package:trackflow/features/audio_cache/shared/domain/entities/enhanced_storage_types.dart';
import 'package:trackflow/core/di/injection.dart';

class StorageStatsWidgetComponent extends StatefulWidget {
  final bool showHeader;
  final bool showActions;

  const StorageStatsWidgetComponent({
    super.key,
    this.showHeader = true,
    this.showActions = true,
  });

  @override
  State<StorageStatsWidgetComponent> createState() =>
      _StorageStatsWidgetState();
}

class _StorageStatsWidgetState extends State<StorageStatsWidgetComponent> {
  late final EnhancedStorageManagementService _storageService;
  EnhancedStorageStats? _currentStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _storageService = sl<EnhancedStorageManagementService>();
    _loadStorageStats();
    _subscribeToUpdates();
  }

  Future<void> _loadStorageStats() async {
    try {
      final result = await _storageService.getStorageStats();
      if (mounted) {
        setState(() {
          _currentStats = result.fold((failure) => null, (stats) => stats);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _subscribeToUpdates() {
    _storageService.watchStorageStats().listen((stats) {
      if (mounted) {
        setState(() {
          _currentStats = stats;
        });
      }
    });
  }

  Future<void> _performCleanup() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final result = await _storageService.performCleanup();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        result.fold(
          (failure) => _showErrorSnackBar('Cleanup failed: ${failure.message}'),
          (cleanupResult) => _showCleanupResult(cleanupResult),
        );
        await _loadStorageStats();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Cleanup failed: $e');
      }
    }
  }

  Future<void> _clearAllCache() async {
    final confirmed = await _showConfirmDialog(
      'Clear All Cache',
      'This will remove all downloaded tracks. Are you sure?',
    );

    if (confirmed) {
      try {
        setState(() {
          _isLoading = true;
        });

        final result = await _storageService.clearAllCache();

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          result.fold(
            (failure) =>
                _showErrorSnackBar('Failed to clear cache: ${failure.message}'),
            (_) => _showSuccessSnackBar('All cache cleared successfully'),
          );
          await _loadStorageStats();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showErrorSnackBar('Failed to clear cache: $e');
        }
      }
    }
  }

  void _showCleanupResult(EnhancedCleanupResult result) {
    final bytesFreedMB = (result.totalSpaceFreed / (1024 * 1024))
        .toStringAsFixed(1);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Cleanup complete: ${bytesFreedMB}MB freed, ${result.totalFilesRemoved} files removed',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
    return result ?? false;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_currentStats == null) {
      return const SizedBox.shrink();
    }

    final stats = _currentStats!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showHeader) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Storage Usage',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (stats.isLowOnSpace)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            stats.isCriticallyLow ? Colors.red : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        stats.isCriticallyLow ? 'CRITICAL' : 'LOW SPACE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Storage usage bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cache Usage',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${_formatBytes(stats.totalCacheSize)} / ${_formatBytes(stats.totalSpace)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: stats.cacheUsagePercentage,
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    stats.isLowOnSpace ? Colors.red : theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(stats.cacheUsagePercentage * 100).toStringAsFixed(1)}% used',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Stats grid
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Cached Tracks',
                    '${stats.cachedTracksCount}',
                    Icons.music_note,
                    theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Available Space',
                    _formatBytes(stats.availableSpace),
                    Icons.storage,
                    theme,
                  ),
                ),
              ],
            ),

            if (stats.corruptedFilesCount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${stats.corruptedFilesCount} corrupted files detected',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (widget.showActions) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _performCleanup,
                      icon: const Icon(Icons.cleaning_services),
                      label: const Text('Auto Cleanup'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _clearAllCache,
                      icon: const Icon(Icons.delete_sweep),
                      label: const Text('Clear All'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: theme.primaryColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
