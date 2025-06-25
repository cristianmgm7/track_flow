import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUserId(String userId);
  Future<String?> getCachedUserId();
  Future<void> setOnboardingCompleted(bool completed);
  Future<bool> isOnboardingCompleted();
  Future<void> setWelcomeScreenSeen(bool seen);
  Future<bool> isWelcomeScreenSeen();
  Future<void> setOfflineCredentials(String email, bool hasCredentials);
  Future<String?> getOfflineEmail();
  Future<bool> hasOfflineCredentials();
  Future<void> clearOfflineCredentials();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _prefs;
  AuthLocalDataSourceImpl(this._prefs);

  @override
  Future<void> cacheUserId(String userId) async {
    await _prefs.setString('userId', userId);
  }

  @override
  Future<String?> getCachedUserId() async {
    return _prefs.getString('userId');
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool('onboardingCompleted', completed);
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    return _prefs.getBool('onboardingCompleted') ?? false;
  }

  @override
  Future<void> setWelcomeScreenSeen(bool seen) async {
    await _prefs.setBool('welcomeScreenSeenCompleted', seen);
  }

  @override
  Future<bool> isWelcomeScreenSeen() async {
    return _prefs.getBool('welcomeScreenSeenCompleted') ?? false;
  }

  @override
  Future<void> setOfflineCredentials(String email, bool hasCredentials) async {
    await _prefs.setBool('has_credentials', hasCredentials);
    await _prefs.setString('offline_email', email);
  }

  @override
  Future<String?> getOfflineEmail() async {
    return _prefs.getString('offline_email');
  }

  @override
  Future<bool> hasOfflineCredentials() async {
    return _prefs.getBool('has_credentials') ?? false;
  }

  @override
  Future<void> clearOfflineCredentials() async {
    await _prefs.setBool('has_credentials', false);
    await _prefs.remove('offline_email');
  }
}
