import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';

/// Local data source responsible for user session management
/// Follows Single Responsibility Principle - only handles user session state
abstract class UserSessionLocalDataSource {
  Future<Either<Failure, Unit>> cacheUserId(String userId);
  Future<Either<Failure, String?>> getCachedUserId();
  Future<Either<Failure, Unit>> setOfflineCredentials(
    String email,
    bool hasCredentials,
  );
  Future<Either<Failure, String?>> getOfflineEmail();
  Future<Either<Failure, bool>> hasOfflineCredentials();
  Future<Either<Failure, Unit>> clearOfflineCredentials();
}

@LazySingleton(as: UserSessionLocalDataSource)
class UserSessionLocalDataSourceImpl implements UserSessionLocalDataSource {
  final SharedPreferences _prefs;

  UserSessionLocalDataSourceImpl(this._prefs);

  @override
  Future<Either<Failure, Unit>> cacheUserId(String userId) async {
    try {
      await _prefs.setString('userId', userId);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to cache user ID: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getCachedUserId() async {
    try {
      final userId = _prefs.getString('userId');
      return Right(userId);
    } catch (e) {
      return Left(CacheFailure('Failed to get cached user ID: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> setOfflineCredentials(
    String email,
    bool hasCredentials,
  ) async {
    try {
      await _prefs.setBool('has_credentials', hasCredentials);
      await _prefs.setString('offline_email', email);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to set offline credentials: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getOfflineEmail() async {
    try {
      final email = _prefs.getString('offline_email');
      return Right(email);
    } catch (e) {
      return Left(CacheFailure('Failed to get offline email: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasOfflineCredentials() async {
    try {
      final hasCredentials = _prefs.getBool('has_credentials') ?? false;
      return Right(hasCredentials);
    } catch (e) {
      return Left(CacheFailure('Failed to check offline credentials: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearOfflineCredentials() async {
    try {
      await _prefs.setBool('has_credentials', false);
      await _prefs.remove('offline_email');
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to clear offline credentials: $e'));
    }
  }
}
