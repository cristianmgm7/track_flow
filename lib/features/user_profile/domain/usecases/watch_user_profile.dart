import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

@lazySingleton
class WatchUserProfileUseCase {
  final UserProfileRepository _userProfileRepository;
  final SessionStorage _sessionStorage;

  WatchUserProfileUseCase(this._userProfileRepository, this._sessionStorage);

  Stream<Either<Failure, UserProfile?>> call() {
    final userId = _sessionStorage.getUserId();
    if (userId == null) {
      return Stream.value(Left(ServerFailure('No user found')));
    }
    final stream = _userProfileRepository.watchUserProfile(
      UserId.fromUniqueString(userId),
    );
    return stream.map(
      (either) =>
          either.fold((failure) => left(failure), (profile) => right(profile)),
    );
  }
}
