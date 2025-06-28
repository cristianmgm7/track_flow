import 'package:isar/isar.dart';
import '../../domain/entities/cached_audio.dart';

part 'cached_audio_document.g.dart';

@collection
class CachedAudioDocument {
  Id get isarId => fastHash(trackId);

  @Index(unique: true)
  late String trackId;

  late String filePath;

  late int fileSizeBytes;

  late DateTime cachedAt;

  late String checksum;

  @Enumerated(EnumType.name)
  late AudioQuality quality;

  @Enumerated(EnumType.name)
  late CacheStatus status;

  CachedAudioDocument();

  factory CachedAudioDocument.fromEntity(CachedAudio audio) {
    return CachedAudioDocument()
      ..trackId = audio.trackId
      ..filePath = audio.filePath
      ..fileSizeBytes = audio.fileSizeBytes
      ..cachedAt = audio.cachedAt
      ..checksum = audio.checksum
      ..quality = audio.quality
      ..status = audio.status;
  }

  CachedAudio toEntity() {
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
