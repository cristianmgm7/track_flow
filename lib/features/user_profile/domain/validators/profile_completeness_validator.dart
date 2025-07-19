import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class ProfileCompletenessValidator {
  /// Validates if a user profile is complete for onboarding
  /// A profile is considered complete if it has:
  /// - A valid name (not empty and not default)
  /// - A creative role set
  /// - An email address
  static bool isComplete(UserProfile profile) {
    return _hasValidName(profile.name) &&
        _hasCreativeRole(profile.creativeRole) &&
        _hasValidEmail(profile.email);
  }

  /// Gets the reason why a profile is incomplete
  static String getIncompletenessReason(UserProfile profile) {
    if (!_hasValidName(profile.name)) {
      return 'Name is required and must be at least 2 characters';
    }
    if (!_hasCreativeRole(profile.creativeRole)) {
      return 'Creative role must be selected';
    }
    if (!_hasValidEmail(profile.email)) {
      return 'Valid email address is required';
    }
    return 'Profile is complete';
  }

  static bool _hasValidName(String name) {
    return name.isNotEmpty &&
        name.trim().length >= 2 &&
        name != 'No Name' &&
        name != 'Unknown';
  }

  static bool _hasCreativeRole(CreativeRole? creativeRole) {
    return creativeRole != null && creativeRole != CreativeRole.other;
  }

  static bool _hasValidEmail(String email) {
    return email.isNotEmpty && email.contains('@') && email.contains('.');
  }
}
