import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart';
import 'package:trackflow/features/user_profile/domain/usecases/watch_userprofiles.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profiles/user_profiles_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profiles/user_profiles_state.dart';
import 'package:trackflow/core/utils/app_logger.dart';

@injectable
class UserProfilesBloc extends Bloc<UserProfilesEvent, UserProfilesState> {
  final WatchUserProfileUseCase _watchUserProfileUseCase;
  final WatchUserProfilesUseCase _watchUserProfilesUseCase;

  StreamSubscription? _profileSubscription;

  UserProfilesBloc({
    required WatchUserProfileUseCase watchUserProfileUseCase,
    required WatchUserProfilesUseCase watchUserProfilesUseCase,
  })  : _watchUserProfileUseCase = watchUserProfileUseCase,
        _watchUserProfilesUseCase = watchUserProfilesUseCase,
        super(UserProfilesInitial()) {
    on<WatchUserProfile>(_onWatchUserProfile);
    on<WatchMultipleUserProfiles>(_onWatchMultipleUserProfiles);
    on<LoadUserProfile>(_onLoadUserProfile);
    on<ClearUserProfiles>(_onClearUserProfiles);
  }

  Future<void> _onWatchUserProfile(
    WatchUserProfile event,
    Emitter<UserProfilesState> emit,
  ) async {
    emit(UserProfilesLoading());

    try {
      // Use callAny() - no session validation, for viewing collaborators
      final stream = _watchUserProfileUseCase.callAny(event.userId);

      await emit.onEach<Either<Failure, UserProfile?>>(
        stream,
        onData: (eitherProfile) {
          eitherProfile.fold(
            (failure) {
              AppLogger.error(
                'Failed to watch user profile ${event.userId}: ${failure.message}',
                tag: 'USER_PROFILES_BLOC',
                error: failure,
              );
              emit(UserProfilesError(failure.message));
            },
            (profile) {
              if (profile != null) {
                emit(UserProfileLoaded(profile: profile));
              } else {
                emit(UserProfilesError('Profile not found'));
              }
            },
          );
        },
        onError: (error, stackTrace) {
          AppLogger.error(
            'Error watching user profile: $error',
            tag: 'USER_PROFILES_BLOC',
            error: error,
          );
          emit(UserProfilesError('Failed to watch profile'));
        },
      );
    } catch (e) {
      AppLogger.error(
        'Exception watching user profile: $e',
        tag: 'USER_PROFILES_BLOC',
        error: e,
      );
      emit(UserProfilesError('Failed to watch profile'));
    }
  }

  Future<void> _onWatchMultipleUserProfiles(
    WatchMultipleUserProfiles event,
    Emitter<UserProfilesState> emit,
  ) async {
    if (event.userIds.isEmpty) {
      emit(UserProfilesLoaded(profiles: {}));
      return;
    }

    emit(UserProfilesLoading());

    try {
      final stream = _watchUserProfilesUseCase.call(event.userIds);

      await emit.onEach<Either<Failure, List<UserProfile>>>(
        stream,
        onData: (eitherProfiles) {
          eitherProfiles.fold(
            (failure) {
              AppLogger.error(
                'Failed to watch multiple profiles: ${failure.message}',
                tag: 'USER_PROFILES_BLOC',
                error: failure,
              );
              emit(UserProfilesError(failure.message));
            },
            (profiles) {
              // Convert list to map for easy lookup
              final profileMap = <String, UserProfile>{};
              for (final profile in profiles) {
                profileMap[profile.id.value] = profile;
              }
              emit(UserProfilesLoaded(profiles: profileMap));
            },
          );
        },
        onError: (error, stackTrace) {
          AppLogger.error(
            'Error watching multiple profiles: $error',
            tag: 'USER_PROFILES_BLOC',
            error: error,
          );
          emit(UserProfilesError('Failed to watch profiles'));
        },
      );
    } catch (e) {
      AppLogger.error(
        'Exception watching multiple profiles: $e',
        tag: 'USER_PROFILES_BLOC',
        error: e,
      );
      emit(UserProfilesError('Failed to watch profiles'));
    }
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserProfilesState> emit,
  ) async {
    emit(UserProfilesLoading());

    try {
      // One-time fetch - take first emission and cancel
      final stream = _watchUserProfileUseCase.callAny(event.userId);

      await for (final eitherProfile in stream) {
        eitherProfile.fold(
          (failure) {
            emit(UserProfilesError(failure.message));
          },
          (profile) {
            if (profile != null) {
              emit(UserProfileLoaded(profile: profile));
            } else {
              emit(UserProfilesError('Profile not found'));
            }
          },
        );
        break; // Only take first emission
      }
    } catch (e) {
      AppLogger.error(
        'Exception loading user profile: $e',
        tag: 'USER_PROFILES_BLOC',
        error: e,
      );
      emit(UserProfilesError('Failed to load profile'));
    }
  }

  Future<void> _onClearUserProfiles(
    ClearUserProfiles event,
    Emitter<UserProfilesState> emit,
  ) async {
    _profileSubscription?.cancel();
    _profileSubscription = null;
    emit(UserProfilesInitial());
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}

