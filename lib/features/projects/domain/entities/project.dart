import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/entities/project_collaborator.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_description.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_name.dart';
import 'package:trackflow/core/domain/aggregate_root.dart';

class Project extends AggregateRoot<ProjectId> {
  @override
  final ProjectId id;
  final UserId ownerId;
  final ProjectName name;
  final ProjectDescription description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<ProjectCollaborator> collaborators;
  final bool isDeleted;

  const Project({
    required ProjectId id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    this.collaborators = const [],
    this.isDeleted = false,
  }) : id = id,
       super(id);

  Project copyWith({
    ProjectId? id,
    UserId? ownerId,
    ProjectName? name,
    ProjectDescription? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ProjectCollaborator>? collaborators,
    bool? isDeleted,
  }) {
    return Project(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      collaborators: collaborators ?? this.collaborators,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Project updateProject({
    required UserId requester,
    ProjectName? newName,
    ProjectDescription? newDescription,
  }) {
    if (requester != ownerId) {
      throw Exception('Only the owner can update the project');
    }

    return copyWith(
      name: newName ?? name,
      description: newDescription ?? description,
      updatedAt: DateTime.now(),
    );
  }

  Project deleteProject({required UserId requester}) {
    if (requester != ownerId) {
      throw Exception('Only the owner can delete the project');
    }

    return copyWith(updatedAt: DateTime.now(), isDeleted: true);
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

  void updateCollaboratorRole(
    ProjectCollaborator collaborator,
    ProjectRole role,
  ) {
    if (collaborators.contains(collaborator)) {
      final updatedCollaborator = collaborator.copyWith(role: role);
      collaborators.remove(collaborator);
      collaborators.add(updatedCollaborator);
    } else {
      throw Exception('Collaborator does not exist');
    }
  }
}
