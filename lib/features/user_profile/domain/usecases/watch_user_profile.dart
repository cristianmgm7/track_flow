import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/session/data/session_storage.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

@lazySingleton
class WatchUserProfileUseCase {
  final UserProfileRepository _userProfileRepository;
  final SessionStorage _sessionStorage;

  WatchUserProfileUseCase(this._userProfileRepository, this._sessionStorage);

  Stream<Either<Failure, UserProfile?>> call([String? userId]) async* {
    final id = userId ?? await _sessionStorage.getUserId();
    if (id == null) {
      yield Left(ServerFailure('No user found'));
      return;
    }
    final stream = _userProfileRepository.watchUserProfile(
      UserId.fromUniqueString(id),
    );
    await for (final either in stream) {
      yield either.fold(
        (failure) => left(failure),
        (profile) => right(profile),
      );
    }
  }
}
