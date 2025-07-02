import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/domain/repositories/onboarding_repository.dart';
import 'package:trackflow/features/auth/domain/repositories/welcome_screen_repository.dart';

@lazySingleton
class OnboardingUseCase {
  final OnboardingRepository _onboardingRepository;
  final WelcomeScreenRepository _welcomeScreenRepository;
  
  OnboardingUseCase(
    this._onboardingRepository,
    this._welcomeScreenRepository,
  );

  Future<Either<Failure, Unit>> onboardingCompleted() async {
    return await _onboardingRepository.onboardingCompleted();
  }

  Future<Either<Failure, Unit>> welcomeScreenSeenCompleted() async {
    return await _welcomeScreenRepository.welcomeScreenSeenCompleted();
  }

  Future<Either<Failure, bool>> checkWelcomeScreenSeen() async {
    return await _welcomeScreenRepository.checkWelcomeScreenSeen();
  }

  Future<Either<Failure, bool>> checkOnboardingCompleted() async {
    return await _onboardingRepository.checkOnboardingCompleted();
  }
}
