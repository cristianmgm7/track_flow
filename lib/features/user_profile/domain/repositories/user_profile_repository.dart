import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, void>> updateUserProfile(UserProfile userProfile);

  Stream<Either<Failure, UserProfile?>> watchUserProfile(UserId userId);

  /// Cache a list of user profiles locally (for offline-first, e.g. collaborators)
  Future<void> cacheUserProfiles(List<UserProfile> profiles);

  /// Watch a list of user profiles by their IDs (reactive, for offline-first UI)
  Stream<List<UserProfile>> watchUserProfilesByIds(List<String> userIds);

  /// Get a list of user profiles by their IDs (one-time fetch)
  Future<Either<Failure, List<UserProfile>>> getUserProfilesByIds(
    List<String> userIds,
  );
}
