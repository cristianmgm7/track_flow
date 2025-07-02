import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/domain/repositories/onboarding_repository.dart';
import 'package:trackflow/features/auth/data/data_sources/onboarding_state_local_datasource.dart';

@LazySingleton(as: OnboardingRepository)
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingStateLocalDataSource _onboardingStateDataSource;

  OnboardingRepositoryImpl(this._onboardingStateDataSource);

  @override
  Future<Either<Failure, Unit>> onboardingCompleted() async {
    return await _onboardingStateDataSource.setOnboardingCompleted(true);
  }

  @override
  Future<Either<Failure, bool>> checkOnboardingCompleted() async {
    return await _onboardingStateDataSource.isOnboardingCompleted();
  }
}