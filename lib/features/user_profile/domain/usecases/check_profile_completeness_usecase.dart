import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:trackflow/core/utils/app_logger.dart';

class ProfileCompletenessInfo {
  final bool isComplete;
  final UserProfile? profile;
  final String reason;

  ProfileCompletenessInfo({
    required this.isComplete,
    this.profile,
    required this.reason,
  });
}

@injectable
class CheckProfileCompletenessUseCase {
  final UserProfileRepository _repository;

  CheckProfileCompletenessUseCase(this._repository);

  Future<bool> isProfileComplete(String userId) async {
    final result = await _repository.getUserProfile(
      UserId.fromUniqueString(userId),
    );
    return result.fold(
      (failure) => false,
      (profile) => profile != null && _isProfileComplete(profile),
    );
  }

  Future<Either<Failure, ProfileCompletenessInfo>> getDetailedCompleteness([
    String? userId,
  ]) async {
    if (userId == null) {
      AppLogger.warning(
        'getDetailedCompleteness called with null userId',
        tag: 'PROFILE_COMPLETENESS',
      );
      return Right(
        ProfileCompletenessInfo(
          isComplete: false,
          profile: null,
          reason: 'User ID is required',
        ),
      );
    }

    AppLogger.info(
      'Checking profile completeness for user: $userId',
      tag: 'PROFILE_COMPLETENESS',
    );

    final userIdObj = UserId.fromUniqueString(userId);
    final result = await _repository.getUserProfile(userIdObj);

    return result.fold(
      (failure) {
        // Handle the case where profile doesn't exist (normal for new users)
        if (failure.message.contains('not found') ||
            failure.message.contains('Profile not found')) {
          AppLogger.info(
            'Profile not found for user $userId - this is normal for new users',
            tag: 'PROFILE_COMPLETENESS',
          );
          return Right(
            ProfileCompletenessInfo(
              isComplete: false,
              profile: null,
              reason: 'Profile not found - user needs to create profile',
            ),
          );
        }

        // For other failures, return the failure
        AppLogger.error(
          'Profile completeness check failed: ${failure.message}',
          tag: 'PROFILE_COMPLETENESS',
          error: failure,
        );
        return Left(failure);
      },
      (profile) {
        if (profile == null) {
          AppLogger.info(
            'Profile is null for user $userId - user needs to create profile',
            tag: 'PROFILE_COMPLETENESS',
          );
          return Right(
            ProfileCompletenessInfo(
              isComplete: false,
              profile: null,
              reason: 'Profile not found - user needs to create profile',
            ),
          );
        }

        final isComplete = _isProfileComplete(profile);

        AppLogger.info(
          'Profile completeness result: $isComplete for user $userId',
          tag: 'PROFILE_COMPLETENESS',
        );

        if (isComplete) {
          return Right(
            ProfileCompletenessInfo(
              isComplete: true,
              profile: profile,
              reason: 'Profile is complete',
            ),
          );
        } else {
          return Right(
            ProfileCompletenessInfo(
              isComplete: false,
              profile: profile,
              reason: 'Profile is incomplete - missing required fields',
            ),
          );
        }
      },
    );
  }

  bool _isProfileComplete(UserProfile profile) {
    final hasName = profile.name.isNotEmpty;
    final hasEmail = profile.email.isNotEmpty;
    // Avatar optional (Plan A): only require name and email
    final isComplete = hasName && hasEmail;

    AppLogger.debug(
      'Profile completeness check: name=$hasName, email=$hasEmail, complete=$isComplete',
      tag: 'PROFILE_COMPLETENESS',
    );

    // Add detailed logging to see actual values
    AppLogger.info(
      'Profile completeness details - name: "${profile.name}", email: "${profile.email}"',
      tag: 'PROFILE_COMPLETENESS',
    );

    return isComplete;
  }
}
