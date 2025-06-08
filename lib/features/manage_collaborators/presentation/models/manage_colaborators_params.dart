import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class ManageCollaboratorsParams {
  final Project project;
  final List<UserProfile> collaborators;

  ManageCollaboratorsParams({
    required this.project,
    required this.collaborators,
  });
}
