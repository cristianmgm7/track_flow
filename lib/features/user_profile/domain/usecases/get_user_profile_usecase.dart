import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

@injectable
class GetUserProfileUseCase {
  final UserProfileRepository repository;
  final SessionStorage sessionStorage;

  GetUserProfileUseCase(this.repository, this.sessionStorage);

  Future<Either<Failure, UserProfile>> call() async {
    final userId = sessionStorage.getUserId();
    if (userId == null) {
      return left(UnexpectedFailure('User not found'));
    }
    return await repository.getUserProfile(UserId.fromUniqueString(userId));
  }
}
