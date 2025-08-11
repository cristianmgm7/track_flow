import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

/// Creates a new user profile for the current authenticated user.
///
/// Semantically distinct from update, but currently implemented
/// as an upsert via the repository's update method to keep the
/// data layer simple. This separation preserves domain intent.
@injectable
class CreateUserProfileUseCase {
  final UserProfileRepository _repository;
  final SessionStorage _sessionStorage;

  CreateUserProfileUseCase(this._repository, this._sessionStorage);

  Future<Either<Failure, void>> call(UserProfile userProfile) async {
    final userId = await _sessionStorage.getUserId();
    if (userId == null) {
      return left(UnexpectedFailure('User not found'));
    }

    final profileWithId = userProfile.copyWith(
      id: UserId.fromUniqueString(userId),
    );

    // Upsert: repository handles local-first write and remote sync
    return _repository.updateUserProfile(profileWithId);
  }
}
