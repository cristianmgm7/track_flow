import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/domain/repositories/onboarding_repository.dart';

@lazySingleton
class OnboardingUseCase {
  final OnboardingRepository _onboardingRepository;

  OnboardingUseCase(this._onboardingRepository);

  Future<Either<Failure, Unit>> onboardingCompleted() async {
    return await _onboardingRepository.onboardingCompleted();
  }

  Future<Either<Failure, bool>> checkOnboardingCompleted() async {
    return await _onboardingRepository.checkOnboardingCompleted();
  }
}
