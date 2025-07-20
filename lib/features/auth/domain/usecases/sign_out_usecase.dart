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

      // 3. ✅ Clear user-specific onboarding data if we have a user ID
      if (userId != null) {
        try {
          await _onboardingUseCase.clearUserOnboardingData(userId.value);
        } catch (e) {
          // Don't fail logout if onboarding data clearing fails
          print('Warning: Failed to clear onboarding data during sign out: $e');
        }
      }

      // 4. ✅ Sign out user (AuthRepository responsibility)
      return await _authRepository.signOut();
    } catch (e) {
      return Left(AuthenticationFailure('Failed to sign out: $e'));
    }
  }
}
