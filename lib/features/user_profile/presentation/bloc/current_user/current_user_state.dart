import 'package:equatable/equatable.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class CurrentUserState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state - no profile loaded yet
class CurrentUserInitial extends CurrentUserState {}

/// Loading profile data
class CurrentUserLoading extends CurrentUserState {}

/// Profile loaded successfully
class CurrentUserLoaded extends CurrentUserState {
  final UserProfile profile;

  CurrentUserLoaded({required this.profile});

  CurrentUserLoaded copyWith({UserProfile? profile}) {
    return CurrentUserLoaded(profile: profile ?? this.profile);
  }

  @override
  List<Object?> get props => [profile];
}

/// Updating profile in progress (shows loading indicator but keeps current data)
class CurrentUserUpdating extends CurrentUserState {
  final UserProfile? currentProfile; // Keep current data visible during update

  CurrentUserUpdating({this.currentProfile});

  @override
  List<Object?> get props => [currentProfile];
}

/// Profile update succeeded (brief success message)
class CurrentUserSaved extends CurrentUserState {
  final UserProfile profile;

  CurrentUserSaved({required this.profile});

  @override
  List<Object?> get props => [profile];
}

/// Error occurred
class CurrentUserError extends CurrentUserState {
  final String message;

  CurrentUserError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Profile is incomplete (for onboarding flow)
class CurrentUserProfileIncomplete extends CurrentUserState {
  final String reason;

  CurrentUserProfileIncomplete({required this.reason});

  @override
  List<Object?> get props => [reason];
}

/// Profile creation data loaded (userId, email from auth)
class CurrentUserCreationDataLoaded extends CurrentUserState {
  final String userId;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isGoogleUser;

  CurrentUserCreationDataLoaded({
    required this.userId,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isGoogleUser = false,
  });

  @override
  List<Object?> get props => [userId, email, displayName, photoUrl, isGoogleUser];
}

