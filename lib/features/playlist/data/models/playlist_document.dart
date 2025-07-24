import 'package:isar/isar.dart';
import 'package:trackflow/features/playlist/data/models/playlist_dto.dart';
import 'package:trackflow/core/sync/data/models/sync_metadata_document.dart';
part 'playlist_document.g.dart';

@collection
class PlaylistDocument {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String name;
  late List<String> trackIds;
  late String playlistSource;

  /// Sync metadata for offline-first functionality
  SyncMetadataDocument? syncMetadata;

  PlaylistDocument();

  factory PlaylistDocument.fromDTO(
    PlaylistDto dto, {
    SyncMetadataDocument? syncMeta,
  }) {
    return PlaylistDocument()
      ..uuid = dto.id
      ..name = dto.name
      ..trackIds = dto.trackIds
      ..playlistSource = dto.playlistSource
      // ⭐ NEW: Use sync metadata from DTO if available (from remote)
      ..syncMetadata =
          syncMeta ??
          SyncMetadataDocument.fromRemote(
            version: dto.version,
            lastModified: dto.lastModified ?? DateTime.now(),
          );
  }

  /// Create PlaylistDocument from remote DTO with sync metadata
  factory PlaylistDocument.fromRemoteDTO(
    PlaylistDto dto, {
    int? version,
    DateTime? lastModified,
  }) {
    return PlaylistDocument()
      ..uuid = dto.id
      ..name = dto.name
      ..trackIds = dto.trackIds
      ..playlistSource = dto.playlistSource
      ..syncMetadata = SyncMetadataDocument.fromRemote(
        version: version ?? 1,
        lastModified: lastModified ?? DateTime.now(),
      );
  }

  /// Create PlaylistDocument for local operations
  factory PlaylistDocument.forLocalOperation({
    required String uuid,
    required String name,
    required List<String> trackIds,
    required String playlistSource,
  }) {
    return PlaylistDocument()
      ..uuid = uuid
      ..name = name
      ..trackIds = trackIds
      ..playlistSource = playlistSource
      ..syncMetadata = SyncMetadataDocument.initial();
  }

  PlaylistDto toDTO() {
    return PlaylistDto(
      id: uuid,
      name: name,
      trackIds: trackIds,
      playlistSource: playlistSource,
      // ⭐ NEW: Include sync metadata from document (CRITICAL FIX!)
      version: syncMetadata?.version ?? 1,
      lastSyncTime: syncMetadata?.lastSyncTime,
      lastModified: syncMetadata?.lastModified ?? DateTime.now(),
    );
  }
}
