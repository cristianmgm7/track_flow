import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/cached_audio.dart';
import '../../domain/entities/cache_metadata.dart';

part 'cached_audio_document_unified.g.dart';

@collection
class CachedAudioDocumentUnified {
  Id get isarId => fastHash(trackId);

  @Index(unique: true)
  late String trackId;

  late String versionId;

  // ===============================================
  // ARCHIVO FÍSICO
  // ===============================================
  late String relativePath; // Ruta relativa al directorio de cache
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

  late DateTime lastAccessed;
  late int downloadAttempts;

  DateTime? lastDownloadAttempt;
  String? failureReason;
  String? originalUrl;

  CachedAudioDocumentUnified();

  factory CachedAudioDocumentUnified.fromCachedAudio(CachedAudio audio) {
    return CachedAudioDocumentUnified()
      ..trackId = audio.trackId
      ..versionId = audio.versionId
      ..relativePath = _getRelativePath(
        audio.filePath,
      ) // Convertir a ruta relativa
      ..fileSizeBytes = audio.fileSizeBytes
      ..cachedAt = audio.cachedAt
      ..checksum = audio.checksum
      ..quality = audio.quality
      ..status = audio.status
      ..lastAccessed = DateTime.now()
      ..downloadAttempts = 0
      ..lastDownloadAttempt = null
      ..failureReason = null
      ..originalUrl = null;
  }

  factory CachedAudioDocumentUnified.fromCacheMetadata(CacheMetadata metadata) {
    return CachedAudioDocumentUnified()
      ..trackId = metadata.trackId
      ..versionId =
          '' // Metadata legacy no tiene versionId
      ..relativePath =
          '' // Will be set when file is downloaded
      ..fileSizeBytes = 0
      ..cachedAt = DateTime.now()
      ..checksum = ''
      ..quality = AudioQuality.medium
      ..status = metadata.status
      ..lastAccessed = metadata.lastAccessed
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
      ..versionId = audio.versionId
      ..relativePath = _getRelativePath(
        audio.filePath,
      ) // Convertir a ruta relativa
      ..fileSizeBytes = audio.fileSizeBytes
      ..cachedAt = audio.cachedAt
      ..checksum = audio.checksum
      ..quality = audio.quality
      ..status = metadata.status
      ..lastAccessed = metadata.lastAccessed
      ..downloadAttempts = metadata.downloadAttempts
      ..lastDownloadAttempt = metadata.lastDownloadAttempt
      ..failureReason = metadata.failureReason
      ..originalUrl = metadata.originalUrl;
  }

  Future<CachedAudio> toCachedAudio() async {
    // Reconstruir la ruta absoluta desde la relativa
    final absolutePath = await getAbsolutePath();

    return CachedAudio(
      trackId: trackId,
      versionId: versionId,
      filePath: absolutePath, // Ruta absoluta reconstruida
      fileSizeBytes: fileSizeBytes,
      cachedAt: cachedAt,
      checksum: checksum,
      quality: quality,
      status: status,
    );
  }

  /// Convert relative path to absolute path
  Future<String> getAbsolutePath() async {
    final cacheDir = await _getCacheDirectory();
    return '${cacheDir.path}/$relativePath';
  }

  /// Validate if the cached file still exists
  Future<bool> validateFileExists() async {
    try {
      final absolutePath = await getAbsolutePath();
      final file = File(absolutePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  CacheMetadata toCacheMetadata() {
    return CacheMetadata(
      trackId: trackId,
      lastAccessed: lastAccessed,
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

/// Get the cache directory for relative path resolution
Future<Directory> _getCacheDirectory() async {
  final appDir = await getApplicationDocumentsDirectory();
  final cacheDir = Directory('${appDir.path}/trackflow/audio');

  if (!await cacheDir.exists()) {
    await cacheDir.create(recursive: true);
  }

  return cacheDir;
}

/// Convert absolute path to relative path
String _getRelativePath(String absolutePath) {
  try {
    // Extraer la parte relativa después de '/trackflow/audio/'
    final trackflowIndex = absolutePath.indexOf('/trackflow/audio/');
    if (trackflowIndex != -1) {
      return absolutePath.substring(
        trackflowIndex + '/trackflow/audio/'.length,
      );
    }
    // Fallback: devolver el path original si no se puede convertir
    return absolutePath;
  } catch (e) {
    return absolutePath;
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
