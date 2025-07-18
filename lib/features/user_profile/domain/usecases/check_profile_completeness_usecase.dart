import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

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
        // Consider profile complete if it exists in local storage
        // and has a name (which is required in profile creation)
        final isComplete = profile != null && profile.name.isNotEmpty;
        return Right(isComplete);
      });
    } catch (e) {
      return Left(ServerFailure('Failed to check profile completeness: $e'));
    }
  }
}
