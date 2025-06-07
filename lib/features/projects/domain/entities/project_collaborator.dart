import 'package:trackflow/core/domain/entity.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_collaborator_id.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_permission.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';

// project collaborator entity
class ProjectCollaborator extends Entity<ProjectCollaboratorId> {
  final UserId userId;
  ProjectRole role;
  final List<ProjectPermission> specificPermissions;

  ProjectCollaborator._({
    required ProjectCollaboratorId id,
    required this.userId,
    required this.role,
    required this.specificPermissions,
  }) : super(id);

  factory ProjectCollaborator.create({
    required UserId userId,
    required ProjectRole role,
  }) {
    return ProjectCollaborator._(
      id: ProjectCollaboratorId(),
      userId: userId,
      role: role,
      specificPermissions: [],
    );
  }

  ProjectCollaborator copyWith({
    ProjectRole? role,
    List<ProjectPermission>? specificPermissions,
  }) {
    return ProjectCollaborator._(
      id: id,
      userId: userId,
      role: role ?? this.role,
      specificPermissions: specificPermissions ?? this.specificPermissions,
    );
  }

  bool hasPermission(ProjectPermission p) {
    if (specificPermissions.contains(p)) return true;

    switch (role.value) {
      case ProjectRoleType.owner:
        return true;
      case ProjectRoleType.admin:
        return [
          ProjectPermission.addCollaborator,
          ProjectPermission.removeCollaborator,
          ProjectPermission.updateCollaboratorRole,
          ProjectPermission.addTrack,
          ProjectPermission.editTrack,
          ProjectPermission.deleteTrack,
          ProjectPermission.addComment,
          ProjectPermission.editComment,
          ProjectPermission.deleteComment,
          ProjectPermission.addTask,
          ProjectPermission.editTask,
          ProjectPermission.deleteTask,
          ProjectPermission.addFile,
          ProjectPermission.editFile,
          ProjectPermission.deleteFile,
        ].contains(p);
      case ProjectRoleType.editor:
        return [
          ProjectPermission.addTrack,
          ProjectPermission.editTrack,
          ProjectPermission.addComment,
          ProjectPermission.editComment,
          ProjectPermission.addTask,
          ProjectPermission.editTask,
          ProjectPermission.addFile,
          ProjectPermission.editFile,
        ].contains(p);
      case ProjectRoleType.viewer:
        return false;
    }
  }
}
