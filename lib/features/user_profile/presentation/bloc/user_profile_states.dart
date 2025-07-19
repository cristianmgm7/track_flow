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
  UserProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class UserProfileSaving extends UserProfileState {}

class UserProfileSaved extends UserProfileState {}

class UserProfileError extends UserProfileState {}

class ProfileComplete extends UserProfileState {
  final UserProfile profile;
  ProfileComplete(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileIncomplete extends UserProfileState {
  final UserProfile? profile;
  final String reason;
  ProfileIncomplete({this.profile, required this.reason});

  @override
  List<Object?> get props => [profile, reason];
}
