import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

/// Use case to find a user by email address
/// Returns the user profile if found, null if not found
@lazySingleton
class FindUserByEmailUseCase {
  final UserProfileRepository _userProfileRepository;

  FindUserByEmailUseCase(this._userProfileRepository);

  /// Find a user by email address
  /// Returns the user profile if found, null if not found
  Future<Either<Failure, UserProfile?>> call(String email) async {
    try {
      // Validate email format
      if (email.isEmpty) {
        return Left(ServerFailure('Email cannot be empty'));
      }

      // Check if email has basic format
      if (!email.contains('@')) {
        return Left(ServerFailure('Invalid email format'));
      }

      // Search for user by email in the repository
      // This will search both local cache and remote database
      final result = await _userProfileRepository.findUserByEmail(email);

      return result.fold(
        (failure) => Left(failure),
        (userProfile) => Right(userProfile),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to find user by email: $e'));
    }
  }
}
