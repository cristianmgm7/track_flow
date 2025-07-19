import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/domain/entities/user.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

@lazySingleton
class GoogleSignInUseCase {
  final AuthRepository _authRepository;
  final UserProfileRepository _userProfileRepository;

  GoogleSignInUseCase(this._authRepository, this._userProfileRepository);

  Future<Either<Failure, User>> call() async {
    // 1. ✅ Authenticate user with Google (AuthRepository responsibility)
    final authResult = await _authRepository.signInWithGoogle();

    return authResult.fold((failure) => Left(failure), (user) async {
      // 2. ✅ Sync user profile (UserProfileRepository responsibility)
      try {
        await _userProfileRepository.syncProfileFromRemote(user.id);
      } catch (e) {
        // Don't fail authentication if profile sync fails
        // Profile will be handled by the profile creation flow
        print('Warning: Failed to sync profile after Google sign in: $e');
      }

      return Right(user);
    });
  }
}
