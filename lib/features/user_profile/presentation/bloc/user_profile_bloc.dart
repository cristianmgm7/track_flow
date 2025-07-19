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
    print(
      '👤 PROFILE DEBUG: WatchUserProfile started for userId: ${event.userId}',
    );
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
            print('👤 PROFILE DEBUG: Watch failed - ${failure.message}');
            emit(UserProfileError());
          },
          (profile) {
            if (profile != null) {
              print('👤 PROFILE DEBUG: Profile loaded - ${profile.id.value}');
              emit(UserProfileLoaded(profile));
            } else {
              print('👤 PROFILE DEBUG: Profile is null');
              emit(UserProfileError());
            }
          },
        );
      },
      onError: (error, stackTrace) {
        print('👤 PROFILE DEBUG: Watch error - $error');
        emit(UserProfileError());
      },
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

  Future<void> _onCreateUserProfile(
    CreateUserProfile event,
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

  Future<void> _onClearUserProfile(
    ClearUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    // Cancel any existing subscription
    _profileSubscription?.cancel();
    // Reset to initial state
    emit(UserProfileInitial());
  }

  Future<void> _onCheckProfileCompleteness(
    CheckProfileCompleteness event,
    Emitter<UserProfileState> emit,
  ) async {
    print('👤 PROFILE DEBUG: CheckProfileCompleteness started');
    emit(UserProfileLoading());

    try {
      print('👤 PROFILE DEBUG: Calling checkProfileCompletenessUseCase');
      final result =
          await checkProfileCompletenessUseCase.getDetailedCompleteness();

      print('👤 PROFILE DEBUG: Got result from use case');
      result.fold(
        (failure) {
          print(
            '👤 PROFILE DEBUG: Completeness check failed - ${failure.message}',
          );
          emit(UserProfileError());
        },
        (completenessInfo) {
          print(
            '👤 PROFILE DEBUG: Completeness result - isComplete: ${completenessInfo.isComplete}, profile: ${completenessInfo.profile?.id.value}',
          );
          if (completenessInfo.isComplete && completenessInfo.profile != null) {
            print('👤 PROFILE DEBUG: Emitting ProfileComplete');
            emit(ProfileComplete(completenessInfo.profile!));
          } else {
            print(
              '👤 PROFILE DEBUG: Emitting ProfileIncomplete - reason: ${completenessInfo.reason}',
            );
            emit(
              ProfileIncomplete(
                profile: completenessInfo.profile,
                reason: completenessInfo.reason,
              ),
            );
          }
        },
      );
    } catch (e) {
      print('👤 PROFILE DEBUG: Exception in CheckProfileCompleteness - $e');
      emit(UserProfileError());
    }
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}
