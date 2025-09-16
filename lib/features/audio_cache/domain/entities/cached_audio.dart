import 'package:equatable/equatable.dart';

enum AudioQuality { low, medium, high, lossless }

enum CacheStatus { notCached, downloading, cached, failed, corrupted }

class CachedAudio extends Equatable {
  const CachedAudio({
    required this.trackId,
    required this.versionId,
    required this.filePath,
    required this.fileSizeBytes,
    required this.cachedAt,
    required this.checksum,
    required this.quality,
    required this.status,
  });

  final String trackId;
  final String versionId;
  final String filePath;
  final int fileSizeBytes;
  final DateTime cachedAt;
  final String checksum;
  final AudioQuality quality;
  final CacheStatus status;

  CachedAudio copyWith({
    String? trackId,
    String? versionId,
    String? filePath,
    int? fileSizeBytes,
    DateTime? cachedAt,
    String? checksum,
    AudioQuality? quality,
    CacheStatus? status,
  }) {
    return CachedAudio(
      trackId: trackId ?? this.trackId,
      versionId: versionId ?? this.versionId,
      filePath: filePath ?? this.filePath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      cachedAt: cachedAt ?? this.cachedAt,
      checksum: checksum ?? this.checksum,
      quality: quality ?? this.quality,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    trackId,
    versionId,
    filePath,
    fileSizeBytes,
    cachedAt,
    checksum,
    quality,
    status,
  ];
}
