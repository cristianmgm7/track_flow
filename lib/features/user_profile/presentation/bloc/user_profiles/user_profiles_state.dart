import 'package:equatable/equatable.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/presentation/models/user_profile_ui_model.dart';

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
  final UserProfileUiModel uiModel;

  UserProfileLoaded({required this.uiModel});

  // Access domain entity when needed via composition
  UserProfile get profile => uiModel.profile;

  @override
  List<Object?> get props => [uiModel];
}

/// Multiple profiles loaded (for collaborator lists)
class UserProfilesLoaded extends UserProfilesState {
  final Map<String, UserProfileUiModel> uiModels; // userId -> UI model

  UserProfilesLoaded({required this.uiModels});

  // Access domain entities when needed via composition
  Map<String, UserProfile> get profiles => 
      uiModels.map((key, uiModel) => MapEntry(key, uiModel.profile));

  UserProfilesLoaded copyWith({Map<String, UserProfileUiModel>? uiModels}) {
    return UserProfilesLoaded(uiModels: uiModels ?? this.uiModels);
  }

  @override
  List<Object?> get props => [uiModels];
}

/// Error occurred
class UserProfilesError extends UserProfilesState {
  final String message;

  UserProfilesError(this.message);

  @override
  List<Object?> get props => [message];
}

