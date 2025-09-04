import 'package:equatable/equatable.dart';
import 'cached_audio.dart';

class CacheMetadata extends Equatable {
  const CacheMetadata({
    required this.trackId,
    required this.referenceCount,
    required this.lastAccessed,
    required this.references,
    required this.status,
    required this.downloadAttempts,
    this.lastDownloadAttempt,
    this.failureReason,
    this.originalUrl,
  });

  final String trackId;
  final int referenceCount;
  final DateTime lastAccessed;
  final List<String> references;
  final CacheStatus status;
  final int downloadAttempts;
  final DateTime? lastDownloadAttempt;
  final String? failureReason;
  final String? originalUrl;

  bool get isDownloadable => downloadAttempts < 3;
  
  bool get shouldRetry {
    if (status != CacheStatus.failed) return false;
    if (!isDownloadable) return false;
    if (lastDownloadAttempt == null) return true;
    
    // Wait at least 5 minutes before retry
    final timeSinceLastAttempt = DateTime.now().difference(lastDownloadAttempt!);
    return timeSinceLastAttempt.inMinutes >= 5;
  }

  CacheMetadata incrementDownloadAttempts({String? failureReason}) {
    return copyWith(
      downloadAttempts: downloadAttempts + 1,
      lastDownloadAttempt: DateTime.now(),
      failureReason: failureReason,
      status: CacheStatus.failed,
    );
  }

  CacheMetadata markAsDownloading() {
    return copyWith(
      status: CacheStatus.downloading,
      lastDownloadAttempt: DateTime.now(),
    );
  }

  CacheMetadata markAsCompleted() {
    return copyWith(
      status: CacheStatus.cached,
      failureReason: null,
    );
  }

  CacheMetadata markAsCorrupted() {
    return copyWith(status: CacheStatus.corrupted);
  }

  CacheMetadata updateLastAccessed() {
    return copyWith(lastAccessed: DateTime.now());
  }

  CacheMetadata copyWith({
    String? trackId,
    int? referenceCount,
    DateTime? lastAccessed,
    List<String>? references,
    CacheStatus? status,
    int? downloadAttempts,
    DateTime? lastDownloadAttempt,
    String? failureReason,
    String? originalUrl,
  }) {
    return CacheMetadata(
      trackId: trackId ?? this.trackId,
      referenceCount: referenceCount ?? this.referenceCount,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      references: references ?? this.references,
      status: status ?? this.status,
      downloadAttempts: downloadAttempts ?? this.downloadAttempts,
      lastDownloadAttempt: lastDownloadAttempt ?? this.lastDownloadAttempt,
      failureReason: failureReason ?? this.failureReason,
      originalUrl: originalUrl ?? this.originalUrl,
    );
  }

  @override
  List<Object?> get props => [
    trackId,
    referenceCount,
    lastAccessed,
    references,
    status,
    downloadAttempts,
    lastDownloadAttempt,
    failureReason,
    originalUrl,
  ];
}