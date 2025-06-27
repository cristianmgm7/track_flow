import 'package:isar/isar.dart';
import '../../domain/entities/cache_metadata.dart';
import '../../domain/entities/cached_audio.dart';

part 'cache_metadata_document.g.dart';

@collection
class CacheMetadataDocument {
  Id get isarId => fastHash(trackId);

  @Index(unique: true)
  late String trackId;

  late int referenceCount;
  
  late DateTime lastAccessed;
  
  late List<String> references;
  
  @Enumerated(EnumType.name)
  late CacheStatus status;
  
  late int downloadAttempts;
  
  DateTime? lastDownloadAttempt;
  
  String? failureReason;
  
  String? originalUrl;

  CacheMetadataDocument();

  factory CacheMetadataDocument.fromEntity(CacheMetadata metadata) {
    return CacheMetadataDocument()
      ..trackId = metadata.trackId
      ..referenceCount = metadata.referenceCount
      ..lastAccessed = metadata.lastAccessed
      ..references = List<String>.from(metadata.references)
      ..status = metadata.status
      ..downloadAttempts = metadata.downloadAttempts
      ..lastDownloadAttempt = metadata.lastDownloadAttempt
      ..failureReason = metadata.failureReason
      ..originalUrl = metadata.originalUrl;
  }

  CacheMetadata toEntity() {
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