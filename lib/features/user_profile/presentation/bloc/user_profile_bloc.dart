import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:trackflow/features/user_profile/domain/usecases/create_user_profile_usecase.dart';
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart';
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart';
import 'package:trackflow/core/app_flow/domain/usecases/get_current_user_usecase.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/common/mixins/resetable_bloc_mixin.dart';

@injectable
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState>
    with ResetableBlocMixin<UserProfileEvent, UserProfileState> {
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  final CreateUserProfileUseCase createUserProfileUseCase;
  final WatchUserProfileUseCase watchUserProfileUseCase;
  final CheckProfileCompletenessUseCase checkProfileCompletenessUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  StreamSubscription<Either<Failure, UserProfile?>>? _profileSubscription;

  UserProfileBloc({
    required this.updateUserProfileUseCase,
    required this.createUserProfileUseCase,
    required this.watchUserProfileUseCase,
    required this.checkProfileCompletenessUseCase,
    required this.getCurrentUserUseCase,
  }) : super(UserProfileInitial()) {
    on<WatchUserProfile>(_onWatchUserProfile);
    on<SaveUserProfile>(_onSaveUserProfile);
    on<CreateUserProfile>(_onCreateUserProfile);
    on<ClearUserProfile>(_onClearUserProfile);
    on<CheckProfileCompleteness>(_onCheckProfileCompleteness);
    on<GetProfileCreationData>(_onGetProfileCreationData);

    AppLogger.info(
      'UserProfileBloc: Constructor called, registering for cleanup',
      tag: 'USER_PROFILE_BLOC',
    );

    // Register for automatic state cleanup
    registerForCleanup();

    AppLogger.info(
      'UserProfileBloc: Registration for cleanup completed',
      tag: 'USER_PROFILE_BLOC',
    );
  }

  @override
  UserProfileState get initialState => UserProfileInitial();

  @override
  void reset() {
    AppLogger.info(
      'UserProfileBloc: Starting BLoC reset - canceling ${_profileSubscription != null ? "active" : "no"} subscriptions',
      tag: 'USER_PROFILE_BLOC',
    );

    // Cancel all active subscriptions before resetting state
    if (_profileSubscription != null) {
      AppLogger.info(
        'UserProfileBloc: Canceling active profile subscription',
        tag: 'USER_PROFILE_BLOC',
      );
      _profileSubscription?.cancel();
      _profileSubscription = null;
    } else {
      AppLogger.warning(
        'UserProfileBloc: No active subscription to cancel during reset',
        tag: 'USER_PROFILE_BLOC',
      );
    }

    // Use the parent's reset method which properly emits the initial state
    super.reset();

    AppLogger.info(
      'UserProfileBloc: BLoC reset completed successfully - state is now ${state.runtimeType}',
      tag: 'USER_PROFILE_BLOC',
    );
  }

  Future<void> _onWatchUserProfile(
    WatchUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    AppLogger.info(
      'UserProfileBloc: WatchUserProfile event received - userId: ${event.userId} - current state: ${state.runtimeType}',
      tag: 'USER_PROFILE_BLOC',
    );

    // Debug: Print stack trace to see what's calling this
    AppLogger.info(
      'UserProfileBloc: WatchUserProfile called from: ${StackTrace.current.toString().split('\n').take(5).join('\n')}',
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
                // Keep lightweight loading state while local profile is not yet seeded
                if (state is! UserProfileLoading) {
                  emit(UserProfileLoading());
                }
              }
            },
          );
        },
        onError: (error, stackTrace) {
          AppLogger.error(
            'UserProfileBloc: Error watching profile: $error',
            tag: 'USER_PROFILE_BLOC',
            error: error,
          );
          emit(UserProfileError());
        },
      );
    } catch (e) {
      AppLogger.error(
        'UserProfileBloc: Exception watching profile: $e',
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
    emit(UserProfileSaving());
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
          'UserProfileBloc: Profile saved successfully',
          tag: 'USER_PROFILE_BLOC',
        );
        emit(UserProfileSaved());
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
    emit(UserProfileSaving());
    final result = await createUserProfileUseCase.call(event.profile);
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
          'UserProfileBloc: Profile created successfully',
          tag: 'USER_PROFILE_BLOC',
        );
        emit(UserProfileSaved());
      },
    );
  }

  Future<void> _onClearUserProfile(
    ClearUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    AppLogger.info(
      'UserProfileBloc: Clearing user profile state',
      tag: 'USER_PROFILE_BLOC',
    );

    _profileSubscription?.cancel();
    emit(UserProfileInitial());
  }

  /// Clear all user profile data and state
  void clearAllUserData() {
    AppLogger.info(
      'UserProfileBloc: Clearing all user profile data and canceling streams',
      tag: 'USER_PROFILE_BLOC',
    );

    // Cancelar todas las subscripciones activas
    _profileSubscription?.cancel();
    _profileSubscription = null;

    // Limpiar cualquier estado residual
    add(ClearUserProfile());

    AppLogger.info(
      'UserProfileBloc: All user profile data cleared successfully',
      tag: 'USER_PROFILE_BLOC',
    );
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

  Future<void> _onGetProfileCreationData(
    GetProfileCreationData event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());

    final result = await getCurrentUserUseCase.getProfileCreationData();

    result.fold(
      (failure) {
        emit(UserDataError(failure.message));
      },
      (userData) {
        if (userData.userId != null && userData.email != null) {
          final isGoogleUser =
              userData.displayName != null || userData.photoUrl != null;

          emit(
            ProfileCreationDataLoaded(
              userId: userData.userId!.value,
              email: userData.email!,
              displayName: userData.displayName,
              photoUrl: userData.photoUrl,
              isGoogleUser: isGoogleUser,
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
