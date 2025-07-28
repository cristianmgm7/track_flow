import 'package:isar/isar.dart';
import 'package:trackflow/features/invitations/data/models/invitation_dto.dart';
import 'package:trackflow/core/sync/data/models/sync_metadata_document.dart';

part 'invitation_document.g.dart';

@collection
class InvitationDocument {
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  late String projectId;
  late String invitedByUserId;
  String? invitedUserId; // For existing users
  late String invitedEmail;
  late String proposedRole;
  String? message;
  late String status;
  late DateTime createdAt;
  late DateTime expiresAt;

  // Sync metadata for offline-first functionality
  late SyncMetadataDocument syncMetadata;

  InvitationDocument();

  factory InvitationDocument.fromDTO(
    InvitationDto dto, {
    SyncMetadataDocument? syncMeta,
  }) {
    return InvitationDocument()
      ..id = dto.id
      ..projectId = dto.projectId
      ..invitedByUserId = dto.invitedByUserId
      ..invitedUserId = dto.invitedUserId
      ..invitedEmail = dto.invitedEmail
      ..proposedRole = dto.proposedRole
      ..message = dto.message
      ..status = dto.status
      ..createdAt = dto.createdAt
      ..expiresAt = dto.expiresAt ?? dto.createdAt.add(const Duration(days: 7))
      // ⭐ NEW: Use sync metadata from DTO if available (from remote)
      ..syncMetadata =
          syncMeta ??
          SyncMetadataDocument.fromRemote(
            version: dto.version,
            lastModified: dto.lastModified ?? dto.createdAt,
          );
  }

  /// Create from DTO for remote data (already synced)
  factory InvitationDocument.fromRemoteDTO(
    InvitationDto dto, {
    int? version,
    DateTime? lastModified,
  }) {
    return InvitationDocument()
      ..id = dto.id
      ..projectId = dto.projectId
      ..invitedByUserId = dto.invitedByUserId
      ..invitedUserId = dto.invitedUserId
      ..invitedEmail = dto.invitedEmail
      ..proposedRole = dto.proposedRole
      ..message = dto.message
      ..status = dto.status
      ..createdAt = dto.createdAt
      ..expiresAt = dto.expiresAt ?? dto.createdAt.add(const Duration(days: 7))
      ..syncMetadata = SyncMetadataDocument.fromRemote(
        version: version ?? 1,
        lastModified: lastModified ?? dto.createdAt,
      );
  }

  InvitationDto toDTO() {
    return InvitationDto(
      id: id,
      projectId: projectId,
      invitedByUserId: invitedByUserId,
      invitedUserId: invitedUserId,
      invitedEmail: invitedEmail,
      proposedRole: proposedRole,
      message: message,
      status: status,
      createdAt: createdAt,
      expiresAt: expiresAt,
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
