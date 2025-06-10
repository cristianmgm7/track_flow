import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/user_profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';

@injectable
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;

  UserProfileBloc({
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
  }) : super(UserProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<SaveUserProfile>(_onSaveUserProfile);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());
    final result = await getUserProfileUseCase.call();
    result.fold(
      (failure) => emit(UserProfileError()),
      (profile) => emit(UserProfileLoaded(profile)),
    );
  }

  Future<void> _onSaveUserProfile(
    SaveUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileSaving());
    final result = await updateUserProfileUseCase(event.profile);
    result.fold(
      (failure) => emit(UserProfileError()),
      (_) => emit(UserProfileSaved()),
    );
    add(LoadUserProfile());
  }
}
