import 'package:equatable/equatable.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class UserProfilesState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state
class UserProfilesInitial extends UserProfilesState {}

/// Loading profiles
class UserProfilesLoading extends UserProfilesState {}

/// Single profile loaded
class UserProfileLoaded extends UserProfilesState {
  final UserProfile profile;

  UserProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

/// Multiple profiles loaded (for collaborator lists)
class UserProfilesLoaded extends UserProfilesState {
  final Map<String, UserProfile> profiles; // userId -> profile

  UserProfilesLoaded({required this.profiles});

  UserProfilesLoaded copyWith({Map<String, UserProfile>? profiles}) {
    return UserProfilesLoaded(
      profiles: profiles ?? this.profiles,
    );
  }

  @override
  List<Object?> get props => [profiles];
}

/// Error occurred
class UserProfilesError extends UserProfilesState {
  final String message;

  UserProfilesError(this.message);

  @override
  List<Object?> get props => [message];
}

