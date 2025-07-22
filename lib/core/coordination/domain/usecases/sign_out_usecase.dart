import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

@lazySingleton
class SignOutUseCase {
  final AuthRepository _authRepository;
  final UserProfileRepository _userProfileRepository;

  SignOutUseCase(this._authRepository, this._userProfileRepository);

  Future<Either<Failure, Unit>> call() async {
    try {
      await _userProfileRepository.clearProfileCache();

      return await _authRepository.signOut();
    } catch (e) {
      return Left(AuthenticationFailure('Failed to sign out: $e'));
    }
  }
}