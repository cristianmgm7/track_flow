import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'user_session_local_datasource.dart';
import 'onboarding_state_local_datasource.dart';

/// Legacy auth local data source for backward compatibility
/// DEPRECATED: Use UserSessionLocalDataSource and OnboardingStateLocalDataSource directly
/// This composite will be removed in future versions
@Deprecated('Use UserSessionLocalDataSource and OnboardingStateLocalDataSource directly')
abstract class AuthLocalDataSource {
  Future<Either<Failure, Unit>> cacheUserId(String userId);
  Future<Either<Failure, String?>> getCachedUserId();
  Future<Either<Failure, Unit>> setOnboardingCompleted(bool completed);
  Future<Either<Failure, bool>> isOnboardingCompleted();
  Future<Either<Failure, Unit>> setWelcomeScreenSeen(bool seen);
  Future<Either<Failure, bool>> isWelcomeScreenSeen();
  Future<Either<Failure, Unit>> setOfflineCredentials(String email, bool hasCredentials);
  Future<Either<Failure, String?>> getOfflineEmail();
  Future<Either<Failure, bool>> hasOfflineCredentials();
  Future<Either<Failure, Unit>> clearOfflineCredentials();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final UserSessionLocalDataSource _userSessionDataSource;
  final OnboardingStateLocalDataSource _onboardingStateDataSource;
  
  AuthLocalDataSourceImpl(
    this._userSessionDataSource,
    this._onboardingStateDataSource,
  );

  @override
  Future<Either<Failure, Unit>> cacheUserId(String userId) =>
      _userSessionDataSource.cacheUserId(userId);

  @override
  Future<Either<Failure, String?>> getCachedUserId() =>
      _userSessionDataSource.getCachedUserId();

  @override
  Future<Either<Failure, Unit>> setOnboardingCompleted(bool completed) =>
      _onboardingStateDataSource.setOnboardingCompleted(completed);

  @override
  Future<Either<Failure, bool>> isOnboardingCompleted() =>
      _onboardingStateDataSource.isOnboardingCompleted();

  @override
  Future<Either<Failure, Unit>> setWelcomeScreenSeen(bool seen) =>
      _onboardingStateDataSource.setWelcomeScreenSeen(seen);

  @override
  Future<Either<Failure, bool>> isWelcomeScreenSeen() =>
      _onboardingStateDataSource.isWelcomeScreenSeen();

  @override
  Future<Either<Failure, Unit>> setOfflineCredentials(String email, bool hasCredentials) =>
      _userSessionDataSource.setOfflineCredentials(email, hasCredentials);

  @override
  Future<Either<Failure, String?>> getOfflineEmail() =>
      _userSessionDataSource.getOfflineEmail();

  @override
  Future<Either<Failure, bool>> hasOfflineCredentials() =>
      _userSessionDataSource.hasOfflineCredentials();

  @override
  Future<Either<Failure, Unit>> clearOfflineCredentials() =>
      _userSessionDataSource.clearOfflineCredentials();
}
