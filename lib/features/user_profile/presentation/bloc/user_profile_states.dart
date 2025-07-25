import 'package:equatable/equatable.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class UserProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final UserProfile profile;
  final bool isSyncing;
  final double? syncProgress;
  
  UserProfileLoaded({
    required this.profile,
    this.isSyncing = false,
    this.syncProgress,
  });

  UserProfileLoaded copyWith({
    UserProfile? profile,
    bool? isSyncing,
    double? syncProgress,
  }) {
    return UserProfileLoaded(
      profile: profile ?? this.profile,
      isSyncing: isSyncing ?? this.isSyncing,
      syncProgress: syncProgress ?? this.syncProgress,
    );
  }

  @override
  List<Object?> get props => [profile, isSyncing, syncProgress ?? 0.0];
}

class UserProfileSaving extends UserProfileState {}

class UserProfileSaved extends UserProfileState {}

class UserProfileError extends UserProfileState {}

class ProfileComplete extends UserProfileState {
  final UserProfile profile;
  final bool isSyncing;
  final double? syncProgress;
  
  ProfileComplete({
    required this.profile,
    this.isSyncing = false,
    this.syncProgress,
  });

  ProfileComplete copyWith({
    UserProfile? profile,
    bool? isSyncing,
    double? syncProgress,
  }) {
    return ProfileComplete(
      profile: profile ?? this.profile,
      isSyncing: isSyncing ?? this.isSyncing,
      syncProgress: syncProgress ?? this.syncProgress,
    );
  }

  @override
  List<Object?> get props => [profile, isSyncing, syncProgress ?? 0.0];
}

class ProfileIncomplete extends UserProfileState {
  final UserProfile? profile;
  final String reason;
  ProfileIncomplete({this.profile, required this.reason});

  @override
  List<Object?> get props => [profile, reason];
}
