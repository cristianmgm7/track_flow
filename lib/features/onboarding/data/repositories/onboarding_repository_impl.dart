import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/features/onboarding/domain/repositories/onboarding_repository.dart';

@LazySingleton(as: OnboardingRepository)
class OnboardingRepositoryImpl implements OnboardingRepository {
  final SharedPreferences _prefs;

  OnboardingRepositoryImpl({required SharedPreferences prefs}) : _prefs = prefs;

  @override
  Future<bool> onboardingCompleted() async {
    return _prefs.setBool('onboardingCompleted', true);
  }

  @override
  Future<void> welcomeScreenSeenCompleted() async {
    await _prefs.setBool('welcomeScreenSeenCompleted', true);
  }

  @override
  Future<bool> checkWelcomeScreenSeen() async {
    return _prefs.getBool('welcomeScreenSeenCompleted') ?? false;
  }

  @override
  Future<bool> checkOnboardingCompleted() async {
    return _prefs.getBool('onboardingCompleted') ?? false;
  }
}
