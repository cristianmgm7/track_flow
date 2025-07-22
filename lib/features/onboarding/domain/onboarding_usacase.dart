import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart';

@lazySingleton
class OnboardingUseCase {
  final OnboardingRepository _onboardingRepository;

  OnboardingUseCase(this._onboardingRepository);

  Future<Either<Failure, Unit>> onboardingCompleted(String userId) async {
    return await _onboardingRepository.onboardingCompleted(userId);
  }

  Future<Either<Failure, bool>> checkOnboardingCompleted(String userId) async {
    return await _onboardingRepository.checkOnboardingCompleted(userId);
  }

  Future<Either<Failure, Unit>> resetOnboarding(String userId) async {
    return await _onboardingRepository.resetOnboarding(userId);
  }

  Future<Either<Failure, Unit>> clearUserOnboardingData(String userId) async {
    return await _onboardingRepository.clearUserOnboardingData(userId);
  }

  Future<Either<Failure, Unit>> clearAllOnboardingData() async {
    return await _onboardingRepository.clearAllOnboardingData();
  }
}
