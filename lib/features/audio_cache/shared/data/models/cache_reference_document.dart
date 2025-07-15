import 'package:isar/isar.dart';
import '../../domain/entities/cache_reference.dart';

part 'cache_reference_document.g.dart';

@collection
class CacheReferenceDocument {
  Id get isarId => fastHash(trackId);

  @Index(unique: true)
  late String trackId;

  late List<String> referenceIds;
  
  late DateTime createdAt;
  
  DateTime? lastAccessed;

  CacheReferenceDocument();

  factory CacheReferenceDocument.fromEntity(CacheReference reference) {
    return CacheReferenceDocument()
      ..trackId = reference.trackId
      ..referenceIds = List<String>.from(reference.referenceIds)
      ..createdAt = reference.createdAt
      ..lastAccessed = reference.lastAccessed;
  }

  CacheReference toEntity() {
    return CacheReference(
      trackId: trackId,
      referenceIds: List<String>.from(referenceIds),
      createdAt: createdAt,
      lastAccessed: lastAccessed,
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