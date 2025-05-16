import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/entities/project_status.dart';
import 'package:trackflow/features/projects/domain/entities/project_id.dart';
import 'package:trackflow/core/entities/user_id.dart';

/// Data Transfer Object for Project documents in Firestore.
///
/// This class represents the exact structure of how projects are stored in Firestore,
/// including field names and data types. It handles the conversion between Firestore
/// documents and domain entities.
class ProjectDTO {
  const ProjectDTO({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.status,
  });
  static const String collection = 'projects';

  // Firestore field names
  static const String fieldId = 'id';
  static const String fieldUserId = 'userId';
  static const String fieldTitle = 'title';
  static const String fieldDescription = 'description';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldStatus = 'status';

  // instance variables
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime createdAt;
  final String status;

  /// Creates a ProjectDTO from a Firestore document.
  factory ProjectDTO.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectDTO(
      id: data[fieldId] as String,
      userId: data[fieldUserId] as String,
      title: data[fieldTitle] as String,
      description: (data[fieldDescription] as String?) ?? '',
      createdAt: (data[fieldCreatedAt] as Timestamp).toDate(),
      status: data[fieldStatus] as String,
    );
  }

  /// Converts the DTO to a Firestore document map.
  Map<String, dynamic> toFirestore() {
    return {
      fieldUserId: userId,
      fieldTitle: title,
      fieldDescription: description,
      fieldCreatedAt: Timestamp.fromDate(createdAt),
      fieldStatus: status,
    };
  }

  /// Converts the DTO to a domain entity.
  Project toEntity() {
    return Project(
      id: ProjectId(id),
      userId: UserId(userId),
      title: title,
      description: description,
      createdAt: createdAt,
      status: ProjectStatus(status),
    );
  }

  /// Creates a DTO from a domain entity.
  factory ProjectDTO.fromEntity(Project project) {
    return ProjectDTO(
      id: project.id.value,
      userId: project.userId.value.getOrElse(() => ''),
      title: project.title,
      description: project.description,
      createdAt: project.createdAt,
      status: project.status.value.getOrElse(() => ProjectStatus.draft),
    );
  }

  /// Creates a copy of this DTO with the given fields replaced with new values.
  ProjectDTO copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? createdAt,
    String? status,
  }) {
    return ProjectDTO(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  /// Creates a ProjectDTO from a map of data.
  factory ProjectDTO.fromMap(Map<String, dynamic> data) {
    final createdAtRaw = data[fieldCreatedAt];
    final createdAt =
        createdAtRaw is Timestamp
            ? createdAtRaw.toDate()
            : createdAtRaw is DateTime
            ? createdAtRaw
            : DateTime.parse(createdAtRaw.toString());
    return ProjectDTO(
      id: data[fieldId] as String,
      userId: data[fieldUserId] as String,
      title: data[fieldTitle] as String,
      description: (data[fieldDescription] as String?) ?? '',
      createdAt: createdAt,
      status: data[fieldStatus] as String,
    );
  }

  /// Converts the DTO to a map for local storage (Hive).
  Map<String, dynamic> toMap() {
    return {
      fieldId: id,
      fieldUserId: userId,
      fieldTitle: title,
      fieldDescription: description,
      fieldCreatedAt: createdAt.toIso8601String(),
      fieldStatus: status,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectDTO &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.status == status;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      title.hashCode ^
      description.hashCode ^
      createdAt.hashCode ^
      status.hashCode;
}
