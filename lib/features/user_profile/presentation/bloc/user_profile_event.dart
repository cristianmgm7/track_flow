import 'package:equatable/equatable.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class UserProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class WatchUserProfile extends UserProfileEvent {
  final String? userId;
  WatchUserProfile({this.userId});
}

class SaveUserProfile extends UserProfileEvent {
  final UserProfile profile;
  SaveUserProfile(this.profile);
}

class CreateUserProfile extends UserProfileEvent {
  final UserProfile profile;
  CreateUserProfile(this.profile);
}

class ClearUserProfile extends UserProfileEvent {}

class CheckProfileCompleteness extends UserProfileEvent {
  final String? userId;
  CheckProfileCompleteness({this.userId});
}

class GetProfileCreationData extends UserProfileEvent {}
