import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/entities/project_description.dart';
import 'package:trackflow/features/projects/domain/entities/project_name.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';

class ProjectDetailDTO {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final DateTime createdAt;
  final List<UserProfileDTO> collaborators;

  ProjectDetailDTO({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.createdAt,
    this.collaborators = const [],
  });

  static const String collection = 'project_details';

  factory ProjectDetailDTO.fromDomain(Project project) {
    return ProjectDetailDTO(
      id: project.id.value,
      ownerId: project.ownerId.value,
      name: project.name.value.fold((l) => '', (r) => r),
      description: project.description.value.fold((l) => '', (r) => r),
      createdAt: project.createdAt,
      collaborators:
          project.collaborators
              .map(
                (u) => UserProfileDTO(
                  id: u.value,
                  name: '',
                  email: '',
                  avatarUrl: '',
                  createdAt: DateTime.now(),
                ),
              )
              .toList(),
    );
  }

  Project toDomain() {
    return Project(
      id: ProjectId.fromUniqueString(id),
      ownerId: UserId.fromUniqueString(ownerId),
      name: ProjectName(name),
      description: ProjectDescription(description),
      createdAt: createdAt,
      collaborators:
          collaborators.map((dto) => UserId.fromUniqueString(dto.id)).toList(),
    );
  }

  factory ProjectDetailDTO.fromJson(Map<String, dynamic> json) {
    return ProjectDetailDTO(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      collaborators:
          (json['collaborators'] as List<dynamic>?)
              ?.map((e) => UserProfileDTO.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'collaborators': collaborators.map((dto) => dto.toJson()).toList(),
    };
  }

  factory ProjectDetailDTO.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectDetailDTO(
      id: data['id'] as String,
      ownerId: data['ownerId'] as String,
      name: data['name'] as String,
      description: (data['description'] as String?) ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      collaborators:
          (data['collaborators'] as List<dynamic>?)
              ?.map((e) => UserProfileDTO.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'collaborators': collaborators.map((dto) => dto.toJson()).toList(),
    };
  }
}
