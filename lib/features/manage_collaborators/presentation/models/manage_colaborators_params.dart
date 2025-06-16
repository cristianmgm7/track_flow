import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class ManageCollaboratorsParams {
  final ProjectId projectId;
  final List<UserProfile> collaborators;

  ManageCollaboratorsParams({
    required this.projectId,
    required this.collaborators,
  });
}
