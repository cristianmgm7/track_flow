import 'package:equatable/equatable.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class UserProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class WatchUserProfile extends UserProfileEvent {
  WatchUserProfile();
}

class SaveUserProfile extends UserProfileEvent {
  final UserProfile profile;
  SaveUserProfile(this.profile);
}

class CreateUserProfile extends UserProfileEvent {
  final UserProfile profile;
  CreateUserProfile(this.profile);
}
