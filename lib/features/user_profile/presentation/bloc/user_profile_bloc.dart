import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart';
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';

@injectable
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  final WatchUserProfileUseCase watchUserProfileUseCase;
  final CheckProfileCompletenessUseCase checkProfileCompletenessUseCase;

  StreamSubscription<Either<Failure, UserProfile?>>? _profileSubscription;

  UserProfileBloc({
    required this.updateUserProfileUseCase,
    required this.watchUserProfileUseCase,
    required this.checkProfileCompletenessUseCase,
  }) : super(UserProfileInitial()) {
    on<WatchUserProfile>(_onWatchUserProfile);
    on<SaveUserProfile>(_onSaveUserProfile);
    on<CreateUserProfile>(_onCreateUserProfile);
    on<ClearUserProfile>(_onClearUserProfile);
    on<CheckProfileCompleteness>(_onCheckProfileCompleteness);
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
        eitherProfile.fold(
          (failure) {
            emit(UserProfileError());
          },
          (profile) {
            if (profile != null) {
              emit(
                UserProfileLoaded(
                  profile: profile,
                  isSyncing: false,
                  syncProgress: null,
                ),
              );
            } else {
              emit(UserProfileError());
            }
          },
        );
      },
      onError: (error, stackTrace) {
        emit(UserProfileError());
      },
    );
  }

  Future<void> _onSaveUserProfile(
    SaveUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());
    final result = await updateUserProfileUseCase.call(event.profile);
    result.fold((failure) => emit(UserProfileError()), (profile) {
      add(WatchUserProfile());
    });
  }

  Future<void> _onCreateUserProfile(
    CreateUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());
    final result = await updateUserProfileUseCase.call(event.profile);
    result.fold(
      (failure) {
        emit(UserProfileError());
      },
      (profile) {
        add(WatchUserProfile());
      },
    );
  }

  Future<void> _onClearUserProfile(
    ClearUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    _profileSubscription?.cancel();
    emit(UserProfileInitial());
  }

  Future<void> _onCheckProfileCompleteness(
    CheckProfileCompleteness event,
    Emitter<UserProfileState> emit,
  ) async {
    if (event.userId == null) {
      emit(ProfileIncomplete(reason: 'User ID is required'));
      return;
    }

    final isComplete = await checkProfileCompletenessUseCase.isProfileComplete(
      event.userId!,
    );

    if (isComplete) {
      // Need to get the actual profile to pass to ProfileComplete
      // For now, emit a simple success state
      add(WatchUserProfile());
    } else {
      emit(ProfileIncomplete(reason: 'Profile is not complete'));
    }
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}
