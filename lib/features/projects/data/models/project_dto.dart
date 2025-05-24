import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/entities/project_name.dart';
import 'package:trackflow/features/projects/domain/entities/project_description.dart';

class ProjectDTO {
  const ProjectDTO({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  final String id;
  final String ownerId;
  final String name;
  final String description;
  final DateTime createdAt;

  static const String collection = 'projects';

  factory ProjectDTO.fromDomain(Project project) => ProjectDTO(
    id: project.id.value,
    ownerId: project.ownerId.value,
    name: project.name.value.fold((l) => '', (r) => r),
    description: project.description.value.fold((l) => '', (r) => r),
    createdAt: project.createdAt,
  );

  Project toDomain() => Project(
    id: UniqueId.fromUniqueString(id),
    ownerId: UserId.fromUniqueString(ownerId),
    name: ProjectName(name),
    description: ProjectDescription(description),
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerId': ownerId,
    'name': name,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ProjectDTO.fromJson(Map<String, dynamic> json) => ProjectDTO(
    id: json['id'] as String,
    ownerId: json['ownerId'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  /// Creates a ProjectDTO from a Firestore document.
  factory ProjectDTO.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectDTO(
      id: data['id'] as String,
      ownerId: data['ownerId'] as String,
      name: data['name'] as String,
      description: (data['description'] as String?) ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
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
    };
  }

  /// Creates a copy of this DTO with the given fields replaced with new values.
  ProjectDTO copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return ProjectDTO(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
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
            : DateTime.parse(createdAtRaw.toString());
    return ProjectDTO(
      id: data['id'] as String,
      ownerId: data['ownerId'] as String,
      name: data['name'] as String,
      description: (data['description'] as String?) ?? '',
      createdAt: createdAt,
    );
  }

  /// Converts the DTO to a map for local storage (Hive).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
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
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      ownerId.hashCode ^
      name.hashCode ^
      description.hashCode ^
      createdAt.hashCode;
}
