import 'package:equatable/equatable.dart';

abstract class UserProfilesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Watch a specific user's profile (for collaborator view)
class WatchUserProfile extends UserProfilesEvent {
  final String userId;

  WatchUserProfile({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Watch multiple users' profiles (for collaborator lists)
class WatchMultipleUserProfiles extends UserProfilesEvent {
  final List<String> userIds;

  WatchMultipleUserProfiles({required this.userIds});

  @override
  List<Object?> get props => [userIds];
}

/// Load a single profile (one-time fetch, no watch)
class LoadUserProfile extends UserProfilesEvent {
  final String userId;

  LoadUserProfile({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Clear all cached profiles
class ClearUserProfiles extends UserProfilesEvent {}

