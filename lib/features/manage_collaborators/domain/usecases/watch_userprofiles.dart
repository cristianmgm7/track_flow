import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

class GetProjectWithUserProfilesParams {
  final ProjectId projectId;

  GetProjectWithUserProfilesParams({required this.projectId});
}

@lazySingleton
class WatchUserProfilesUseCase {
  final UserProfileRepository userProfileRepository;

  WatchUserProfilesUseCase(this.userProfileRepository);

  Stream<List<UserProfile>> call(List<String> userIds) {
    return userProfileRepository.watchUserProfilesByIds(userIds);
  }
}
