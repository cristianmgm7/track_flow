import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';

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
    try {
      await _prefs.setBool('onboardingCompleted_$userId', completed);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to set onboarding completed: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isOnboardingCompleted(String userId) async {
    try {
      final completed = _prefs.getBool('onboardingCompleted_$userId') ?? false;
      return Right(completed);
    } catch (e) {
      return Left(CacheFailure('Failed to check onboarding status: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> setWelcomeScreenSeen(
    String userId,
    bool seen,
  ) async {
    try {
      await _prefs.setBool('welcomeScreenSeenCompleted_$userId', seen);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to set welcome screen seen: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isWelcomeScreenSeen(String userId) async {
    try {
      final seen =
          _prefs.getBool('welcomeScreenSeenCompleted_$userId') ?? false;
      return Right(seen);
    } catch (e) {
      return Left(CacheFailure('Failed to check welcome screen status: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearUserOnboardingData(String userId) async {
    try {
      await _prefs.remove('onboardingCompleted_$userId');
      await _prefs.remove('welcomeScreenSeenCompleted_$userId');
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to clear user onboarding data: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearAllOnboardingData() async {
    try {
      // Get all keys and remove only onboarding-related ones
      final keys = _prefs.getKeys();
      final onboardingKeys = keys.where(
        (key) =>
            key.startsWith('onboardingCompleted_') ||
            key.startsWith('welcomeScreenSeenCompleted_'),
      );

      for (final key in onboardingKeys) {
        await _prefs.remove(key);
      }
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to clear onboarding data: $e'));
    }
  }
}
