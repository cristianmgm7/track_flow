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
    if (userId == null) {
      return Right(
        ProfileCompletenessInfo(
          isComplete: false,
          profile: null,
          reason: 'User ID is required',
        ),
      );
    }

    final userIdObj = UserId.fromUniqueString(userId);
    final result = await _repository.getUserProfile(userIdObj);
    return result.fold((failure) => Left(failure), (profile) {
      if (profile == null) {
        return Right(
          ProfileCompletenessInfo(
            isComplete: false,
            profile: null,
            reason: 'Profile not found',
          ),
        );
      }

      final isComplete = _isProfileComplete(profile);
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
            reason: 'Profile is incomplete',
          ),
        );
      }
    });
  }

  bool _isProfileComplete(UserProfile profile) {
    return profile.name.isNotEmpty &&
        profile.email.isNotEmpty &&
        profile.avatarUrl.isNotEmpty;
  }
}
