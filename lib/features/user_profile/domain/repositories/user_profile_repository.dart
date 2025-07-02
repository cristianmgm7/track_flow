import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

/// Repository responsible for individual user profile operations
/// Follows Single Responsibility Principle - only handles single profile management
abstract class UserProfileRepository {
  /// Update a user profile
  Future<Either<Failure, Unit>> updateUserProfile(UserProfile userProfile);

  /// Watch a user profile by ID (reactive, for real-time UI updates)
  Stream<Either<Failure, UserProfile?>> watchUserProfile(UserId userId);

  /// Get a user profile by ID (one-time fetch)
  Future<Either<Failure, UserProfile?>> getUserProfile(UserId userId);
}
