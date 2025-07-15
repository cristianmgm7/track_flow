import 'package:isar/isar.dart';
import '../../domain/entities/cached_audio.dart';
import '../../domain/entities/cache_metadata.dart';

part 'cached_audio_document_unified.g.dart';

@collection
class CachedAudioDocumentUnified {
  Id get isarId => fastHash(trackId);

  @Index(unique: true)
  late String trackId;

  // ===============================================
  // ARCHIVO FÍSICO
  // ===============================================
  late String filePath;
  late int fileSizeBytes;
  late DateTime cachedAt;
  late String checksum;

  @Enumerated(EnumType.name)
  late AudioQuality quality;

  // ===============================================
  // METADATA DE GESTIÓN
  // ===============================================
  @Enumerated(EnumType.name)
  late CacheStatus status;

  late int referenceCount;
  late DateTime lastAccessed;
  late List<String> references;
  late int downloadAttempts;

  DateTime? lastDownloadAttempt;
  String? failureReason;
  String? originalUrl;

  CachedAudioDocumentUnified();

  factory CachedAudioDocumentUnified.fromCachedAudio(CachedAudio audio) {
    return CachedAudioDocumentUnified()
      ..trackId = audio.trackId
      ..filePath = audio.filePath
      ..fileSizeBytes = audio.fileSizeBytes
      ..cachedAt = audio.cachedAt
      ..checksum = audio.checksum
      ..quality = audio.quality
      ..status = audio.status
      ..referenceCount =
          1 // Default reference count
      ..lastAccessed = DateTime.now()
      ..references = ['individual'] // Default reference
      ..downloadAttempts = 0
      ..lastDownloadAttempt = null
      ..failureReason = null
      ..originalUrl = null;
  }

  factory CachedAudioDocumentUnified.fromCacheMetadata(CacheMetadata metadata) {
    return CachedAudioDocumentUnified()
      ..trackId = metadata.trackId
      ..filePath =
          '' // Will be set when file is downloaded
      ..fileSizeBytes = 0
      ..cachedAt = DateTime.now()
      ..checksum = ''
      ..quality = AudioQuality.medium
      ..status = metadata.status
      ..referenceCount = metadata.referenceCount
      ..lastAccessed = metadata.lastAccessed
      ..references = List<String>.from(metadata.references)
      ..downloadAttempts = metadata.downloadAttempts
      ..lastDownloadAttempt = metadata.lastDownloadAttempt
      ..failureReason = metadata.failureReason
      ..originalUrl = metadata.originalUrl;
  }

  factory CachedAudioDocumentUnified.merge(
    CachedAudio audio,
    CacheMetadata metadata,
  ) {
    return CachedAudioDocumentUnified()
      ..trackId = audio.trackId
      ..filePath = audio.filePath
      ..fileSizeBytes = audio.fileSizeBytes
      ..cachedAt = audio.cachedAt
      ..checksum = audio.checksum
      ..quality = audio.quality
      ..status = metadata.status
      ..referenceCount = metadata.referenceCount
      ..lastAccessed = metadata.lastAccessed
      ..references = List<String>.from(metadata.references)
      ..downloadAttempts = metadata.downloadAttempts
      ..lastDownloadAttempt = metadata.lastDownloadAttempt
      ..failureReason = metadata.failureReason
      ..originalUrl = metadata.originalUrl;
  }

  CachedAudio toCachedAudio() {
    return CachedAudio(
      trackId: trackId,
      filePath: filePath,
      fileSizeBytes: fileSizeBytes,
      cachedAt: cachedAt,
      checksum: checksum,
      quality: quality,
      status: status,
    );
  }

  CacheMetadata toCacheMetadata() {
    return CacheMetadata(
      trackId: trackId,
      referenceCount: referenceCount,
      lastAccessed: lastAccessed,
      references: List<String>.from(references),
      status: status,
      downloadAttempts: downloadAttempts,
      lastDownloadAttempt: lastDownloadAttempt,
      failureReason: failureReason,
      originalUrl: originalUrl,
    );
  }

  // Métodos de conveniencia
  bool get isCached => status == CacheStatus.cached;
  bool get isDownloading => status == CacheStatus.downloading;
  bool get isFailed => status == CacheStatus.failed;
  bool get isCorrupted => status == CacheStatus.corrupted;

  bool get hasReferences => references.isNotEmpty;
  bool get canDelete => references.isEmpty;

  bool get shouldRetry {
    if (status != CacheStatus.failed) return false;
    if (downloadAttempts >= 3) return false;
    if (lastDownloadAttempt == null) return true;

    final timeSinceLastAttempt = DateTime.now().difference(
      lastDownloadAttempt!,
    );
    return timeSinceLastAttempt.inMinutes >= 5;
  }

  // Métodos de actualización
  CachedAudioDocumentUnified updateLastAccessed() {
    lastAccessed = DateTime.now();
    return this;
  }

  CachedAudioDocumentUnified addReference(String referenceId) {
    if (!references.contains(referenceId)) {
      references.add(referenceId);
      referenceCount = references.length;
    }
    return this;
  }

  CachedAudioDocumentUnified removeReference(String referenceId) {
    references.remove(referenceId);
    referenceCount = references.length;
    return this;
  }

  CachedAudioDocumentUnified markAsDownloading() {
    status = CacheStatus.downloading;
    lastDownloadAttempt = DateTime.now();
    return this;
  }

  CachedAudioDocumentUnified markAsCompleted() {
    status = CacheStatus.cached;
    failureReason = null;
    return this;
  }

  CachedAudioDocumentUnified markAsFailed(String reason) {
    status = CacheStatus.failed;
    failureReason = reason;
    downloadAttempts++;
    lastDownloadAttempt = DateTime.now();
    return this;
  }

  CachedAudioDocumentUnified markAsCorrupted() {
    status = CacheStatus.corrupted;
    return this;
  }
}

/// Generates fast hash for string ID following existing pattern
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;

  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }

  return hash;
}
