import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart';
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart';
import 'package:trackflow/features/user_profile/domain/usecases/get_current_user_data_usecase.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';
import 'package:trackflow/core/utils/app_logger.dart';

@injectable
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  final WatchUserProfileUseCase watchUserProfileUseCase;
  final CheckProfileCompletenessUseCase checkProfileCompletenessUseCase;
  final GetCurrentUserDataUseCase getCurrentUserDataUseCase;

  StreamSubscription<Either<Failure, UserProfile?>>? _profileSubscription;

  UserProfileBloc({
    required this.updateUserProfileUseCase,
    required this.watchUserProfileUseCase,
    required this.checkProfileCompletenessUseCase,
    required this.getCurrentUserDataUseCase,
  }) : super(UserProfileInitial()) {
    on<WatchUserProfile>(_onWatchUserProfile);
    on<SaveUserProfile>(_onSaveUserProfile);
    on<CreateUserProfile>(_onCreateUserProfile);
    on<ClearUserProfile>(_onClearUserProfile);
    on<CheckProfileCompleteness>(_onCheckProfileCompleteness);
    on<GetCurrentUserData>(_onGetCurrentUserData);
  }

  Future<void> _onWatchUserProfile(
    WatchUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    AppLogger.info(
      'UserProfileBloc: Starting to watch user profile - userId: ${event.userId}',
      tag: 'USER_PROFILE_BLOC',
    );

    emit(UserProfileLoading());

    try {
      final stream =
          event.userId == null
              ? watchUserProfileUseCase.call()
              : watchUserProfileUseCase.call(event.userId!);

      await emit.onEach<Either<Failure, UserProfile?>>(
        stream,
        onData: (eitherProfile) {
          eitherProfile.fold(
            (failure) {
              AppLogger.error(
                'UserProfileBloc: Profile watch failed: ${failure.message}',
                tag: 'USER_PROFILE_BLOC',
                error: failure,
              );

              // Check if it's an authentication error
              if (failure.message.contains('No user found') ||
                  failure.message.contains('not authenticated')) {
                AppLogger.warning(
                  'UserProfileBloc: Authentication error detected - user not authenticated',
                  tag: 'USER_PROFILE_BLOC',
                );
                emit(UserProfileError());
              } else {
                emit(UserProfileError());
              }
            },
            (profile) {
              if (profile != null) {
                AppLogger.info(
                  'UserProfileBloc: Profile loaded successfully for user: ${profile.email}',
                  tag: 'USER_PROFILE_BLOC',
                );
                emit(
                  UserProfileLoaded(
                    profile: profile,
                    isSyncing: false,
                    syncProgress: null,
                  ),
                );
              } else {
                AppLogger.warning(
                  'UserProfileBloc: No profile found for user',
                  tag: 'USER_PROFILE_BLOC',
                );
                emit(UserProfileError());
              }
            },
          );
        },
        onError: (error, stackTrace) {
          AppLogger.error(
            'UserProfileBloc: Exception watching profile: $error',
            tag: 'USER_PROFILE_BLOC',
            error: error,
          );
          emit(UserProfileError());
        },
      );
    } catch (e) {
      AppLogger.error(
        'UserProfileBloc: Exception in _onWatchUserProfile: $e',
        tag: 'USER_PROFILE_BLOC',
        error: e,
      );
      emit(UserProfileError());
    }
  }

  Future<void> _onSaveUserProfile(
    SaveUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    AppLogger.info(
      'UserProfileBloc: Saving user profile for user: ${event.profile.email}',
      tag: 'USER_PROFILE_BLOC',
    );

    emit(UserProfileLoading());
    final result = await updateUserProfileUseCase.call(event.profile);
    result.fold(
      (failure) {
        AppLogger.error(
          'UserProfileBloc: Profile save failed: ${failure.message}',
          tag: 'USER_PROFILE_BLOC',
          error: failure,
        );
        emit(UserProfileError());
      },
      (profile) {
        AppLogger.info(
          'UserProfileBloc: Profile saved successfully, triggering profile reload',
          tag: 'USER_PROFILE_BLOC',
        );
        // FIXED: Emit UserProfileSaved and then trigger a profile reload
        emit(UserProfileSaved());
        // Trigger profile reload to get the updated profile data
        add(WatchUserProfile());
      },
    );
  }

  Future<void> _onCreateUserProfile(
    CreateUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    AppLogger.info(
      'UserProfileBloc: Creating user profile for user: ${event.profile.email}',
      tag: 'USER_PROFILE_BLOC',
    );

    emit(UserProfileLoading());
    final result = await updateUserProfileUseCase.call(event.profile);
    result.fold(
      (failure) {
        AppLogger.error(
          'UserProfileBloc: Profile creation failed: ${failure.message}',
          tag: 'USER_PROFILE_BLOC',
          error: failure,
        );
        emit(UserProfileError());
      },
      (profile) {
        AppLogger.info(
          'UserProfileBloc: Profile created successfully, triggering profile reload',
          tag: 'USER_PROFILE_BLOC',
        );
        // FIXED: Emit UserProfileSaved and then trigger a profile reload
        emit(UserProfileSaved());
        // Trigger profile reload to get the updated profile data
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

  Future<void> _onGetCurrentUserData(
    GetCurrentUserData event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());

    final result = await getCurrentUserDataUseCase.call();

    result.fold(
      (failure) {
        emit(UserDataError(failure.message));
      },
      (userData) {
        if (userData.userId != null && userData.email != null) {
          emit(
            UserDataLoaded(
              userId: userData.userId!.value,
              email: userData.email!,
            ),
          );
        } else {
          emit(UserDataError('User data not available'));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}
