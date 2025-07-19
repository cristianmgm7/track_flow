import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:trackflow/features/user_profile/domain/validators/profile_completeness_validator.dart';

@lazySingleton
class CheckProfileCompletenessUseCase {
  final UserProfileRepository _userProfileRepository;
  final SessionStorage _sessionStorage;

  CheckProfileCompletenessUseCase(
    this._userProfileRepository,
    this._sessionStorage,
  );

  Future<Either<Failure, bool>> call() async {
    try {
      final userId = _sessionStorage.getUserId();
      if (userId == null) {
        return Left(ServerFailure('No user session found'));
      }

      final result = await _userProfileRepository.getUserProfile(
        UserId.fromUniqueString(userId),
      );

      return result.fold((failure) => Left(failure), (profile) {
        if (profile == null) {
          return Right(false);
        }

        final isComplete = ProfileCompletenessValidator.isComplete(profile);
        return Right(isComplete);
      });
    } catch (e) {
      return Left(ServerFailure('Failed to check profile completeness: $e'));
    }
  }

  /// Get detailed profile completeness information
  Future<
    Either<Failure, ({bool isComplete, String reason, UserProfile? profile})>
  >
  getDetailedCompleteness() async {
    try {
      final userId = _sessionStorage.getUserId();

      if (userId == null) {
        return Left(ServerFailure('No user session found'));
      }

      final result = await _userProfileRepository.getUserProfile(
        UserId.fromUniqueString(userId),
      );

      return result.fold((failure) => Left(failure), (profile) {
        if (profile == null) {
          return Right((
            isComplete: false,
            reason: 'Profile not found',
            profile: null,
          ));
        }

        final isComplete = ProfileCompletenessValidator.isComplete(profile);
        final reason = ProfileCompletenessValidator.getIncompletenessReason(
          profile,
        );

        return Right((
          isComplete: isComplete,
          reason: reason,
          profile: profile,
        ));
      });
    } catch (e) {
      return Left(ServerFailure('Failed to check profile completeness: $e'));
    }
  }
}
