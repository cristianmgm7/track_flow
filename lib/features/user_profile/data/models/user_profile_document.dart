import 'package:isar/isar.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/core/sync/data/models/sync_metadata_document.dart';

part 'user_profile_document.g.dart';

@collection
class UserProfileDocument {
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  late String name;

  @Index(unique: true)
  late String email;

  late String avatarUrl;
  late DateTime createdAt;
  DateTime? updatedAt;

  @Enumerated(EnumType.name)
  late CreativeRole creativeRole;

  /// Sync metadata for offline-first functionality
  SyncMetadataDocument? syncMetadata;

  UserProfileDocument();

  factory UserProfileDocument.fromDTO(UserProfileDTO dto) {
    return UserProfileDocument()
      ..id = dto.id
      ..name = dto.name
      ..email = dto.email
      ..avatarUrl = dto.avatarUrl
      ..createdAt = dto.createdAt
      ..updatedAt = dto.updatedAt
      ..creativeRole = dto.creativeRole;
  }

  /// Create UserProfileDocument from remote DTO with sync metadata
  factory UserProfileDocument.fromRemoteDTO(UserProfileDTO dto, {
    int? version,
    DateTime? lastModified,
  }) {
    return UserProfileDocument()
      ..id = dto.id
      ..name = dto.name
      ..email = dto.email
      ..avatarUrl = dto.avatarUrl
      ..createdAt = dto.createdAt
      ..updatedAt = dto.updatedAt
      ..creativeRole = dto.creativeRole
      ..syncMetadata = SyncMetadataDocument.fromRemote(
        version: version ?? 1,
        lastModified: lastModified ?? dto.updatedAt ?? dto.createdAt,
      );
  }

  /// Create UserProfileDocument for local updates
  factory UserProfileDocument.forLocalUpdate({
    required String id,
    required String name,
    required String email,
    required String avatarUrl,
    required DateTime createdAt,
    DateTime? updatedAt,
    required CreativeRole creativeRole,
  }) {
    return UserProfileDocument()
      ..id = id
      ..name = name
      ..email = email
      ..avatarUrl = avatarUrl
      ..createdAt = createdAt
      ..updatedAt = updatedAt ?? DateTime.now()
      ..creativeRole = creativeRole
      ..syncMetadata = SyncMetadataDocument.initial();
  }

  UserProfileDTO toDTO() {
    return UserProfileDTO(
      id: id,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      creativeRole: creativeRole,
    );
  }
}
