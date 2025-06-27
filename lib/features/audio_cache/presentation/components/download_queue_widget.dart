import 'package:flutter/material.dart';
import 'package:trackflow/features/audio_cache/domain/usecases/enhanced_download_manager.dart';
import 'package:trackflow/core/di/injection.dart';

class DownloadQueueWidget extends StatefulWidget {
  final bool showHeader;
  final int maxVisibleItems;

  const DownloadQueueWidget({
    Key? key,
    this.showHeader = true,
    this.maxVisibleItems = 5,
  }) : super(key: key);

  @override
  State<DownloadQueueWidget> createState() => _DownloadQueueWidgetState();
}

class _DownloadQueueWidgetState extends State<DownloadQueueWidget> {
  late final EnhancedDownloadManager _downloadManager;
  QueueInfo _queueInfo = const QueueInfo(
    queuedCount: 0,
    downloadingCount: 0,
    completedCount: 0,
    failedCount: 0,
    totalTasks: 0,
  );
  Map<String, DownloadStatus> _downloadStatuses = {};

  @override
  void initState() {
    super.initState();
    _downloadManager = sl<EnhancedDownloadManager>();
    _updateQueueInfo();
    _subscribeToUpdates();
  }

  void _updateQueueInfo() {
    setState(() {
      _queueInfo = _downloadManager.getQueueInfo();
    });
  }

  void _subscribeToUpdates() {
    _downloadManager.downloadStatuses.listen((statuses) {
      setState(() {
        _downloadStatuses = Map.from(statuses);
        _queueInfo = _downloadManager.getQueueInfo();
      });
    });
  }

  Future<void> _retryFailedDownloads() async {
    final result = await _downloadManager.retryFailedDownloads();
    result.fold(
      (failure) => _showErrorSnackBar(failure.message),
      (_) => _showSuccessSnackBar('Retrying failed downloads'),
    );
  }

  Future<void> _cancelAllDownloads() async {
    final result = await _downloadManager.cancelAllDownloads();
    result.fold(
      (failure) => _showErrorSnackBar(failure.message),
      (_) => _showSuccessSnackBar('All downloads cancelled'),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $message'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_queueInfo.totalTasks == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(8),
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
                    'Download Queue',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      if (_queueInfo.failedCount > 0)
                        IconButton(
                          onPressed: _retryFailedDownloads,
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Retry failed downloads',
                          iconSize: 20,
                        ),
                      if (_queueInfo.downloadingCount > 0 || _queueInfo.queuedCount > 0)
                        IconButton(
                          onPressed: _cancelAllDownloads,
                          icon: const Icon(Icons.stop),
                          tooltip: 'Cancel all downloads',
                          iconSize: 20,
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            _buildQueueStats(theme),
            if (_queueInfo.downloadingCount > 0 || _queueInfo.queuedCount > 0) ...[
              const SizedBox(height: 12),
              _buildProgressIndicator(theme),
            ],
            if (_downloadStatuses.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildActiveDownloadsList(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQueueStats(ThemeData theme) {
    return Row(
      children: [
        _buildStatChip(
          'Completed',
          _queueInfo.completedCount,
          Colors.green,
          theme,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          'Downloading',
          _queueInfo.downloadingCount,
          Colors.blue,
          theme,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          'Queued',
          _queueInfo.queuedCount,
          Colors.orange,
          theme,
        ),
        if (_queueInfo.failedCount > 0) ...[
          const SizedBox(width: 8),
          _buildStatChip(
            'Failed',
            _queueInfo.failedCount,
            Colors.red,
            theme,
          ),
        ],
      ],
    );
  }

  Widget _buildStatChip(String label, int count, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: $count',
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    final totalActive = _queueInfo.downloadingCount + _queueInfo.queuedCount;
    final progress = totalActive > 0 
        ? (_queueInfo.completedCount / (_queueInfo.completedCount + totalActive))
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overall Progress',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
        ),
        const SizedBox(height: 4),
        Text(
          '${_queueInfo.completedCount} of ${_queueInfo.totalTasks} completed',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveDownloadsList(ThemeData theme) {
    final activeDownloads = _downloadStatuses.entries
        .where((entry) => 
            entry.value == DownloadStatus.downloading || 
            entry.value == DownloadStatus.queued)
        .take(widget.maxVisibleItems)
        .toList();

    if (activeDownloads.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Downloads',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...activeDownloads.map((entry) => _buildDownloadItem(
          entry.key,
          entry.value,
          theme,
        )),
        if (_downloadStatuses.length > widget.maxVisibleItems)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+ ${_downloadStatuses.length - widget.maxVisibleItems} more...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDownloadItem(String trackId, DownloadStatus status, ThemeData theme) {
    IconData icon;
    Color iconColor;

    switch (status) {
      case DownloadStatus.downloading:
        icon = Icons.download;
        iconColor = Colors.blue;
        break;
      case DownloadStatus.queued:
        icon = Icons.schedule;
        iconColor = Colors.orange;
        break;
      default:
        icon = Icons.help;
        iconColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Track $trackId',
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            status.name.toUpperCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: iconColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}