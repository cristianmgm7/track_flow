import 'package:isar/isar.dart';
import 'package:trackflow/features/track_version/data/models/track_version_dto.dart';
import 'package:trackflow/core/sync/data/models/sync_metadata_document.dart';

part 'track_version_document.g.dart';

@collection
class TrackVersionDocument {
  Id get isarId => id.hashCode;

  @Index(unique: true)
  late String id;

  @Index()
  late String trackId;

  late int versionNumber;

  String? label;
  String? fileLocalPath;
  String? fileRemoteUrl;
  int? durationMs;

  @Index()
  late String status; // processing | ready | failed

  late DateTime createdAt;

  late String createdBy;

  /// Sync metadata for offline-first functionality
  SyncMetadataDocument? syncMetadata;

  TrackVersionDocument();

  factory TrackVersionDocument.fromDTO(
    TrackVersionDTO dto, {
    SyncMetadataDocument? syncMeta,
  }) {
    return TrackVersionDocument()
      ..id = dto.id
      ..trackId = dto.trackId
      ..versionNumber = dto.versionNumber
      ..label = dto.label
      ..fileLocalPath = dto.fileLocalPath
      ..fileRemoteUrl = dto.fileRemoteUrl
      ..durationMs = dto.durationMs
      ..status = dto.status
      ..createdAt = dto.createdAt
      ..createdBy = dto.createdBy
      // ⭐ NEW: Use sync metadata from DTO if available (from remote)
      ..syncMetadata =
          syncMeta ??
          SyncMetadataDocument.fromRemote(
            version: dto.version ?? 1,
            lastModified: dto.lastModified ?? dto.createdAt,
          );
  }

  /// Create from DTO for remote data (already synced)
  factory TrackVersionDocument.fromRemoteDTO(
    TrackVersionDTO dto, {
    int? version,
    DateTime? lastModified,
  }) {
    return TrackVersionDocument()
      ..id = dto.id
      ..trackId = dto.trackId
      ..versionNumber = dto.versionNumber
      ..label = dto.label
      ..fileLocalPath = dto.fileLocalPath
      ..fileRemoteUrl = dto.fileRemoteUrl
      ..durationMs = dto.durationMs
      ..status = dto.status
      ..createdAt = dto.createdAt
      ..createdBy = dto.createdBy
      ..syncMetadata = SyncMetadataDocument.fromRemote(
        version: version ?? 1,
        lastModified: lastModified ?? DateTime.now(),
      );
  }

  /// Create for local upload (pending sync)
  factory TrackVersionDocument.forUpload(TrackVersionDTO dto) {
    return TrackVersionDocument()
      ..id = dto.id
      ..trackId = dto.trackId
      ..versionNumber = dto.versionNumber
      ..label = dto.label
      ..fileLocalPath = dto.fileLocalPath
      ..fileRemoteUrl = dto.fileRemoteUrl
      ..durationMs = dto.durationMs
      ..status = dto.status
      ..createdAt = dto.createdAt
      ..createdBy = dto.createdBy
      ..syncMetadata = SyncMetadataDocument.initial();
  }

  TrackVersionDTO toDTO() {
    return TrackVersionDTO(
      id: _cleanId(id),
      trackId: _cleanId(trackId),
      versionNumber: versionNumber,
      label: label,
      fileLocalPath: fileLocalPath,
      fileRemoteUrl: fileRemoteUrl,
      durationMs: durationMs,
      status: status,
      createdAt: createdAt,
      createdBy: _cleanId(createdBy),
      // ⭐ NEW: Include sync metadata from document (CRITICAL FIX!)
      version: syncMetadata?.version ?? 1,
      lastModified: syncMetadata?.lastModified ?? createdAt,
    );
  }

  /// Clean ID string by removing wrapper format like "UserId(id)" -> "id"
  String _cleanId(String id) {
    // Remove patterns like "UserId(...)", "AudioTrackId(...)", etc.
    final regex = RegExp(r'^[A-Za-z]+\((.+)\)$');
    final match = regex.firstMatch(id);
    return match != null ? match.group(1)! : id;
  }
}
