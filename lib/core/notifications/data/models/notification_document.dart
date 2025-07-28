import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:trackflow/core/notifications/data/models/notification_dto.dart';
import 'package:trackflow/core/sync/data/models/sync_metadata_document.dart';

part 'notification_document.g.dart';

@collection
class NotificationDocument {
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  late String recipientUserId;
  late String title;
  late String body;
  late String type;

  @ignore
  late Map<String, dynamic> payload;

  // Store payload as JSON string for Isar compatibility
  late String payloadJson;

  late bool isRead;
  late DateTime timestamp;

  // Sync metadata for offline-first functionality
  late SyncMetadataDocument syncMetadata;

  NotificationDocument();

  factory NotificationDocument.fromDTO(
    NotificationDto dto, {
    SyncMetadataDocument? syncMeta,
  }) {
    return NotificationDocument()
      ..id = dto.id
      ..recipientUserId = dto.recipientUserId
      ..title = dto.title
      ..body = dto.body
      ..type = dto.type
      ..payload = dto.payload
      ..payloadJson = jsonEncode(dto.payload)
      ..isRead = dto.isRead
      ..timestamp = dto.timestamp
      // ⭐ NEW: Use sync metadata from DTO if available (from remote)
      ..syncMetadata =
          syncMeta ??
          SyncMetadataDocument.fromRemote(
            version: dto.version,
            lastModified: dto.lastModified ?? dto.timestamp,
          );
  }

  /// Create from DTO for remote data (already synced)
  factory NotificationDocument.fromRemoteDTO(
    NotificationDto dto, {
    int? version,
    DateTime? lastModified,
  }) {
    return NotificationDocument()
      ..id = dto.id
      ..recipientUserId = dto.recipientUserId
      ..title = dto.title
      ..body = dto.body
      ..type = dto.type
      ..payload = dto.payload
      ..payloadJson = jsonEncode(dto.payload)
      ..isRead = dto.isRead
      ..timestamp = dto.timestamp
      ..syncMetadata = SyncMetadataDocument.fromRemote(
        version: version ?? 1,
        lastModified: lastModified ?? dto.timestamp,
      );
  }

  NotificationDto toDTO() {
    // Parse payload from JSON string
    final payloadMap = jsonDecode(payloadJson) as Map<String, dynamic>;

    return NotificationDto(
      id: id,
      recipientUserId: recipientUserId,
      title: title,
      body: body,
      type: type,
      payload: payloadMap,
      isRead: isRead,
      timestamp: timestamp,
      // ⭐ NEW: Include sync metadata from document (CRITICAL FIX!)
      version: syncMetadata.version,
      lastModified: syncMetadata.lastModified,
    );
  }
}

/// FNV-1a 64bit hash algorithm.
int fastHash(String string) {
  int hash = 0xcbf29ce484222325;
  int i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash;
}
