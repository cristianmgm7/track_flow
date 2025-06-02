import 'package:equatable/equatable.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class UserProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserProfileEvent {
  LoadUserProfile();
}

class SaveUserProfile extends UserProfileEvent {
  final UserProfile profile;
  SaveUserProfile(this.profile);
}
