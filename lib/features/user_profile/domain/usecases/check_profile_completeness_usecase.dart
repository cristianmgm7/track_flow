import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

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
    print(
      '🔍 CheckProfileCompletenessUseCase - Checking profile for userId: $userId',
    );

    if (userId == null) {
      print('❌ CheckProfileCompletenessUseCase - No userId provided');
      return Right(
        ProfileCompletenessInfo(
          isComplete: false,
          profile: null,
          reason: 'User ID is required',
        ),
      );
    }

    final userIdObj = UserId.fromUniqueString(userId);
    print(
      '🔍 CheckProfileCompletenessUseCase - Getting profile from repository',
    );
    final result = await _repository.getUserProfile(userIdObj);

    return result.fold(
      (failure) {
        print(
          '❌ CheckProfileCompletenessUseCase - Repository failed: ${failure.message}',
        );
        return Left(failure);
      },
      (profile) {
        print(
          '🔍 CheckProfileCompletenessUseCase - Profile found: ${profile?.name}',
        );

        if (profile == null) {
          print('❌ CheckProfileCompletenessUseCase - No profile found');
          return Right(
            ProfileCompletenessInfo(
              isComplete: false,
              profile: null,
              reason: 'Profile not found',
            ),
          );
        }

        final isComplete = _isProfileComplete(profile);
        print(
          '🔍 CheckProfileCompletenessUseCase - Profile complete: $isComplete',
        );
        print(
          '🔍 CheckProfileCompletenessUseCase - Profile details: name=${profile.name}, email=${profile.email}, avatar=${profile.avatarUrl}',
        );

        if (isComplete) {
          print('✅ CheckProfileCompletenessUseCase - Profile is complete');
          return Right(
            ProfileCompletenessInfo(
              isComplete: true,
              profile: profile,
              reason: 'Profile is complete',
            ),
          );
        } else {
          print('❌ CheckProfileCompletenessUseCase - Profile is incomplete');
          return Right(
            ProfileCompletenessInfo(
              isComplete: false,
              profile: profile,
              reason: 'Profile is incomplete',
            ),
          );
        }
      },
    );
  }

  bool _isProfileComplete(UserProfile profile) {
    final hasName = profile.name.isNotEmpty;
    final hasEmail = profile.email.isNotEmpty;
    final hasAvatar = profile.avatarUrl.isNotEmpty;

    print('🔍 _isProfileComplete - Checking profile completeness:');
    print('  - hasName: $hasName (${profile.name})');
    print('  - hasEmail: $hasEmail (${profile.email})');
    print('  - hasAvatar: $hasAvatar (${profile.avatarUrl})');

    // TEMPORARY: Only require name and avatar, skip email requirement
    // TODO: Re-enable email requirement after fixing auth state
    final isComplete = hasName && hasAvatar; // Removed hasEmail requirement

    print(
      '🔍 _isProfileComplete - Result: $isComplete (TEMPORARY: email not required)',
    );

    return isComplete;
  }
}
