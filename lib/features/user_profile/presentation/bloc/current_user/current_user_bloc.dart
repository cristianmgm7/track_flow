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
import 'package:trackflow/core/app_flow/domain/usecases/get_auth_state_usecase.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/common/mixins/resetable_bloc_mixin.dart';

@injectable
class CurrentUserBloc extends Bloc<CurrentUserEvent, CurrentUserState>
    with ResetableBlocMixin<CurrentUserEvent, CurrentUserState> {
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final CreateUserProfileUseCase _createUserProfileUseCase;
  final WatchUserProfileUseCase _watchUserProfileUseCase;
  final CheckProfileCompletenessUseCase _checkProfileCompletenessUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final GetAuthStateUseCase _getAuthStateUseCase;

  StreamSubscription<Either<Failure, UserProfile?>>? _profileSubscription;
  StreamSubscription? _authSubscription;

  CurrentUserBloc({
    required UpdateUserProfileUseCase updateUserProfileUseCase,
    required CreateUserProfileUseCase createUserProfileUseCase,
    required WatchUserProfileUseCase watchUserProfileUseCase,
    required CheckProfileCompletenessUseCase checkProfileCompletenessUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required GetAuthStateUseCase getAuthStateUseCase,
  })  : _updateUserProfileUseCase = updateUserProfileUseCase,
        _createUserProfileUseCase = createUserProfileUseCase,
        _watchUserProfileUseCase = watchUserProfileUseCase,
        _checkProfileCompletenessUseCase = checkProfileCompletenessUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _getAuthStateUseCase = getAuthStateUseCase,
        super(CurrentUserInitial()) {
    on<WatchCurrentUserProfile>(_onWatchCurrentUserProfile);
    on<CreateCurrentUserProfile>(_onCreateCurrentUserProfile);
    on<UpdateCurrentUserProfile>(_onUpdateCurrentUserProfile);
    on<CheckCurrentUserProfileCompleteness>(_onCheckCurrentUserProfileCompleteness);
    on<GetCurrentUserProfileCreationData>(_onGetCurrentUserProfileCreationData);
    on<ClearCurrentUserProfile>(_onClearCurrentUserProfile);

    // Register for automatic state cleanup on logout
    registerForCleanup();

    // Listen to auth state changes and auto-watch on login
    _authSubscription = _getAuthStateUseCase().listen((user) {
      if (user != null && state is CurrentUserInitial) {
        // User logged in and bloc is in initial state - start watching
        add(WatchCurrentUserProfile());
      }
    });
  }

  @override
  CurrentUserState get initialState => CurrentUserInitial();

  @override
  void reset() {
    // Cancel all active subscriptions before resetting state
    _profileSubscription?.cancel();
    _profileSubscription = null;

    // Reset to initial state
    super.reset();
  }

  Future<void> _onWatchCurrentUserProfile(
    WatchCurrentUserProfile event,
    Emitter<CurrentUserState> emit,
  ) async {
    emit(CurrentUserLoading());

    try {
      // Watch current user's profile (no userId parameter = current user)
      final stream = _watchUserProfileUseCase.call();

      await emit.onEach<Either<Failure, UserProfile?>>(
        stream,
        onData: (eitherProfile) {
          eitherProfile.fold(
            (failure) {
              if (failure.message.contains('No user found') ||
                  failure.message.contains('not authenticated')) {
                emit(CurrentUserError('Not authenticated'));
              } else {
                emit(CurrentUserError(failure.message));
              }
            },
            (profile) {
              if (profile != null) {
                emit(CurrentUserLoaded(profile: profile));
              } else {
                // Keep lightweight loading state while profile is being seeded
                if (state is! CurrentUserLoading) {
                  emit(CurrentUserLoading());
                }
              }
            },
          );
        },
        onError: (error, stackTrace) {
          AppLogger.error(
            'Error watching current user profile: $error',
            tag: 'CURRENT_USER_BLOC',
            error: error,
          );
          emit(CurrentUserError('Failed to watch profile'));
        },
      );
    } catch (e) {
      AppLogger.error(
        'Exception in watch current user profile: $e',
        tag: 'CURRENT_USER_BLOC',
        error: e,
      );
      emit(CurrentUserError('Failed to watch profile'));
    }
  }

  Future<void> _onCreateCurrentUserProfile(
    CreateCurrentUserProfile event,
    Emitter<CurrentUserState> emit,
  ) async {
    emit(CurrentUserUpdating(
      currentProfile: null, // No profile exists yet
    ));

    final result = await _createUserProfileUseCase.call(event.profile);

    result.fold(
      (failure) {
        AppLogger.error(
          'Profile creation failed: ${failure.message}',
          tag: 'CURRENT_USER_BLOC',
          error: failure,
        );
        emit(CurrentUserError(failure.message));
      },
      (profile) {
        // Profile created successfully
        // The watch stream will emit the new profile, so we can just show success briefly
        emit(CurrentUserSaved(profile: event.profile));

        // Auto-transition to watching after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (!isClosed) {
            add(WatchCurrentUserProfile());
          }
        });
      },
    );
  }

  Future<void> _onUpdateCurrentUserProfile(
    UpdateCurrentUserProfile event,
    Emitter<CurrentUserState> emit,
  ) async {
    // Keep current profile data visible during update
    final currentState = state;
    final currentProfile = currentState is CurrentUserLoaded
        ? currentState.profile
        : null;

    emit(CurrentUserUpdating(currentProfile: currentProfile));

    final result = await _updateUserProfileUseCase.call(event.profile);

    await result.fold(
      (failure) async {
        AppLogger.error(
          'Profile update failed: ${failure.message}',
          tag: 'CURRENT_USER_BLOC',
          error: failure,
        );
        emit(CurrentUserError(failure.message));
      },
      (unit) async {
        // Update succeeded - show success briefly then return to loaded
        emit(CurrentUserSaved(profile: event.profile));

        // Auto-transition back to loaded after 2 seconds
        await Future.delayed(const Duration(seconds: 2));
        if (!isClosed && state is CurrentUserSaved) {
          // The watch stream should have emitted the updated profile by now
          // But if not, we'll emit loaded state with the profile we just saved
          emit(CurrentUserLoaded(profile: event.profile));
        }
      },
    );
  }

  Future<void> _onCheckCurrentUserProfileCompleteness(
    CheckCurrentUserProfileCompleteness event,
    Emitter<CurrentUserState> emit,
  ) async {
    if (event.userId == null) {
      emit(CurrentUserProfileIncomplete(
        reason: 'User ID is required',
      ));
      return;
    }

    final isComplete = await _checkProfileCompletenessUseCase.isProfileComplete(
      event.userId!,
    );

    if (isComplete) {
      // Profile is complete - start watching
      add(WatchCurrentUserProfile());
    } else {
      emit(CurrentUserProfileIncomplete(
        reason: 'Profile is not complete',
      ));
    }
  }

  Future<void> _onGetCurrentUserProfileCreationData(
    GetCurrentUserProfileCreationData event,
    Emitter<CurrentUserState> emit,
  ) async {
    emit(CurrentUserLoading());

    final result = await _getCurrentUserUseCase.getProfileCreationData();

    result.fold(
      (failure) {
        emit(CurrentUserError(failure.message));
      },
      (userData) {
        if (userData.userId != null && userData.email != null) {
          final isGoogleUser =
              userData.displayName != null || userData.photoUrl != null;

          emit(CurrentUserCreationDataLoaded(
            userId: userData.userId!.value,
            email: userData.email!,
            displayName: userData.displayName,
            photoUrl: userData.photoUrl,
            isGoogleUser: isGoogleUser,
          ));
        } else {
          emit(CurrentUserError('User data not available'));
        }
      },
    );
  }

  Future<void> _onClearCurrentUserProfile(
    ClearCurrentUserProfile event,
    Emitter<CurrentUserState> emit,
  ) async {
    _profileSubscription?.cancel();
    _profileSubscription = null;
    emit(CurrentUserInitial());
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}

