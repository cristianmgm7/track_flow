import 'package:trackflow/features/auth/domain/repositories/onboarding_repository.dart';

class OnboardingUseCase {
  final OnboardingRepository _repository;

  OnboardingUseCase(this._repository);

  Future<bool> isOnboardingCompleted() async {
    final result = await _repository.checkOnboardingCompleted();
    return result.fold((failure) => false, (isCompleted) => isCompleted);
  }
}
