import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart';

class GetProjectWithUserProfilesParams {
  final ProjectId projectId;

  GetProjectWithUserProfilesParams({required this.projectId});
}

@lazySingleton
class WatchUserProfilesUseCase {
  final UserProfileCacheRepository userProfileCacheRepository;

  WatchUserProfilesUseCase(this.userProfileCacheRepository);

  Stream<Either<Failure, List<UserProfile>>> call(List<String> userIds) {
    final userIdObjects =
        userIds.map((id) => UserId.fromUniqueString(id)).toList();
    return userProfileCacheRepository.watchUserProfilesByIds(userIdObjects);
  }
}
