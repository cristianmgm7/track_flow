import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_cache/domain/usecases/enhanced_download_manager.dart';
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart';
import 'package:trackflow/core/di/injection.dart';

class DownloadButton extends StatefulWidget {
  final String trackId;
  final String trackUrl;
  final String trackName;
  final DownloadPriority priority;
  final IconData? customIcon;
  final Color? color;
  final double? size;
  final VoidCallback? onDownloadStarted;
  final VoidCallback? onDownloadCompleted;

  const DownloadButton({
    Key? key,
    required this.trackId,
    required this.trackUrl,
    required this.trackName,
    this.priority = DownloadPriority.normal,
    this.customIcon,
    this.color,
    this.size = 24.0,
    this.onDownloadStarted,
    this.onDownloadCompleted,
  }) : super(key: key);

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  late final EnhancedDownloadManager _downloadManager;
  late final AudioSourceResolver _audioSourceResolver;
  
  DownloadStatus _currentStatus = DownloadStatus.notStarted;
  double _progress = 0.0;
  CacheStatus _cacheStatus = CacheStatus.notCached;

  @override
  void initState() {
    super.initState();
    _downloadManager = sl<EnhancedDownloadManager>();
    _audioSourceResolver = sl<AudioSourceResolver>();
    _initializeStatus();
    _subscribeToUpdates();
  }

  Future<void> _initializeStatus() async {
    _currentStatus = _downloadManager.getDownloadStatus(widget.trackId);
    _cacheStatus = await _audioSourceResolver.getCacheStatus(widget.trackUrl);
    
    if (mounted) {
      setState(() {});
    }
  }

  void _subscribeToUpdates() {
    // Listen to download status changes
    _downloadManager.downloadStatuses.listen((statuses) {
      final newStatus = statuses[widget.trackId] ?? DownloadStatus.notStarted;
      if (newStatus != _currentStatus) {
        setState(() {
          _currentStatus = newStatus;
        });
        
        if (newStatus == DownloadStatus.downloading && widget.onDownloadStarted != null) {
          widget.onDownloadStarted!();
        } else if (newStatus == DownloadStatus.completed && widget.onDownloadCompleted != null) {
          widget.onDownloadCompleted!();
        }
      }
    });

    // Listen to download progress
    _downloadManager.getDownloadProgress(widget.trackId).listen((progressInfo) {
      setState(() {
        _progress = progressInfo.progress;
      });
    });
  }

  Future<void> _handleDownloadAction() async {
    switch (_currentStatus) {
      case DownloadStatus.notStarted:
        await _startDownload();
        break;
      case DownloadStatus.downloading:
      case DownloadStatus.queued:
        await _cancelDownload();
        break;
      case DownloadStatus.failed:
        await _retryDownload();
        break;
      case DownloadStatus.completed:
        _showDownloadedSnackBar();
        break;
      case DownloadStatus.cancelled:
        await _startDownload();
        break;
    }
  }

  Future<void> _startDownload() async {
    final result = await _downloadManager.downloadTrack(
      trackId: widget.trackId,
      trackUrl: widget.trackUrl,
      trackName: widget.trackName,
      priority: widget.priority,
    );

    result.fold(
      (failure) => _showErrorSnackBar(failure.message),
      (_) => null,
    );
  }

  Future<void> _cancelDownload() async {
    final result = await _downloadManager.cancelDownload(widget.trackId);
    result.fold(
      (failure) => _showErrorSnackBar(failure.message),
      (_) => null,
    );
  }

  Future<void> _retryDownload() async {
    await _startDownload();
  }

  void _showDownloadedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.trackName} is already downloaded'),
        duration: const Duration(seconds: 2),
      ),
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleDownloadAction,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: widget.size! + 8,
        height: widget.size! + 8,
        padding: const EdgeInsets.all(4),
        child: _buildIcon(),
      ),
    );
  }

  Widget _buildIcon() {
    final color = widget.color ?? Theme.of(context).primaryColor;
    
    switch (_currentStatus) {
      case DownloadStatus.notStarted:
      case DownloadStatus.cancelled:
        return Icon(
          widget.customIcon ?? Icons.download,
          color: color.withOpacity(0.7),
          size: widget.size,
        );
        
      case DownloadStatus.queued:
        return Icon(
          Icons.schedule,
          color: Colors.orange,
          size: widget.size,
        );
        
      case DownloadStatus.downloading:
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: CircularProgressIndicator(
                value: _progress,
                strokeWidth: 2,
                color: color,
                backgroundColor: color.withOpacity(0.2),
              ),
            ),
            Icon(
              Icons.close,
              color: color,
              size: widget.size! * 0.6,
            ),
          ],
        );
        
      case DownloadStatus.completed:
        return Icon(
          Icons.download_done,
          color: Colors.green,
          size: widget.size,
        );
        
      case DownloadStatus.failed:
        return Icon(
          Icons.refresh,
          color: Colors.red,
          size: widget.size,
        );
    }
  }
}