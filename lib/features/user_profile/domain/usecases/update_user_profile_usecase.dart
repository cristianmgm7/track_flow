import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

@injectable
class UpdateUserProfileUseCase {
  final UserProfileRepository repository;
  final SessionStorage sessionStorage;

  UpdateUserProfileUseCase(this.repository, this.sessionStorage);

  Future<Either<Failure, void>> call(UserProfile userProfile) async {
    final userId = sessionStorage.getUserId();
    if (userId == null) {
      return left(UnexpectedFailure('User not found'));
    }
    userProfile = userProfile.copyWith(id: UserId.fromUniqueString(userId));
    return await repository.updateUserProfile(userProfile);
  }
}
