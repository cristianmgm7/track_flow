import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/entities/user_creative_role.dart';
import 'package:trackflow/core/entities/user_role.dart';
import 'package:trackflow/features/projects/domain/entities/project_description.dart';
import 'package:trackflow/features/projects/domain/entities/project_name.dart';

class Project {
  final ProjectId id;
  final UserId ownerId;
  final ProjectName name;
  final ProjectDescription description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<UserId> collaborators;
  final Map<UserId, UserRole> roles;
  final Map<UserId, UserCreativeRole> members;

  const Project({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    this.collaborators = const [],
    this.roles = const {},
    this.members = const {},
  });

  Project copyWith({
    ProjectId? id,
    UserId? ownerId,
    ProjectName? name,
    ProjectDescription? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<UserId>? collaborators,
    Map<UserId, UserRole>? roles,
    Map<UserId, UserCreativeRole>? members,
  }) {
    return Project(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      collaborators: collaborators ?? this.collaborators,
      roles: roles ?? this.roles,
      members: members ?? this.members,
    );
  }
}
