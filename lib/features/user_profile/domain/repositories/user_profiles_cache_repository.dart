import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

/// Repository responsible for bulk user profile cache operations
/// Follows Single Responsibility Principle - only handles profile caching and batch operations
abstract class UserProfileCacheRepository {
  /// Cache a list of user profiles locally (for offline-first, e.g. collaborators)
  Future<Either<Failure, Unit>> cacheUserProfiles(List<UserProfile> profiles);

  /// Watch a list of user profiles by their IDs (reactive, for offline-first UI)
  Stream<Either<Failure, List<UserProfile>>> watchUserProfilesByIds(
    List<UserId> userIds,
  );

  /// Get a list of user profiles by their IDs (one-time fetch)
  Future<Either<Failure, List<UserProfile>>> getUserProfilesByIds(
    List<UserId> userIds,
  );

  /// Clear all cached user profiles
  Future<Either<Failure, Unit>> clearCache();

  /// Preload user profiles for better offline experience
  Future<Either<Failure, Unit>> preloadProfiles(List<UserId> userIds);
}
