import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class ProjectWithCollaborators {
  final Project project;
  final List<UserProfile> collaborators;

  const ProjectWithCollaborators({
    required this.project,
    required this.collaborators,
  });

  ProjectWithCollaborators copyWith({
    Project? project,
    List<UserProfile>? collaborators,
  }) {
    return ProjectWithCollaborators(
      project: project ?? this.project,
      collaborators: collaborators ?? this.collaborators,
    );
  }
}
