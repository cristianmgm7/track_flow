import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_cache/domain/usecases/enhanced_download_manager.dart';

class DownloadManagerWidget extends StatelessWidget {
  const DownloadManagerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, DownloadStatus>>(
      stream: context.read<EnhancedDownloadManager>().downloadStatuses,
      builder: (context, snapshot) {
        final downloadStatuses = snapshot.data ?? {};
        final downloadManager = context.read<EnhancedDownloadManager>();
        final queueInfo = downloadManager.getQueueInfo();

        if (downloadStatuses.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No downloads',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Downloaded tracks will appear here',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Header with queue info and controls
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Downloads',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${queueInfo.totalTasks} total • ${queueInfo.completedCount} completed • ${queueInfo.downloadingCount} active',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  if (queueInfo.failedCount > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${queueInfo.failedCount} failed downloads',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Control buttons
                  Row(
                    children: [
                      if (queueInfo.downloadingCount > 0 || queueInfo.queuedCount > 0)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.stop, size: 16),
                          label: const Text('Cancel All'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            downloadManager.cancelAllDownloads();
                          },
                        ),
                      if (queueInfo.failedCount > 0) ...[
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Retry Failed'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[600],
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            downloadManager.retryFailedDownloads();
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Downloads list
            Expanded(
              child: ListView.builder(
                itemCount: downloadStatuses.length,
                itemBuilder: (context, index) {
                  final entry = downloadStatuses.entries.elementAt(index);
                  final trackId = entry.key;
                  final status = entry.value;
                  
                  return _DownloadItem(
                    trackId: trackId,
                    status: status,
                    downloadManager: downloadManager,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DownloadItem extends StatelessWidget {
  final String trackId;
  final DownloadStatus status;
  final EnhancedDownloadManager downloadManager;

  const _DownloadItem({
    required this.trackId,
    required this.status,
    required this.downloadManager,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DownloadProgressInfo>(
      stream: downloadManager.getDownloadProgress(trackId),
      builder: (context, progressSnapshot) {
        final progress = progressSnapshot.data;
        
        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[800]!,
                width: 0.5,
              ),
            ),
          ),
          child: ListTile(
            leading: _buildStatusIcon(),
            title: Text(
              progress?.trackName ?? 'Track $trackId',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontSize: 12,
                  ),
                ),
                if (status == DownloadStatus.downloading && progress != null) ...[
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress.progress,
                    backgroundColor: Colors.grey[800],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue[400]!,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(progress.progress * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
            trailing: _buildActionButton(),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;
    
    switch (status) {
      case DownloadStatus.queued:
        icon = Icons.schedule;
        color = Colors.blue;
        break;
      case DownloadStatus.downloading:
        icon = Icons.download;
        color = Colors.blue;
        break;
      case DownloadStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case DownloadStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
      case DownloadStatus.cancelled:
        icon = Icons.cancel;
        color = Colors.grey;
        break;
      case DownloadStatus.notStarted:
        icon = Icons.download_outlined;
        color = Colors.grey;
        break;
    }

    Widget iconWidget = Icon(icon, color: color, size: 24);

    if (status == DownloadStatus.downloading) {
      iconWidget = SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    return iconWidget;
  }

  String _getStatusText() {
    switch (status) {
      case DownloadStatus.queued:
        return 'Queued for download';
      case DownloadStatus.downloading:
        return 'Downloading...';
      case DownloadStatus.completed:
        return 'Download complete';
      case DownloadStatus.failed:
        return 'Download failed';
      case DownloadStatus.cancelled:
        return 'Download cancelled';
      case DownloadStatus.notStarted:
        return 'Not started';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case DownloadStatus.queued:
        return Colors.blue;
      case DownloadStatus.downloading:
        return Colors.blue;
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.failed:
        return Colors.red;
      case DownloadStatus.cancelled:
        return Colors.grey;
      case DownloadStatus.notStarted:
        return Colors.grey;
    }
  }

  Widget? _buildActionButton() {
    switch (status) {
      case DownloadStatus.queued:
      case DownloadStatus.downloading:
        return IconButton(
          icon: const Icon(Icons.close, size: 20),
          color: Colors.grey[400],
          onPressed: () {
            downloadManager.cancelDownload(trackId);
          },
        );
      case DownloadStatus.failed:
        return IconButton(
          icon: const Icon(Icons.refresh, size: 20),
          color: Colors.orange,
          onPressed: () {
            // Would need to implement retry for individual track
            downloadManager.retryFailedDownloads();
          },
        );
      default:
        return null;
    }
  }
}

// Helper function to show download manager as modal bottom sheet
void showDownloadManager(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: const DownloadManagerWidget(),
    ),
  );
}