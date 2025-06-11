import 'package:injectable/injectable.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/exceptions/project_exceptions.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_permission.dart';
import 'package:trackflow/core/entities/unique_id.dart';

@lazySingleton
class ProjectTrackService {
  bool canAddTrack({required Project project, required UserId userId}) {
    final collaborator = project.collaborators.firstWhere(
      (c) => c.userId == userId,
      orElse: () => throw UserNotCollaboratorException(),
    );

    return collaborator.hasPermission(ProjectPermission.addTrack);
  }
}
