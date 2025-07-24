import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/entities/project_collaborator.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_collaborator_id.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_permission.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';

class ProjectDTO {
  const ProjectDTO({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    this.collaborators = const [], // userId, role
    this.collaboratorIds = const [],
    this.isDeleted = false,
    // ⭐ NEW: Sync metadata fields for proper offline-first sync
    this.version = 1,
    this.lastModified,
  });

  final String id;
  final String ownerId;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> collaboratorIds;
  final List<Map<String, dynamic>> collaborators; // userId, role
  final bool isDeleted;

  // ⭐ NEW: Sync metadata fields (now included in remote storage)
  final int version;
  final DateTime? lastModified;

  static const String collection = 'projects';

  factory ProjectDTO.fromDomain(Project project) => ProjectDTO(
    id: project.id.value,
    ownerId: project.ownerId.value,
    name: project.name.value.fold((l) => '', (r) => r),
    description: project.description.value.fold((l) => '', (r) => r),
    createdAt: project.createdAt,
    updatedAt: project.updatedAt,
    collaborators:
        project.collaborators
            .map(
              (c) => {
                'id': c.id.value,
                'userId': c.userId.value,
                'role': c.role.toShortString(),
                'specificPermissions':
                    c.specificPermissions.map((p) => p.name).toList(),
              },
            )
            .toList(),
    collaboratorIds: project.collaborators.map((c) => c.userId.value).toList(),
    isDeleted: project.isDeleted,
    // ⭐ NEW: Include sync metadata for proper offline-first sync
    version: 1, // Initial version for new projects
    lastModified: project.updatedAt ?? project.createdAt,
  );

  Project toDomain() => Project(
    id: ProjectId.fromUniqueString(id),
    ownerId: UserId.fromUniqueString(ownerId),
    name: ProjectName(name),
    description: ProjectDescription(description),
    createdAt: createdAt,
    updatedAt: updatedAt,
    collaborators:
        collaborators.map((data) {
          return ProjectCollaborator.rebuild(
            id: ProjectCollaboratorId.fromUniqueString(data['id']),
            userId: UserId.fromUniqueString(data['userId']),
            role: ProjectRole.fromString(data['role']),
            specificPermissions:
                (data['specificPermissions'] as List<dynamic>?)
                    ?.map(
                      (e) => ProjectPermission.values.firstWhere(
                        (p) => p.name == e,
                      ),
                    )
                    .toList() ??
                [],
          );
        }).toList(),
    isDeleted: isDeleted,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerId': ownerId,
    'name': name,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'collaborators': collaborators,
    'collaboratorIds': collaboratorIds,
    'isDeleted': isDeleted,
    // ⭐ NEW: Include sync metadata in JSON
    'version': version,
    'lastModified': lastModified?.toIso8601String(),
  };

  factory ProjectDTO.fromJson(Map<String, dynamic> json) => ProjectDTO(
    id: json['id'] as String? ?? '',
    ownerId: json['ownerId'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    createdAt:
        json['createdAt'] is Timestamp
            ? (json['createdAt'] as Timestamp).toDate()
            : DateTime.tryParse(json['createdAt'] as String? ?? '') ??
                DateTime.now(),
    updatedAt:
        json['updatedAt'] is Timestamp
            ? (json['updatedAt'] as Timestamp).toDate()
            : DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    collaborators:
        (json['collaborators'] as List<dynamic>?)
            ?.map((e) => (e as Map).cast<String, dynamic>())
            .toList() ??
        [],
    collaboratorIds:
        (json['collaboratorIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    isDeleted: json['isDeleted'] as bool? ?? false,
    // ⭐ NEW: Parse sync metadata from JSON
    version: json['version'] as int? ?? 1,
    lastModified:
        json['lastModified'] is Timestamp
            ? (json['lastModified'] as Timestamp).toDate()
            : DateTime.tryParse(json['lastModified'] as String? ?? ''),
  );

  /// Creates a ProjectDTO from a Firestore document.
  factory ProjectDTO.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final createdAtRaw = data['createdAt'];
    final createdAt =
        createdAtRaw is Timestamp
            ? createdAtRaw.toDate()
            : createdAtRaw is DateTime
            ? createdAtRaw
            : DateTime.tryParse(createdAtRaw.toString()) ?? DateTime.now();
    final updatedAtRaw = data['updatedAt'];
    final updatedAt =
        updatedAtRaw is Timestamp
            ? updatedAtRaw.toDate()
            : updatedAtRaw is DateTime
            ? updatedAtRaw
            : DateTime.tryParse(updatedAtRaw.toString());
    final lastModifiedRaw = data['lastModified'];
    final lastModified =
        lastModifiedRaw is Timestamp
            ? lastModifiedRaw.toDate()
            : lastModifiedRaw is DateTime
            ? lastModifiedRaw
            : DateTime.tryParse(lastModifiedRaw?.toString() ?? '');
    return ProjectDTO(
      id: data['id'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: (data['description'] as String?) ?? '',
      createdAt: createdAt,
      updatedAt: updatedAt,
      collaborators:
          (data['collaborators'] as List<dynamic>?)
              ?.map((e) => (e as Map).cast<String, dynamic>())
              .toList() ??
          [],
      collaboratorIds:
          (data['collaboratorIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isDeleted: data['isDeleted'] as bool? ?? false,
      // ⭐ NEW: Parse sync metadata from Firestore
      version: data['version'] as int? ?? 1,
      lastModified: lastModified,
    );
  }

  /// Converts the DTO to a Firestore document map.
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'collaborators': collaborators,
      'collaboratorIds': collaboratorIds,
      'isDeleted': isDeleted,
      // ⭐ NEW: Include sync metadata in Firestore (CRITICAL for offline-first)
      'version': version,
      'lastModified':
          lastModified != null ? Timestamp.fromDate(lastModified!) : null,
    };
  }

  /// Creates a copy of this DTO with the given fields replaced with new values.
  ProjectDTO copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Map<String, dynamic>>? collaborators,
    List<String>? collaboratorIds,
    bool? isDeleted,
    int? version,
    DateTime? lastModified,
  }) {
    return ProjectDTO(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      collaborators: collaborators ?? this.collaborators,
      collaboratorIds: collaboratorIds ?? this.collaboratorIds,
      isDeleted: isDeleted ?? this.isDeleted,
      // ⭐ NEW: Include sync metadata in copyWith
      version: version ?? this.version,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  /// Creates a ProjectDTO from a map of data.
  factory ProjectDTO.fromMap(Map<String, dynamic> data) {
    final createdAtRaw = data['createdAt'];
    final createdAt =
        createdAtRaw is Timestamp
            ? createdAtRaw.toDate()
            : createdAtRaw is DateTime
            ? createdAtRaw
            : DateTime.tryParse(createdAtRaw.toString()) ?? DateTime.now();
    final updatedAtRaw = data['updatedAt'];
    final updatedAt =
        updatedAtRaw is Timestamp
            ? updatedAtRaw.toDate()
            : updatedAtRaw is DateTime
            ? updatedAtRaw
            : DateTime.tryParse(updatedAtRaw.toString());
    final lastModifiedRaw = data['lastModified'];
    final lastModified =
        lastModifiedRaw is Timestamp
            ? lastModifiedRaw.toDate()
            : lastModifiedRaw is DateTime
            ? lastModifiedRaw
            : DateTime.tryParse(lastModifiedRaw?.toString() ?? '');
    return ProjectDTO(
      id: data['id'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: (data['description'] as String?) ?? '',
      createdAt: createdAt,
      updatedAt: updatedAt,
      collaborators:
          (data['collaborators'] as List<dynamic>?)
              ?.map((e) => (e as Map).cast<String, dynamic>())
              .toList() ??
          [],
      collaboratorIds:
          (data['collaboratorIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isDeleted: data['isDeleted'] as bool? ?? false,
      // ⭐ NEW: Parse sync metadata from map
      version: data['version'] as int? ?? 1,
      lastModified: lastModified,
    );
  }

  /// Converts the DTO to a map for local storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'collaborators': collaborators,
      'collaboratorIds': collaboratorIds,
      'isDeleted': isDeleted,
      // ⭐ NEW: Include sync metadata in map
      'version': version,
      'lastModified': lastModified?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectDTO &&
        other.id == id &&
        other.ownerId == ownerId &&
        other.name == name &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        listEquals(other.collaborators, collaborators) &&
        listEquals(other.collaboratorIds, collaboratorIds) &&
        other.isDeleted == isDeleted &&
        // ⭐ NEW: Include sync metadata in equality
        other.version == version &&
        other.lastModified == lastModified;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      ownerId.hashCode ^
      name.hashCode ^
      description.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      collaborators.hashCode ^
      collaboratorIds.hashCode ^
      isDeleted.hashCode ^
      // ⭐ NEW: Include sync metadata in hashCode
      version.hashCode ^
      lastModified.hashCode;
}
