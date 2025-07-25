import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/onboarding/domain/repository/onboarding_repository.dart';
import 'package:trackflow/features/onboarding/data/datasource/onboarding_state_local_datasource.dart';

@LazySingleton(as: OnboardingRepository)
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingStateLocalDataSource _onboardingStateDataSource;

  OnboardingRepositoryImpl(this._onboardingStateDataSource);

  @override
  Future<Either<Failure, Unit>> onboardingCompleted(String userId) async {
    return await _onboardingStateDataSource.setOnboardingCompleted(
      userId,
      true,
    );
  }

  @override
  Future<Either<Failure, bool>> checkOnboardingCompleted(String userId) async {
    return await _onboardingStateDataSource.isOnboardingCompleted(userId);
  }

  @override
  Future<Either<Failure, Unit>> resetOnboarding(String userId) async {
    return await _onboardingStateDataSource.setOnboardingCompleted(
      userId,
      false,
    );
  }

  @override
  Future<Either<Failure, Unit>> clearUserOnboardingData(String userId) async {
    return await _onboardingStateDataSource.clearUserOnboardingData(userId);
  }

  @override
  Future<Either<Failure, Unit>> clearAllOnboardingData() async {
    return await _onboardingStateDataSource.clearAllOnboardingData();
  }
}
