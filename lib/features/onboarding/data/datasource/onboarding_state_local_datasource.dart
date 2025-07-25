import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// Local data source responsible for onboarding and welcome screen state
/// Follows Single Responsibility Principle - only handles onboarding flow state
/// Now tracks onboarding per user for better security and UX
abstract class OnboardingStateLocalDataSource {
  Future<Either<Failure, Unit>> setOnboardingCompleted(
    String userId,
    bool completed,
  );
  Future<Either<Failure, bool>> isOnboardingCompleted(String userId);
  Future<Either<Failure, Unit>> setWelcomeScreenSeen(String userId, bool seen);
  Future<Either<Failure, bool>> isWelcomeScreenSeen(String userId);
  Future<Either<Failure, Unit>> clearUserOnboardingData(String userId);
  Future<Either<Failure, Unit>> clearAllOnboardingData();
}

@LazySingleton(as: OnboardingStateLocalDataSource)
class OnboardingStateLocalDataSourceImpl
    implements OnboardingStateLocalDataSource {
  final SharedPreferences _prefs;

  OnboardingStateLocalDataSourceImpl(this._prefs);

  @override
  Future<Either<Failure, Unit>> setOnboardingCompleted(
    String userId,
    bool completed,
  ) async {
    AppLogger.info(
      'OnboardingStateLocalDataSourceImpl: Setting onboarding completed to $completed for user: $userId',
      tag: 'ONBOARDING_DATASOURCE',
    );

    try {
      final key = 'onboardingCompleted_$userId';
      AppLogger.info(
        'OnboardingStateLocalDataSourceImpl: Using key: $key',
        tag: 'ONBOARDING_DATASOURCE',
      );

      await _prefs.setBool(key, completed);

      // Verify the value was saved
      final savedValue = _prefs.getBool(key);
      AppLogger.info(
        'OnboardingStateLocalDataSourceImpl: Saved value: $savedValue for key: $key',
        tag: 'ONBOARDING_DATASOURCE',
      );

      return const Right(unit);
    } catch (e) {
      AppLogger.error(
        'OnboardingStateLocalDataSourceImpl: Failed to set onboarding completed: $e',
        tag: 'ONBOARDING_DATASOURCE',
        error: e,
      );
      return Left(CacheFailure('Failed to set onboarding completed: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isOnboardingCompleted(String userId) async {
    AppLogger.info(
      'OnboardingStateLocalDataSourceImpl: Checking onboarding completed for user: $userId',
      tag: 'ONBOARDING_DATASOURCE',
    );

    try {
      final key = 'onboardingCompleted_$userId';
      AppLogger.info(
        'OnboardingStateLocalDataSourceImpl: Using key: $key',
        tag: 'ONBOARDING_DATASOURCE',
      );

      final completed = _prefs.getBool(key) ?? false;

      AppLogger.info(
        'OnboardingStateLocalDataSourceImpl: Retrieved value: $completed for key: $key',
        tag: 'ONBOARDING_DATASOURCE',
      );

      return Right(completed);
    } catch (e) {
      AppLogger.error(
        'OnboardingStateLocalDataSourceImpl: Failed to check onboarding status: $e',
        tag: 'ONBOARDING_DATASOURCE',
        error: e,
      );
      return Left(CacheFailure('Failed to check onboarding status: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> setWelcomeScreenSeen(
    String userId,
    bool seen,
  ) async {
    AppLogger.info(
      'OnboardingStateLocalDataSourceImpl: Setting welcome screen seen to $seen for user: $userId',
      tag: 'ONBOARDING_DATASOURCE',
    );

    try {
      final key = 'welcomeScreenSeenCompleted_$userId';
      await _prefs.setBool(key, seen);

      AppLogger.info(
        'OnboardingStateLocalDataSourceImpl: Successfully set welcome screen seen for user: $userId',
        tag: 'ONBOARDING_DATASOURCE',
      );

      return const Right(unit);
    } catch (e) {
      AppLogger.error(
        'OnboardingStateLocalDataSourceImpl: Failed to set welcome screen seen: $e',
        tag: 'ONBOARDING_DATASOURCE',
        error: e,
      );
      return Left(CacheFailure('Failed to set welcome screen seen: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isWelcomeScreenSeen(String userId) async {
    AppLogger.info(
      'OnboardingStateLocalDataSourceImpl: Checking welcome screen seen for user: $userId',
      tag: 'ONBOARDING_DATASOURCE',
    );

    try {
      final key = 'welcomeScreenSeenCompleted_$userId';
      final seen = _prefs.getBool(key) ?? false;

      AppLogger.info(
        'OnboardingStateLocalDataSourceImpl: Welcome screen seen: $seen for user: $userId',
        tag: 'ONBOARDING_DATASOURCE',
      );

      return Right(seen);
    } catch (e) {
      AppLogger.error(
        'OnboardingStateLocalDataSourceImpl: Failed to check welcome screen status: $e',
        tag: 'ONBOARDING_DATASOURCE',
        error: e,
      );
      return Left(CacheFailure('Failed to check welcome screen status: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearUserOnboardingData(String userId) async {
    AppLogger.info(
      'OnboardingStateLocalDataSourceImpl: Clearing onboarding data for user: $userId',
      tag: 'ONBOARDING_DATASOURCE',
    );

    try {
      await _prefs.remove('onboardingCompleted_$userId');
      await _prefs.remove('welcomeScreenSeenCompleted_$userId');

      AppLogger.info(
        'OnboardingStateLocalDataSourceImpl: Successfully cleared onboarding data for user: $userId',
        tag: 'ONBOARDING_DATASOURCE',
      );

      return const Right(unit);
    } catch (e) {
      AppLogger.error(
        'OnboardingStateLocalDataSourceImpl: Failed to clear user onboarding data: $e',
        tag: 'ONBOARDING_DATASOURCE',
        error: e,
      );
      return Left(CacheFailure('Failed to clear user onboarding data: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearAllOnboardingData() async {
    AppLogger.info(
      'OnboardingStateLocalDataSourceImpl: Clearing all onboarding data',
      tag: 'ONBOARDING_DATASOURCE',
    );

    try {
      await _prefs.clear();

      AppLogger.info(
        'OnboardingStateLocalDataSourceImpl: Successfully cleared all onboarding data',
        tag: 'ONBOARDING_DATASOURCE',
      );

      return const Right(unit);
    } catch (e) {
      AppLogger.error(
        'OnboardingStateLocalDataSourceImpl: Failed to clear all onboarding data: $e',
        tag: 'ONBOARDING_DATASOURCE',
        error: e,
      );
      return Left(CacheFailure('Failed to clear all onboarding data: $e'));
    }
  }
}
