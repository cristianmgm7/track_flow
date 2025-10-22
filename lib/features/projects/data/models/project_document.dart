import 'package:isar/isar.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/core/sync/data/models/sync_metadata_document.dart';

part 'project_document.g.dart';

@collection
class ProjectDocument {
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;
  late String ownerId;
  late String name;
  late String description;
  late DateTime createdAt;
  DateTime? updatedAt;
  late List<String> collaboratorIds;
  late List<CollaboratorDocument> collaborators;
  @Index()
  bool isDeleted = false;
  String? coverUrl;
  String? coverLocalPath;

  // NEW: Sync metadata for conflict resolution
  late SyncMetadataDocument syncMetadata;

  ProjectDocument();

  factory ProjectDocument.fromDTO(
    ProjectDTO dto, {
    SyncMetadataDocument? syncMeta,
  }) {
    return ProjectDocument()
      ..id = dto.id
      ..ownerId = dto.ownerId
      ..name = dto.name
      ..description = dto.description
      ..createdAt = dto.createdAt
      ..updatedAt = dto.updatedAt
      ..collaboratorIds = dto.collaboratorIds
      ..collaborators =
          dto.collaborators.map((c) => CollaboratorDocument.fromMap(c)).toList()
      ..isDeleted = dto.isDeleted
      ..coverUrl = dto.coverUrl
      ..coverLocalPath = dto.coverLocalPath
      // ⭐ NEW: Use sync metadata from DTO if available (from remote)
      ..syncMetadata =
          syncMeta ??
          SyncMetadataDocument.fromRemote(
            version: dto.version,
            lastModified: dto.lastModified ?? dto.updatedAt ?? dto.createdAt,
          );
  }

  /// Create from DTO for remote data (already synced)
  factory ProjectDocument.fromRemoteDTO(
    ProjectDTO dto, {
    int? version,
    DateTime? lastModified,
  }) {
    return ProjectDocument()
      ..id = dto.id
      ..ownerId = dto.ownerId
      ..name = dto.name
      ..description = dto.description
      ..createdAt = dto.createdAt
      ..updatedAt = dto.updatedAt
      ..collaboratorIds = dto.collaboratorIds
      ..collaborators =
          dto.collaborators.map((c) => CollaboratorDocument.fromMap(c)).toList()
      ..isDeleted = dto.isDeleted
      ..coverUrl = dto.coverUrl
      ..coverLocalPath = dto.coverLocalPath
      ..syncMetadata = SyncMetadataDocument.fromRemote(
        version: version ?? 1,
        lastModified: lastModified ?? dto.updatedAt ?? dto.createdAt,
      );
  }

  ProjectDTO toDTO() {
    return ProjectDTO(
      id: id,
      ownerId: ownerId,
      name: name,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      collaboratorIds: collaboratorIds,
      collaborators: collaborators.map((c) => c.toMap()).toList(),
      isDeleted: isDeleted,
      // ⭐ NEW: Include sync metadata from document (CRITICAL FIX!)
      version: syncMetadata.version,
      lastModified: syncMetadata.lastModified,
      coverUrl: coverUrl,
      coverLocalPath: coverLocalPath,
    );
  }
}

@embedded
class CollaboratorDocument {
  late String id;
  late String userId;
  late String role;
  late List<String> specificPermissions;

  CollaboratorDocument();

  factory CollaboratorDocument.fromMap(Map<String, dynamic> map) {
    return CollaboratorDocument()
      ..id = map['id'] as String
      ..userId = map['userId'] as String
      ..role = map['role'] as String
      ..specificPermissions =
          (map['specificPermissions'] as List<dynamic>)
              .map((e) => e as String)
              .toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'role': role,
      'specificPermissions': specificPermissions,
    };
  }
}

/// FNV-1a 64bit hash algorithm.
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
