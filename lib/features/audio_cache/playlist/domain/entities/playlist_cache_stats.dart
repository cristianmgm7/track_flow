import 'package:equatable/equatable.dart';

class PlaylistCacheStats extends Equatable {
  const PlaylistCacheStats({
    required this.playlistId,
    required this.totalTracks,
    required this.cachedTracks,
    required this.downloadingTracks,
    required this.failedTracks,
    required this.cachePercentage,
  });

  final String playlistId;
  final int totalTracks;
  final int cachedTracks;
  final int downloadingTracks;
  final int failedTracks;
  final double cachePercentage;

  bool get isFullyCached => cachedTracks == totalTracks;
  bool get hasDownloading => downloadingTracks > 0;
  bool get hasFailures => failedTracks > 0;
  bool get isPartiallyCached => cachedTracks > 0 && cachedTracks < totalTracks;
  bool get isNotCached => cachedTracks == 0;

  int get pendingTracks =>
      totalTracks - cachedTracks - downloadingTracks - failedTracks;

  String get statusDescription {
    if (isFullyCached) return 'Fully cached';
    if (hasDownloading) return 'Downloading...';
    if (isPartiallyCached) return 'Partially cached';
    return 'Not cached';
  }

  String get progressDescription => '$cachedTracks/$totalTracks tracks cached';

  CacheStatus get status {
    if (isFullyCached) return CacheStatus.fullyCached;
    if (hasDownloading) return CacheStatus.downloading;
    if (isPartiallyCached) return CacheStatus.partiallyCached;
    if (hasFailures) return CacheStatus.failed;
    return CacheStatus.notCached;
  }

  @override
  List<Object?> get props => [
        playlistId,
        totalTracks,
        cachedTracks,
        downloadingTracks,
        failedTracks,
        cachePercentage,
      ];

  PlaylistCacheStats copyWith({
    String? playlistId,
    int? totalTracks,
    int? cachedTracks,
    int? downloadingTracks,
    int? failedTracks,
    double? cachePercentage,
  }) {
    return PlaylistCacheStats(
      playlistId: playlistId ?? this.playlistId,
      totalTracks: totalTracks ?? this.totalTracks,
      cachedTracks: cachedTracks ?? this.cachedTracks,
      downloadingTracks: downloadingTracks ?? this.downloadingTracks,
      failedTracks: failedTracks ?? this.failedTracks,
      cachePercentage: cachePercentage ?? this.cachePercentage,
    );
  }
}

enum CacheStatus {
  notCached,
  downloading,
  partiallyCached,
  fullyCached,
  failed,
}