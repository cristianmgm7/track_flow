import 'package:flutter/material.dart';
import 'package:trackflow/features/audio_cache/domain/usecases/enhanced_download_manager.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/core/di/injection.dart';

class BatchDownloadButton extends StatefulWidget {
  final List<AudioTrack> tracks;
  final String buttonText;
  final DownloadPriority priority;
  final VoidCallback? onDownloadStarted;
  final VoidCallback? onDownloadCompleted;

  const BatchDownloadButton({
    Key? key,
    required this.tracks,
    this.buttonText = 'Download All',
    this.priority = DownloadPriority.normal,
    this.onDownloadStarted,
    this.onDownloadCompleted,
  }) : super(key: key);

  @override
  State<BatchDownloadButton> createState() => _BatchDownloadButtonState();
}

class _BatchDownloadButtonState extends State<BatchDownloadButton> {
  late final EnhancedDownloadManager _downloadManager;
  bool _isDownloading = false;
  Map<String, DownloadStatus> _trackStatuses = {};
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _downloadManager = sl<EnhancedDownloadManager>();
    _initializeStatuses();
    _subscribeToUpdates();
  }

  void _initializeStatuses() {
    for (final track in widget.tracks) {
      final trackId = track.id.value;
      _trackStatuses[trackId] = _downloadManager.getDownloadStatus(trackId);
    }
    _updateCompletedCount();
  }

  void _subscribeToUpdates() {
    _downloadManager.downloadStatuses.listen((statuses) {
      setState(() {
        for (final track in widget.tracks) {
          final trackId = track.id.value;
          _trackStatuses[trackId] = statuses[trackId] ?? DownloadStatus.notStarted;
        }
        _updateCompletedCount();
        _checkIfDownloadingComplete();
      });
    });
  }

  void _updateCompletedCount() {
    _completedCount = _trackStatuses.values
        .where((status) => status == DownloadStatus.completed)
        .length;
  }

  void _checkIfDownloadingComplete() {
    if (_isDownloading) {
      final hasActiveDownloads = _trackStatuses.values.any(
        (status) => status == DownloadStatus.downloading || status == DownloadStatus.queued,
      );
      
      if (!hasActiveDownloads) {
        _isDownloading = false;
        if (widget.onDownloadCompleted != null) {
          widget.onDownloadCompleted!();
        }
      }
    }
  }

  Future<void> _startBatchDownload() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    if (widget.onDownloadStarted != null) {
      widget.onDownloadStarted!();
    }

    final requests = widget.tracks
        .where((track) => _trackStatuses[track.id.value] != DownloadStatus.completed)
        .map((track) => DownloadTaskRequest(
              trackId: track.id.value,
              trackUrl: track.url,
              trackName: track.name,
              priority: widget.priority,
            ))
        .toList();

    if (requests.isNotEmpty) {
      final result = await _downloadManager.downloadTracks(requests);
      result.fold(
        (failure) {
          setState(() {
            _isDownloading = false;
          });
          _showErrorSnackBar(failure.message);
        },
        (_) => null,
      );
    } else {
      setState(() {
        _isDownloading = false;
      });
      _showAllDownloadedSnackBar();
    }
  }

  Future<void> _cancelBatchDownload() async {
    final result = await _downloadManager.cancelAllDownloads();
    result.fold(
      (failure) => _showErrorSnackBar(failure.message),
      (_) => setState(() {
        _isDownloading = false;
      }),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Download error: $message'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showAllDownloadedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All tracks are already downloaded'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pendingCount = widget.tracks.length - _completedCount;
    final hasCompletedTracks = _completedCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: _isDownloading ? _cancelBatchDownload : _startBatchDownload,
          icon: _isDownloading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(
                  _completedCount == widget.tracks.length
                      ? Icons.check_circle
                      : Icons.download,
                ),
          label: Text(
            _isDownloading
                ? 'Cancel Downloads'
                : _completedCount == widget.tracks.length
                    ? 'All Downloaded'
                    : widget.buttonText,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isDownloading
                ? Colors.red
                : _completedCount == widget.tracks.length
                    ? Colors.green
                    : theme.primaryColor,
          ),
        ),
        if (widget.tracks.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            hasCompletedTracks
                ? '$_completedCount of ${widget.tracks.length} tracks downloaded'
                : '${widget.tracks.length} tracks available for download',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
          if (_isDownloading && pendingCount > 0) ...[
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: _completedCount / widget.tracks.length,
              backgroundColor: theme.primaryColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
          ],
        ],
      ],
    );
  }
}