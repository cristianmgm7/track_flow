import 'package:equatable/equatable.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class CurrentUserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Start watching current user's profile
class WatchCurrentUserProfile extends CurrentUserEvent {}

/// Create new profile for current user
class CreateCurrentUserProfile extends CurrentUserEvent {
  final UserProfile profile;

  CreateCurrentUserProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Update current user's profile
class UpdateCurrentUserProfile extends CurrentUserEvent {
  final UserProfile profile;

  UpdateCurrentUserProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Check if current user's profile is complete
class CheckCurrentUserProfileCompleteness extends CurrentUserEvent {
  final String? userId;

  CheckCurrentUserProfileCompleteness({this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Get profile creation data (userId, email from auth)
class GetCurrentUserProfileCreationData extends CurrentUserEvent {}

/// Clear current user profile state
class ClearCurrentUserProfile extends CurrentUserEvent {}

