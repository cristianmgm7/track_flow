import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/usecases/watch_user_profile.dart';
import 'package:trackflow/features/user_profile/domain/usecases/watch_userprofiles.dart';
import 'package:trackflow/features/user_profile/domain/usecases/sync_collaborator_profile_usecase.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profiles/user_profiles_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profiles/user_profiles_state.dart';
import 'package:trackflow/core/utils/app_logger.dart';

@injectable
class UserProfilesBloc extends Bloc<UserProfilesEvent, UserProfilesState> {
  final WatchUserProfileUseCase _watchUserProfileUseCase;
  final WatchUserProfilesUseCase _watchUserProfilesUseCase;
  final SyncCollaboratorProfileUseCase _syncCollaboratorProfileUseCase;

  StreamSubscription? _profileSubscription;
  bool _hasSyncedProfile = false;

  UserProfilesBloc({
    required WatchUserProfileUseCase watchUserProfileUseCase,
    required WatchUserProfilesUseCase watchUserProfilesUseCase,
    required SyncCollaboratorProfileUseCase syncCollaboratorProfileUseCase,
  })  : _watchUserProfileUseCase = watchUserProfileUseCase,
        _watchUserProfilesUseCase = watchUserProfilesUseCase,
        _syncCollaboratorProfileUseCase = syncCollaboratorProfileUseCase,
        super(UserProfilesInitial()) {
    on<WatchUserProfile>(_onWatchUserProfile);
    on<WatchMultipleUserProfiles>(_onWatchMultipleUserProfiles);
    on<ClearUserProfiles>(_onClearUserProfiles);
  }

  /// Handle watching a single user profile (for collaborator view)
  Future<void> _onWatchUserProfile(
    WatchUserProfile event,
    Emitter<UserProfilesState> emit,
  ) async {
    emit(UserProfilesLoading());
    _hasSyncedProfile = false;

    try {
      AppLogger.info(
        'UserProfilesBloc: Watching profile for userId: ${event.userId}',
        tag: 'USER_PROFILES_BLOC',
      );

      // Use callAny to watch any user's profile without session validation
      final stream = _watchUserProfileUseCase.callAny(event.userId);

      await emit.onEach<Either<Failure, UserProfile?>>(
        stream,
        onData: (eitherProfile) async {
          eitherProfile.fold(
            (failure) {
              AppLogger.error(
                'Failed to watch profile: ${failure.message}',
                tag: 'USER_PROFILES_BLOC',
                error: failure,
              );
              emit(UserProfilesError(failure.message));
            },
            (profile) async {
              if (profile != null) {
                AppLogger.info(
                  'Profile loaded successfully for userId: ${event.userId}',
                  tag: 'USER_PROFILES_BLOC',
                );
                _hasSyncedProfile = true;
                emit(UserProfileLoaded(profile: profile));
              } else if (!_hasSyncedProfile) {
                // Profile not in cache, sync from remote
                AppLogger.info(
                  'Profile not in cache, syncing from remote for userId: ${event.userId}',
                  tag: 'USER_PROFILES_BLOC',
                );
                _hasSyncedProfile = true;
                
                // Trigger sync in background
                final syncResult = await _syncCollaboratorProfileUseCase.call(event.userId);
                syncResult.fold(
                  (failure) {
                    AppLogger.error(
                      'Failed to sync profile from remote: ${failure.message}',
                      tag: 'USER_PROFILES_BLOC',
                      error: failure,
                    );
                    emit(UserProfilesError('Profile not found'));
                  },
                  (syncedProfile) {
                    // Profile synced successfully, watch stream will emit it
                    AppLogger.info(
                      'Profile synced from remote, watch stream will emit it',
                      tag: 'USER_PROFILES_BLOC',
                    );
                  },
                );
              } else {
                // Already tried syncing, profile truly doesn't exist
                AppLogger.warning(
                  'Profile not found even after sync attempt for userId: ${event.userId}',
                  tag: 'USER_PROFILES_BLOC',
                );
                emit(UserProfilesError('Profile not found'));
              }
            },
          );
        },
        onError: (error, stackTrace) {
          AppLogger.error(
            'Error watching profile: $error',
            tag: 'USER_PROFILES_BLOC',
            error: error,
          );
          emit(UserProfilesError('Failed to load profile'));
        },
      );
    } catch (e) {
      AppLogger.error(
        'Exception watching profile: $e',
        tag: 'USER_PROFILES_BLOC',
        error: e,
      );
      emit(UserProfilesError('Failed to load profile'));
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

  

  Future<void> _onClearUserProfiles(
    ClearUserProfiles event,
    Emitter<UserProfilesState> emit,
  ) async {
    _profileSubscription?.cancel();
    _profileSubscription = null;
    _hasSyncedProfile = false;
    emit(UserProfilesInitial());
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}

