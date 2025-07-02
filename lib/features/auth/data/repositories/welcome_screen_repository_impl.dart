import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/domain/repositories/welcome_screen_repository.dart';
import 'package:trackflow/features/auth/data/data_sources/onboarding_state_local_datasource.dart';

@LazySingleton(as: WelcomeScreenRepository)
class WelcomeScreenRepositoryImpl implements WelcomeScreenRepository {
  final OnboardingStateLocalDataSource _onboardingStateDataSource;

  WelcomeScreenRepositoryImpl(this._onboardingStateDataSource);

  @override
  Future<Either<Failure, Unit>> welcomeScreenSeenCompleted() async {
    return await _onboardingStateDataSource.setWelcomeScreenSeen(true);
  }

  @override
  Future<Either<Failure, bool>> checkWelcomeScreenSeen() async {
    return await _onboardingStateDataSource.isWelcomeScreenSeen();
  }
}