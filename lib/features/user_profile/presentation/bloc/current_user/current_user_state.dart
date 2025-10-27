import 'package:equatable/equatable.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/presentation/models/user_profile_ui_model.dart';

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
  final UserProfileUiModel uiModel;

  CurrentUserLoaded({required this.uiModel});

  // Access domain entity when needed via composition
  UserProfile get profile => uiModel.profile;

  CurrentUserLoaded copyWith({UserProfileUiModel? uiModel}) {
    return CurrentUserLoaded(uiModel: uiModel ?? this.uiModel);
  }

  @override
  List<Object?> get props => [uiModel];
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
  final UserProfileUiModel uiModel;

  CurrentUserSaved({required this.uiModel});

  // Access domain entity when needed via composition
  UserProfile get profile => uiModel.profile;

  @override
  List<Object?> get props => [uiModel];
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

