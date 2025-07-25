import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart';
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart';
import 'package:trackflow/core/utils/app_logger.dart';

@LazySingleton(as: OnboardingRepository)
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingStateLocalDataSource _onboardingStateDataSource;

  OnboardingRepositoryImpl(this._onboardingStateDataSource);

  @override
  Future<Either<Failure, Unit>> onboardingCompleted(String userId) async {
    AppLogger.info(
      'OnboardingRepositoryImpl: Marking onboarding as completed for user: $userId',
      tag: 'ONBOARDING_REPOSITORY',
    );

    final result = await _onboardingStateDataSource.setOnboardingCompleted(
      userId,
      true,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'OnboardingRepositoryImpl: Failed to mark onboarding completed: ${failure.message}',
          tag: 'ONBOARDING_REPOSITORY',
          error: failure,
        );
      },
      (_) {
        AppLogger.info(
          'OnboardingRepositoryImpl: Successfully marked onboarding as completed for user: $userId',
          tag: 'ONBOARDING_REPOSITORY',
        );
      },
    );

    return result;
  }

  @override
  Future<Either<Failure, bool>> checkOnboardingCompleted(String userId) async {
    AppLogger.info(
      'OnboardingRepositoryImpl: Checking onboarding completed for user: $userId',
      tag: 'ONBOARDING_REPOSITORY',
    );

    final result = await _onboardingStateDataSource.isOnboardingCompleted(
      userId,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'OnboardingRepositoryImpl: Failed to check onboarding completed: ${failure.message}',
          tag: 'ONBOARDING_REPOSITORY',
          error: failure,
        );
      },
      (completed) {
        AppLogger.info(
          'OnboardingRepositoryImpl: Onboarding completed check result: $completed for user: $userId',
          tag: 'ONBOARDING_REPOSITORY',
        );
      },
    );

    return result;
  }

  @override
  Future<Either<Failure, Unit>> resetOnboarding(String userId) async {
    AppLogger.info(
      'OnboardingRepositoryImpl: Resetting onboarding for user: $userId',
      tag: 'ONBOARDING_REPOSITORY',
    );

    final result = await _onboardingStateDataSource.setOnboardingCompleted(
      userId,
      false,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'OnboardingRepositoryImpl: Failed to reset onboarding: ${failure.message}',
          tag: 'ONBOARDING_REPOSITORY',
          error: failure,
        );
      },
      (_) {
        AppLogger.info(
          'OnboardingRepositoryImpl: Successfully reset onboarding for user: $userId',
          tag: 'ONBOARDING_REPOSITORY',
        );
      },
    );

    return result;
  }

  @override
  Future<Either<Failure, Unit>> clearUserOnboardingData(String userId) async {
    AppLogger.info(
      'OnboardingRepositoryImpl: Clearing onboarding data for user: $userId',
      tag: 'ONBOARDING_REPOSITORY',
    );

    final result = await _onboardingStateDataSource.clearUserOnboardingData(
      userId,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'OnboardingRepositoryImpl: Failed to clear user onboarding data: ${failure.message}',
          tag: 'ONBOARDING_REPOSITORY',
          error: failure,
        );
      },
      (_) {
        AppLogger.info(
          'OnboardingRepositoryImpl: Successfully cleared onboarding data for user: $userId',
          tag: 'ONBOARDING_REPOSITORY',
        );
      },
    );

    return result;
  }

  @override
  Future<Either<Failure, Unit>> clearAllOnboardingData() async {
    AppLogger.info(
      'OnboardingRepositoryImpl: Clearing all onboarding data',
      tag: 'ONBOARDING_REPOSITORY',
    );

    final result = await _onboardingStateDataSource.clearAllOnboardingData();

    result.fold(
      (failure) {
        AppLogger.error(
          'OnboardingRepositoryImpl: Failed to clear all onboarding data: ${failure.message}',
          tag: 'ONBOARDING_REPOSITORY',
          error: failure,
        );
      },
      (_) {
        AppLogger.info(
          'OnboardingRepositoryImpl: Successfully cleared all onboarding data',
          tag: 'ONBOARDING_REPOSITORY',
        );
      },
    );

    return result;
  }
}
