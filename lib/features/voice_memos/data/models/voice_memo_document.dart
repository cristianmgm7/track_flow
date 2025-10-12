import 'package:isar/isar.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import '../../domain/entities/voice_memo.dart';

part 'voice_memo_document.g.dart';

/// Isar document for voice memo local storage
@collection
class VoiceMemoDocument {
  /// Isar requires int ID - use fast hash
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  late String title;
  late String fileLocalPath;
  String? fileRemoteUrl;
  late int durationMs;

  @Index()
  late DateTime recordedAt;

  /// Future field for track conversion
  String? convertedToTrackId;

  /// The user who created this voice memo. Null for legacy/app local only contexts.
  String? createdBy;

  VoiceMemoDocument();

  /// Create from domain entity
  factory VoiceMemoDocument.fromDomain(VoiceMemo memo) {
    return VoiceMemoDocument()
      ..id = memo.id.value
      ..title = memo.title
      ..fileLocalPath = memo.fileLocalPath
      ..fileRemoteUrl = memo.fileRemoteUrl
      ..durationMs = memo.duration.inMilliseconds
      ..recordedAt = memo.recordedAt
      ..convertedToTrackId = memo.convertedToTrackId
      ..createdBy = memo.createdBy?.value;
  }

  /// Convert to domain entity
  VoiceMemo toDomain() {
    return VoiceMemo(
      id: VoiceMemoId.fromUniqueString(id),
      title: title,
      fileLocalPath: fileLocalPath,
      fileRemoteUrl: fileRemoteUrl,
      duration: Duration(milliseconds: durationMs),
      recordedAt: recordedAt,
      convertedToTrackId: convertedToTrackId,
      createdBy: createdBy != null ? UserId.fromUniqueString(createdBy!) : null,
    );
  }
}

/// FNV-1a 64-bit hash for string to int ID conversion
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit;
    hash *= 0x100000001b3;
  }
  return hash;
}
