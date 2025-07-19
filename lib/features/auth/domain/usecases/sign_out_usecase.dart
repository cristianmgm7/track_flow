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
    // 1. ✅ Clear profile cache (UserProfileRepository responsibility)
    try {
      await _userProfileRepository.clearProfileCache();
    } catch (e) {
      // Don't fail logout if profile cache clearing fails
      print('Warning: Failed to clear profile cache during sign out: $e');
    }

    // 2. ✅ Sign out user (AuthRepository responsibility)
    return await _authRepository.signOut();
  }
}
