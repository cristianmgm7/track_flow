import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';

@injectable
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  final WatchUserProfileUseCase watchUserProfileUseCase;

  StreamSubscription<Either<Failure, UserProfile?>>? _profileSubscription;

  UserProfileBloc({
    required this.updateUserProfileUseCase,
    required this.watchUserProfileUseCase,
  }) : super(UserProfileInitial()) {
    on<WatchUserProfile>(_onWatchUserProfile);
    on<SaveUserProfile>(_onSaveUserProfile);
  }

  Future<void> _onWatchUserProfile(
    WatchUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());
    final stream =
        event.userId == null
            ? watchUserProfileUseCase.call()
            : watchUserProfileUseCase.call(event.userId!);
    await emit.onEach<Either<Failure, UserProfile?>>(
      stream,
      onData: (eitherProfile) {
        eitherProfile.fold((failure) => emit(UserProfileError()), (profile) {
          if (profile != null) {
            emit(UserProfileLoaded(profile));
          } else {
            emit(UserProfileError());
          }
        });
      },
      onError: (error, stackTrace) => emit(UserProfileError()),
    );
  }

  Future<void> _onSaveUserProfile(
    SaveUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileSaving());
    final result = await updateUserProfileUseCase.call(event.profile);
    result.fold(
      (failure) => emit(UserProfileError()),
      (_) => emit(UserProfileSaved()),
    );
    add(WatchUserProfile(userId: event.profile.id.value));
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}
