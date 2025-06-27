import 'package:flutter/material.dart';
import 'package:trackflow/features/audio_cache/domain/services/storage_management_service.dart';
import 'package:trackflow/core/di/injection.dart';

class CachedTracksManager extends StatefulWidget {
  final bool showHeader;
  final int maxVisibleItems;

  const CachedTracksManager({
    Key? key,
    this.showHeader = true,
    this.maxVisibleItems = 10,
  }) : super(key: key);

  @override
  State<CachedTracksManager> createState() => _CachedTracksManagerState();
}

class _CachedTracksManagerState extends State<CachedTracksManager> {
  late final StorageManagementService _storageService;
  List<CachedTrackInfo> _cachedTracks = [];
  List<CachedTrackInfo> _selectedTracks = [];
  bool _isLoading = true;
  bool _isSelectionMode = false;
  String _sortBy = 'lastAccessed'; // lastAccessed, cachedAt, fileSize, name

  @override
  void initState() {
    super.initState();
    _storageService = sl<StorageManagementService>();
    _loadCachedTracks();
  }

  Future<void> _loadCachedTracks() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final tracks = await _storageService.getCachedTracks();
      
      if (mounted) {
        setState(() {
          _cachedTracks = tracks;
          _sortTracks();
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

  void _sortTracks() {
    switch (_sortBy) {
      case 'lastAccessed':
        _cachedTracks.sort((a, b) => b.lastAccessed.compareTo(a.lastAccessed));
        break;
      case 'cachedAt':
        _cachedTracks.sort((a, b) => b.cachedAt.compareTo(a.cachedAt));
        break;
      case 'fileSize':
        _cachedTracks.sort((a, b) => b.fileSizeBytes.compareTo(a.fileSizeBytes));
        break;
      case 'name':
        _cachedTracks.sort((a, b) => a.trackName.compareTo(b.trackName));
        break;
    }
  }

  void _toggleSelection(CachedTrackInfo track) {
    setState(() {
      if (_selectedTracks.contains(track)) {
        _selectedTracks.remove(track);
      } else {
        _selectedTracks.add(track);
      }

      if (_selectedTracks.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _enterSelectionMode(CachedTrackInfo track) {
    setState(() {
      _isSelectionMode = true;
      _selectedTracks = [track];
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedTracks.clear();
    });
  }

  void _selectAll() {
    setState(() {
      _selectedTracks = List.from(_cachedTracks);
    });
  }

  Future<void> _removeSelectedTracks() async {
    if (_selectedTracks.isEmpty) return;

    final confirmed = await _showConfirmDialog(
      'Remove Tracks',
      'Remove ${_selectedTracks.length} cached tracks?',
    );

    if (confirmed) {
      try {
        final trackUrls = _selectedTracks.map((t) => t.trackUrl).toList();
        await _storageService.removeCachedTracks(trackUrls);
        
        _showSuccessSnackBar('${_selectedTracks.length} tracks removed');
        _exitSelectionMode();
        await _loadCachedTracks();
      } catch (e) {
        _showErrorSnackBar('Failed to remove tracks: $e');
      }
    }
  }

  Future<void> _cleanupCorrupted() async {
    try {
      await _storageService.cleanupCorruptedFiles();
      _showSuccessSnackBar('Corrupted files cleaned up');
      await _loadCachedTracks();
    } catch (e) {
      _showErrorSnackBar('Failed to cleanup corrupted files: $e');
    }
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_cachedTracks.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.music_off, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                'No cached tracks',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final corruptedCount = _cachedTracks.where((t) => t.isCorrupted).length;
    final visibleTracks = _cachedTracks.take(widget.maxVisibleItems).toList();

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
                    _isSelectionMode 
                        ? '${_selectedTracks.length} selected'
                        : 'Cached Tracks (${_cachedTracks.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isSelectionMode)
                    Row(
                      children: [
                        IconButton(
                          onPressed: _selectAll,
                          icon: const Icon(Icons.select_all),
                          tooltip: 'Select all',
                        ),
                        IconButton(
                          onPressed: _removeSelectedTracks,
                          icon: const Icon(Icons.delete),
                          tooltip: 'Remove selected',
                        ),
                        IconButton(
                          onPressed: _exitSelectionMode,
                          icon: const Icon(Icons.close),
                          tooltip: 'Exit selection',
                        ),
                      ],
                    )
                  else
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        setState(() {
                          _sortBy = value;
                          _sortTracks();
                        });
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'lastAccessed',
                          child: Text('Sort by Last Accessed'),
                        ),
                        const PopupMenuItem(
                          value: 'cachedAt',
                          child: Text('Sort by Cached Date'),
                        ),
                        const PopupMenuItem(
                          value: 'fileSize',
                          child: Text('Sort by File Size'),
                        ),
                        const PopupMenuItem(
                          value: 'name',
                          child: Text('Sort by Name'),
                        ),
                      ],
                      child: const Icon(Icons.sort),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            if (corruptedCount > 0) ...[
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
                        '$corruptedCount corrupted files found',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: _cleanupCorrupted,
                      child: const Text('Cleanup'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Track list
            ...visibleTracks.map((track) => _buildTrackItem(track, theme)),

            if (_cachedTracks.length > widget.maxVisibleItems) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '+ ${_cachedTracks.length - widget.maxVisibleItems} more tracks...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrackItem(CachedTrackInfo track, ThemeData theme) {
    final isSelected = _selectedTracks.contains(track);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? theme.primaryColor.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: theme.primaryColor) : null,
      ),
      child: ListTile(
        leading: _isSelectionMode
            ? Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleSelection(track),
              )
            : Icon(
                track.isCorrupted ? Icons.error : Icons.music_note,
                color: track.isCorrupted ? Colors.red : theme.primaryColor,
              ),
        title: Text(
          track.trackName,
          style: TextStyle(
            color: track.isCorrupted ? Colors.red : null,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Size: ${_formatBytes(track.fileSizeBytes)}'),
            Text('Last accessed: ${_formatDateTime(track.lastAccessed)}'),
          ],
        ),
        trailing: _isSelectionMode
            ? null
            : IconButton(
                onPressed: () => _enterSelectionMode(track),
                icon: const Icon(Icons.more_vert),
              ),
        onTap: _isSelectionMode
            ? () => _toggleSelection(track)
            : null,
        onLongPress: _isSelectionMode
            ? null
            : () => _enterSelectionMode(track),
      ),
    );
  }
}