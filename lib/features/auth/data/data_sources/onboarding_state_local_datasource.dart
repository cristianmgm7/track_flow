import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';

/// Local data source responsible for onboarding and welcome screen state
/// Follows Single Responsibility Principle - only handles onboarding flow state
abstract class OnboardingStateLocalDataSource {
  Future<Either<Failure, Unit>> setOnboardingCompleted(bool completed);
  Future<Either<Failure, bool>> isOnboardingCompleted();
  Future<Either<Failure, Unit>> setWelcomeScreenSeen(bool seen);
  Future<Either<Failure, bool>> isWelcomeScreenSeen();
  Future<Either<Failure, Unit>> clearAllOnboardingData();
}

@LazySingleton(as: OnboardingStateLocalDataSource)
class OnboardingStateLocalDataSourceImpl
    implements OnboardingStateLocalDataSource {
  final SharedPreferences _prefs;

  OnboardingStateLocalDataSourceImpl(this._prefs);

  @override
  Future<Either<Failure, Unit>> setOnboardingCompleted(bool completed) async {
    try {
      await _prefs.setBool('onboardingCompleted', completed);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to set onboarding completed: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isOnboardingCompleted() async {
    try {
      final completed = _prefs.getBool('onboardingCompleted') ?? false;
      return Right(completed);
    } catch (e) {
      return Left(CacheFailure('Failed to check onboarding status: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> setWelcomeScreenSeen(bool seen) async {
    try {
      await _prefs.setBool('welcomeScreenSeenCompleted', seen);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to set welcome screen seen: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isWelcomeScreenSeen() async {
    try {
      final seen = _prefs.getBool('welcomeScreenSeenCompleted') ?? false;
      return Right(seen);
    } catch (e) {
      return Left(CacheFailure('Failed to check welcome screen status: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearAllOnboardingData() async {
    try {
      await _prefs.clear();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to clear onboarding data: $e'));
    }
  }
}
