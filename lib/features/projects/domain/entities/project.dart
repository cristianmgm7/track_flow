import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/entities/user_creative_role.dart';
import 'package:trackflow/features/projects/domain/entities/project_collaborator.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_description.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_name.dart';

class Project {
  final ProjectId id;
  final UserId ownerId;
  final ProjectName name;
  final ProjectDescription description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<ProjectCollaborator> collaborators;

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
    ProjectId? id,
    UserId? ownerId,
    ProjectName? name,
    ProjectDescription? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ProjectCollaborator>? collaborators,
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

  void addCollaborator(ProjectCollaborator collaborator) {
    if (!collaborators.contains(collaborator)) {
      collaborators.add(collaborator);
    } else {
      throw Exception('Collaborator already exists');
    }
  }

  void removeCollaborator(ProjectCollaborator collaborator) {
    if (collaborators.contains(collaborator)) {
      collaborators.remove(collaborator);
    } else {
      throw Exception('Collaborator does not exist');
    }
  }

  void assignRole(ProjectCollaborator collaborator, ProjectRole role) {
    if (collaborators.contains(collaborator)) {
      collaborator.role = role;
    } else {
      throw Exception('Collaborator does not exist');
    }
  }

  void removeRole(ProjectCollaborator collaborator) {
    if (collaborators.contains(collaborator)) {
      collaborator.role = ProjectRole.viewer;
    } else {
      throw Exception('Role does not exist for this collaborator');
    }
  }
}
