import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/features/onboarding/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final SharedPreferences _prefs;

  OnboardingRepositoryImpl(this._prefs);

  @override
  Future<bool> hasCompletedOnboarding() async {
    return _prefs.getBool('hasCompletedOnboarding') ?? false;
  }

  @override
  Future<bool> hasSeenLaunch() async {
    return _prefs.getBool('hasSeenLaunch') ?? false;
  }

  @override
  Future<void> markOnboardingCompleted() async {
    await _prefs.setBool('hasCompletedOnboarding', true);
  }

  @override
  Future<void> markLaunchScreenSeen() async {
    await _prefs.setBool('hasSeenLaunch', true);
  }

  @override
  Future<bool> hasSeenOnboarding() async {
    return _prefs.getBool('hasSeenOnboarding') ?? false;
  }
}
