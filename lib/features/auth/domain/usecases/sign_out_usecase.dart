import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:trackflow/features/auth/domain/usecases/onboarding_usacase.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

@lazySingleton
class SignOutUseCase {
  final AuthRepository _authRepository;
  final UserProfileRepository _userProfileRepository;
  final OnboardingUseCase _onboardingUseCase;

  SignOutUseCase(
    this._authRepository,
    this._userProfileRepository,
    this._onboardingUseCase,
  );

  Future<Either<Failure, Unit>> call() async {
    try {
      // 1. ✅ Get current user ID before signing out
      final userIdResult = await _authRepository.getSignedInUserId();
      final userId = await userIdResult.fold(
        (failure) async => null,
        (userId) async => userId,
      );

      // 2. ✅ Clear profile cache (UserProfileRepository responsibility)
      try {
        await _userProfileRepository.clearProfileCache();
      } catch (e) {
        // Don't fail logout if profile cache clearing fails
        print('Warning: Failed to clear profile cache during sign out: $e');
      }

      // 3. ❌ REMOVED: Don't clear onboarding data on sign out
      // Onboarding is a one-time experience that shouldn't be repeated
      // The user has already completed onboarding and shouldn't have to do it again

      // 4. ✅ Sign out user (AuthRepository responsibility)
      return await _authRepository.signOut();
    } catch (e) {
      return Left(AuthenticationFailure('Failed to sign out: $e'));
    }
  }
}
