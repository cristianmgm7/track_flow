import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart';
import 'package:trackflow/core/utils/app_logger.dart';

@lazySingleton
class OnboardingUseCase {
  final OnboardingRepository _onboardingRepository;

  OnboardingUseCase(this._onboardingRepository);

  Future<Either<Failure, Unit>> onboardingCompleted(String userId) async {
    AppLogger.info(
      'OnboardingUseCase: Marking onboarding as completed for user: $userId',
      tag: 'ONBOARDING_USECASE',
    );

    final result = await _onboardingRepository.onboardingCompleted(userId);

    result.fold(
      (failure) {
        AppLogger.error(
          'OnboardingUseCase: Failed to mark onboarding completed: ${failure.message}',
          tag: 'ONBOARDING_USECASE',
          error: failure,
        );
      },
      (_) {
        AppLogger.info(
          'OnboardingUseCase: Successfully marked onboarding as completed for user: $userId',
          tag: 'ONBOARDING_USECASE',
        );
      },
    );

    return result;
  }

  Future<Either<Failure, bool>> checkOnboardingCompleted(String userId) async {
    AppLogger.info(
      'OnboardingUseCase: Checking onboarding completed for user: $userId',
      tag: 'ONBOARDING_USECASE',
    );

    final result = await _onboardingRepository.checkOnboardingCompleted(userId);

    result.fold(
      (failure) {
        AppLogger.error(
          'OnboardingUseCase: Failed to check onboarding completed: ${failure.message}',
          tag: 'ONBOARDING_USECASE',
          error: failure,
        );
      },
      (completed) {
        AppLogger.info(
          'OnboardingUseCase: Onboarding completed check result: $completed for user: $userId',
          tag: 'ONBOARDING_USECASE',
        );
      },
    );

    return result;
  }

  Future<Either<Failure, Unit>> resetOnboarding(String userId) async {
    AppLogger.info(
      'OnboardingUseCase: Resetting onboarding for user: $userId',
      tag: 'ONBOARDING_USECASE',
    );

    final result = await _onboardingRepository.resetOnboarding(userId);

    result.fold(
      (failure) {
        AppLogger.error(
          'OnboardingUseCase: Failed to reset onboarding: ${failure.message}',
          tag: 'ONBOARDING_USECASE',
          error: failure,
        );
      },
      (_) {
        AppLogger.info(
          'OnboardingUseCase: Successfully reset onboarding for user: $userId',
          tag: 'ONBOARDING_USECASE',
        );
      },
    );

    return result;
  }

  Future<Either<Failure, Unit>> clearUserOnboardingData(String userId) async {
    AppLogger.info(
      'OnboardingUseCase: Clearing onboarding data for user: $userId',
      tag: 'ONBOARDING_USECASE',
    );

    final result = await _onboardingRepository.clearUserOnboardingData(userId);

    result.fold(
      (failure) {
        AppLogger.error(
          'OnboardingUseCase: Failed to clear user onboarding data: ${failure.message}',
          tag: 'ONBOARDING_USECASE',
          error: failure,
        );
      },
      (_) {
        AppLogger.info(
          'OnboardingUseCase: Successfully cleared onboarding data for user: $userId',
          tag: 'ONBOARDING_USECASE',
        );
      },
    );

    return result;
  }

  Future<Either<Failure, Unit>> clearAllOnboardingData() async {
    AppLogger.info(
      'OnboardingUseCase: Clearing all onboarding data',
      tag: 'ONBOARDING_USECASE',
    );

    final result = await _onboardingRepository.clearAllOnboardingData();

    result.fold(
      (failure) {
        AppLogger.error(
          'OnboardingUseCase: Failed to clear all onboarding data: ${failure.message}',
          tag: 'ONBOARDING_USECASE',
          error: failure,
        );
      },
      (_) {
        AppLogger.info(
          'OnboardingUseCase: Successfully cleared all onboarding data',
          tag: 'ONBOARDING_USECASE',
        );
      },
    );

    return result;
  }
}
