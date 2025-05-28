import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/entities/project_description.dart';
import 'package:trackflow/features/projects/domain/entities/project_name.dart';

class Project {
  final UniqueId id;
  final UserId ownerId;
  final ProjectName name;
  final ProjectDescription description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<UserId> collaborators;

  const Project({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    this.collaborators = const [],
  });

  Project copyWith({
    UniqueId? id,
    UserId? ownerId,
    ProjectName? name,
    ProjectDescription? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<UserId>? collaborators,
  }) {
    return Project(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      collaborators: collaborators ?? this.collaborators,
    );
  }
}
