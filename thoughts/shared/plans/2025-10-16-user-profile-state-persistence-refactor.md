# User Profile State Persistence Bug Fix & Architecture Refactor

## Overview

This plan addresses a critical bug where the "user updated..." message persists incorrectly after navigation, along with several architectural improvements to the user profile management system. The refactor splits UserProfileBloc into two specialized BLoCs following Single Responsibility Principle, fixes state transitions, simplifies over-engineered startup logic, and reduces excessive logging.

## Current State Analysis

### The Bug

**Location**: [user_profile_bloc.dart:265](lib/features/user_profile/presentation/bloc/user_profile_bloc.dart#L265)

The `UserProfileSaved` state persists indefinitely after profile save because:
1. UserProfileBloc is a singleton created at app startup
2. After emitting `UserProfileSaved`, there's no automatic transition back to `UserProfileLoaded`
3. The BLoC instance persists in memory across navigation
4. UI displays stale state when returning to settings/profile screens

**Displayed at**:
- [user_profile_section.dart:131-134](lib/features/settings/presentation/widgets/user_profile_section.dart#L131-L134) - Settings screen
- [profile_creation_screen.dart:172-175](lib/features/user_profile/presentation/screens/profile_creation_screen.dart#L172-L175) - Profile creation

### Architectural Issues

1. **UserProfileBloc Violates Single Responsibility Principle**
   - Handles BOTH current user profile AND other users' profiles
   - Uses `WatchUserProfile()` for current user
   - Uses `WatchAnyUserProfile(userId)` for collaborators
   - Singleton at app level causes state conflicts

2. **Missing State Transition Logic**
   - Current flow: `UserProfileLoaded → Saving → Saved → [STUCK]`
   - Expected flow: `UserProfileLoaded → Saving → Saved → [Auto-transition to Loaded]`

3. **No BLoC Re-initialization After Reset**
   - Cleanup on logout works correctly via `ResetableBlocMixin`
   - BLoC resets to `UserProfileInitial` state
   - But nothing triggers `WatchUserProfile()` again on next login
   - BLoC sits idle in Initial state

4. **Over-Engineered Startup Logic**
   - [session_service.dart:35-182](lib/core/app_flow/domain/services/session_service.dart#L35-L182) has complex 4-step validation
   - Unnecessary 500ms cleanup delay ([app_flow_bloc.dart:130](lib/core/app_flow/presentation/bloc/app_flow_bloc.dart#L130))
   - Multiple nested await points create race conditions

5. **Excessive Logging**
   - 100+ log statements across 4 core files
   - INFO logs clutter normal operation flow
   - Hard to read code with 30+ logs per file

### Key Discoveries

- **Total files using UserProfileBloc**: 22 implementation files
- **Global provider location**: [app_bloc_providers.dart:60-62](lib/core/app/providers/app_bloc_providers.dart#L60-L62)
- **Auto-registered**: Via `@injectable` annotation with get_it
- **Use cases split naturally**:
  - Current user: Create, Update, Watch (with session), CheckCompleteness
  - Other users: Watch (without session), WatchMultiple (batch)
- **Two repositories exist**:
  - `UserProfileRepository` - Single profile operations
  - `UserProfileCacheRepository` - Bulk operations for collaborators

## Desired End State

After this refactor:

1. **CurrentUserBloc** manages authenticated user's profile
   - Singleton at app level
   - Automatically watches profile on login
   - Transitions properly: `Loaded → Updating → Loaded` (with brief success state)
   - Cleans up on logout and re-initializes on next login

2. **UserProfilesBloc** manages viewing other users
   - Scoped to screens that show collaborators
   - Can watch multiple profiles simultaneously
   - No session validation (public data)

3. **State never persists incorrectly**
   - Profile save shows success briefly (2 seconds) then returns to loaded
   - Or immediately returns to loaded with updated profile
   - No stale "Profile updated" messages

4. **Simplified startup logic**
   - Session service focuses only on session validation
   - No unnecessary delays
   - Cleaner code flow

5. **Reduced logging noise**
   - Keep ERROR and WARNING logs
   - Remove most INFO logs from normal flow
   - Use conditional DEBUG logs for troubleshooting

### Verification

**Automated**:
- [ ] All existing tests pass: `flutter test`
- [ ] Code generation succeeds: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- [ ] No analyzer errors: `flutter analyze`

**Manual**:
- [ ] Edit profile → Save → See brief success message → Message disappears → Shows loaded profile
- [ ] Navigate away from settings → Return → Shows loaded profile (not "updated")
- [ ] Logout → Login → Profile loads automatically
- [ ] View collaborator profile → Shows correct collaborator data
- [ ] No console spam during normal operations

## What We're NOT Doing

- NOT migrating existing user data (structure unchanged)
- NOT changing repository implementations
- NOT modifying use case logic
- NOT affecting other features' BLoCs
- NOT changing test infrastructure
- NOT modifying Firebase schema
- NOT changing Isar schema
- NOT adding new features to profile management

## Implementation Approach

This refactor will be implemented in 5 phases:

1. **Create CurrentUserBloc** - New BLoC for authenticated user
2. **Create UserProfilesBloc** - Refactor existing BLoC for collaborators
3. **Update All Usages** - Migrate 22 files to use correct BLoC
4. **Fix State Transitions** - Implement auto-transition after save
5. **Cleanup & Optimization** - Simplify startup logic and reduce logging

Each phase is independently testable and can be verified before proceeding.

---

## Phase 1: Create CurrentUserBloc

### Overview

Create a new BLoC specifically for managing the currently authenticated user's profile. This BLoC will be a singleton at app level and handle create, update, watch, and completeness check operations.

### Changes Required

#### 1. Create CurrentUserBloc Directory Structure

**New Directory**: `lib/features/user_profile/presentation/bloc/current_user/`

Create the following files:
- `current_user_bloc.dart`
- `current_user_event.dart`
- `current_user_state.dart`

#### 2. Define CurrentUserState

**File**: `lib/features/user_profile/presentation/bloc/current_user/current_user_state.dart`

```dart
import 'package:equatable/equatable.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class CurrentUserState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state - no profile loaded yet
class CurrentUserInitial extends CurrentUserState {}

/// Loading profile data
class CurrentUserLoading extends CurrentUserState {}

/// Profile loaded successfully
class CurrentUserLoaded extends CurrentUserState {
  final UserProfile profile;

  CurrentUserLoaded({required this.profile});

  CurrentUserLoaded copyWith({UserProfile? profile}) {
    return CurrentUserLoaded(profile: profile ?? this.profile);
  }

  @override
  List<Object?> get props => [profile];
}

/// Updating profile in progress (shows loading indicator but keeps current data)
class CurrentUserUpdating extends CurrentUserState {
  final UserProfile? currentProfile; // Keep current data visible during update

  CurrentUserUpdating({this.currentProfile});

  @override
  List<Object?> get props => [currentProfile];
}

/// Profile update succeeded (brief success message)
class CurrentUserSaved extends CurrentUserState {
  final UserProfile profile;

  CurrentUserSaved({required this.profile});

  @override
  List<Object?> get props => [profile];
}

/// Error occurred
class CurrentUserError extends CurrentUserState {
  final String message;

  CurrentUserError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Profile is incomplete (for onboarding flow)
class CurrentUserProfileIncomplete extends CurrentUserState {
  final String reason;

  CurrentUserProfileIncomplete({required this.reason});

  @override
  List<Object?> get props => [reason];
}

/// Profile creation data loaded (userId, email from auth)
class CurrentUserCreationDataLoaded extends CurrentUserState {
  final String userId;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isGoogleUser;

  CurrentUserCreationDataLoaded({
    required this.userId,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isGoogleUser = false,
  });

  @override
  List<Object?> get props => [userId, email, displayName, photoUrl, isGoogleUser];
}
```

#### 3. Define CurrentUserEvent

**File**: `lib/features/user_profile/presentation/bloc/current_user/current_user_event.dart`

```dart
import 'package:equatable/equatable.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class CurrentUserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Start watching current user's profile
class WatchCurrentUserProfile extends CurrentUserEvent {}

/// Create new profile for current user
class CreateCurrentUserProfile extends CurrentUserEvent {
  final UserProfile profile;

  CreateCurrentUserProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Update current user's profile
class UpdateCurrentUserProfile extends CurrentUserEvent {
  final UserProfile profile;

  UpdateCurrentUserProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Check if current user's profile is complete
class CheckCurrentUserProfileCompleteness extends CurrentUserEvent {
  final String? userId;

  CheckCurrentUserProfileCompleteness({this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Get profile creation data (userId, email from auth)
class GetCurrentUserProfileCreationData extends CurrentUserEvent {}

/// Clear current user profile state
class ClearCurrentUserProfile extends CurrentUserEvent {}
```

#### 4. Implement CurrentUserBloc

**File**: `lib/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart`

```dart
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
    // Keep current state data if available
    final currentState = state;
    final currentData = currentState is CurrentUserCreationDataLoaded
        ? currentState
        : null;

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
```

#### 5. Register CurrentUserBloc in Dependency Injection

**File**: `lib/core/di/injection.dart`

No changes needed - `@injectable` annotation handles registration automatically.

Run code generation:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### 6. Update App Providers

**File**: `lib/core/app/providers/app_bloc_providers.dart`

**Changes**:

```dart
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_event.dart';

static List<BlocProvider> getMainAppProviders() {
  return [
    // Core infrastructure
    BlocProvider<AppFlowBloc>(create: (_) => sl<AppFlowBloc>()),
    BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
    BlocProvider<NavigationCubit>(create: (_) => sl<NavigationCubit>()),
    BlocProvider<SyncBloc>(create: (_) => sl<SyncBloc>()),

    // Auth flow
    BlocProvider<OnboardingBloc>(create: (_) => sl<OnboardingBloc>()),

    // ✅ NEW: Current user profile management
    BlocProvider<CurrentUserBloc>(
      create: (_) => sl<CurrentUserBloc>()..add(WatchCurrentUserProfile()),
    ),

    // Remove old UserProfileBloc from here (will be scoped instead)

    BlocProvider<MagicLinkBloc>(create: (_) => sl<MagicLinkBloc>()),

    // ... rest of providers
  ];
}
```

### Success Criteria

#### Automated Verification:
- [x] Code generation succeeds: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- [x] No analyzer errors: `flutter analyze`
- [x] CurrentUserBloc registered in DI: Check `lib/core/di/injection.config.dart` contains `CurrentUserBloc` factory

#### Manual Verification:
- [x] App compiles successfully
- [ ] No runtime errors on app startup
- [ ] CurrentUserBloc created at app level (visible in Flutter DevTools)
- [ ] Auth listener automatically triggers `WatchCurrentUserProfile()` on login

---

## Phase 2: Create UserProfilesBloc (Refactor for Collaborators)

### Overview

Refactor the existing UserProfileBloc into UserProfilesBloc, focused solely on viewing other users' profiles for collaboration features. This BLoC will be scoped to specific screens and handle batch profile watching.

### Changes Required

#### 1. Rename and Restructure UserProfileBloc

**Current location**: `lib/features/user_profile/presentation/bloc/`

**Actions**:
- Rename directory to `user_profiles/`
- Rename files:
  - `user_profile_bloc.dart` → `user_profiles_bloc.dart`
  - `user_profile_event.dart` → `user_profiles_event.dart`
  - `user_profile_states.dart` → `user_profiles_state.dart`

#### 2. Define UserProfilesState

**File**: `lib/features/user_profile/presentation/bloc/user_profiles/user_profiles_state.dart`

```dart
import 'package:equatable/equatable.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

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
  final UserProfile profile;

  UserProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

/// Multiple profiles loaded (for collaborator lists)
class UserProfilesLoaded extends UserProfilesState {
  final Map<String, UserProfile> profiles; // userId -> profile

  UserProfilesLoaded({required this.profiles});

  UserProfilesLoaded copyWith({Map<String, UserProfile>? profiles}) {
    return UserProfilesLoaded(
      profiles: profiles ?? this.profiles,
    );
  }

  @override
  List<Object?> get props => [profiles];
}

/// Error occurred
class UserProfilesError extends UserProfilesState {
  final String message;

  UserProfilesError(this.message);

  @override
  List<Object?> get props => [message];
}
```

#### 3. Define UserProfilesEvent

**File**: `lib/features/user_profile/presentation/bloc/user_profiles/user_profiles_event.dart`

```dart
import 'package:equatable/equatable.dart';

abstract class UserProfilesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Watch a specific user's profile (for collaborator view)
class WatchUserProfile extends UserProfilesEvent {
  final String userId;

  WatchUserProfile({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Watch multiple users' profiles (for collaborator lists)
class WatchMultipleUserProfiles extends UserProfilesEvent {
  final List<String> userIds;

  WatchMultipleUserProfiles({required this.userIds});

  @override
  List<Object?> get props => [userIds];
}

/// Load a single profile (one-time fetch, no watch)
class LoadUserProfile extends UserProfilesEvent {
  final String userId;

  LoadUserProfile({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Clear all cached profiles
class ClearUserProfiles extends UserProfilesEvent {}
```

#### 4. Implement UserProfilesBloc

**File**: `lib/features/user_profile/presentation/bloc/user_profiles/user_profiles_bloc.dart`

```dart
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
```

#### 5. Update App Providers (Scoped)

**File**: `lib/core/app/providers/app_bloc_providers.dart`

**Add new scoped provider method**:

```dart
/// Providers for viewing other users (collaborator profiles, artist profiles)
static List<BlocProvider> getUserProfilesProviders() {
  return [
    BlocProvider<UserProfilesBloc>(create: (_) => sl<UserProfilesBloc>()),
  ];
}
```

### Success Criteria

#### Automated Verification:
- [x] Code generation succeeds: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- [x] No analyzer errors: `flutter analyze`
- [x] UserProfilesBloc registered in DI: Check `lib/core/di/injection.config.dart`

#### Manual Verification:
- [x] App compiles successfully
- [ ] Old UserProfileBloc references show errors (expected - will fix in Phase 3)

---

## Phase 3: Update All Usages (22 Files)

### Overview

Migrate all 22 files that currently use UserProfileBloc to use the appropriate new BLoC:
- CurrentUserBloc for current user operations
- UserProfilesBloc for viewing collaborators

This is the most extensive phase with changes across multiple features.

### Changes Required

#### 1. Settings Feature (Current User)

##### File: `lib/features/settings/presentation/screens/settings_screen.dart`

**Changes**:

```dart
// OLD IMPORT
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';

// NEW IMPORT
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_event.dart';

// Line 33: Update BLoC reference
- final userProfileBloc = context.read<UserProfileBloc>();
+ final currentUserBloc = context.read<CurrentUserBloc>();

// Line 34: Update state reference
- final currentState = userProfileBloc.state;
+ final currentState = currentUserBloc.state;

// Line 43: Update event
- userProfileBloc.add(WatchUserProfile());
+ currentUserBloc.add(WatchCurrentUserProfile());
```

##### File: `lib/features/settings/presentation/widgets/user_profile_section.dart`

**Changes**:

```dart
// OLD IMPORT
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';

// NEW IMPORT
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_event.dart';

// Line 20: Update BlocBuilder
- return BlocBuilder<UserProfileBloc, UserProfileState>(
+ return BlocBuilder<CurrentUserBloc, CurrentUserState>(

// Line 50: Update state check
- if (state is UserProfileLoaded) {
+ if (state is CurrentUserLoaded) {

// Line 114: Update state checks
- } else if (state is UserProfileLoading) {
+ } else if (state is CurrentUserLoading) {

// Line 118: Update state check
- } else if (state is UserProfileError) {
+ } else if (state is CurrentUserError) {

// Line 125: Update event
- context.read<UserProfileBloc>().add(WatchUserProfile());
+ context.read<CurrentUserBloc>().add(WatchCurrentUserProfile());

// Line 127: Update state check
- } else if (state is UserProfileInitial) {
+ } else if (state is CurrentUserInitial) {

// Line 131: Update state check (THE BUG FIX!)
- } else if (state is UserProfileSaved) {
+ } else if (state is CurrentUserSaved) {
```

#### 2. User Profile Feature (Current User Screens)

##### File: `lib/features/user_profile/presentation/screens/profile_creation_screen.dart`

**Changes**:

```dart
// OLD IMPORT
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';

// NEW IMPORT
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_event.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';

// Line 48: Update event
- context.read<UserProfileBloc>().add(GetProfileCreationData());
+ context.read<CurrentUserBloc>().add(GetCurrentUserProfileCreationData());

// Line 70: Update event
- context.read<UserProfileBloc>().add(CreateUserProfile(completeProfile));
+ context.read<CurrentUserBloc>().add(CreateCurrentUserProfile(completeProfile));

// Line 95: Update BlocListener
- return BlocListener<UserProfileBloc, UserProfileState>(
+ return BlocListener<CurrentUserBloc, CurrentUserState>(

// Line 145: Update state check
- if (state is ProfileCreationDataLoaded) {
+ if (state is CurrentUserCreationDataLoaded) {

// Line 157: Update state check
- } else if (state is UserDataLoaded) {
+ // Remove this - CurrentUserCreationDataLoaded handles it

// Line 166: Update state check
- } else if (state is UserDataError) {
+ // Handle in CurrentUserError

// Line 172: Update state check
- } else if (state is UserProfileSaved) {
+ } else if (state is CurrentUserSaved) {

// Line 176: Update state check
- } else if (state is UserProfileError) {
+ } else if (state is CurrentUserError) {

// Line 180: Update state check
- } else if (state is UserProfileLoading) {
+ } else if (state is CurrentUserLoading) {

// Line 185: Update state check
- } else if (state is UserProfileLoaded) {
+ } else if (state is CurrentUserLoaded) {
```

##### File: `lib/features/user_profile/presentation/screens/current_user_profile_screen.dart`

**Changes**:

```dart
// OLD IMPORT
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';

// NEW IMPORT
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_event.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';

// Line 36: Update event
- context.read<UserProfileBloc>().add(WatchUserProfile());
+ context.read<CurrentUserBloc>().add(WatchCurrentUserProfile());

// Line 41: Update BlocBuilder
- return BlocBuilder<UserProfileBloc, UserProfileState>(
+ return BlocBuilder<CurrentUserBloc, CurrentUserState>(

// Update all state checks
- UserProfileLoaded → CurrentUserLoaded
- UserProfileLoading → CurrentUserLoading
- UserProfileError → CurrentUserError
```

##### File: `lib/features/user_profile/presentation/edit_profile_dialog.dart`

**Changes**:

```dart
// OLD IMPORT
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';

// NEW IMPORT
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_event.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';

// Line 128: Update event
- context.read<UserProfileBloc>().add(SaveUserProfile(updatedProfile));
+ context.read<CurrentUserBloc>().add(UpdateCurrentUserProfile(updatedProfile));

// Line 145: Update BlocBuilder
- return BlocBuilder<UserProfileBloc, UserProfileState>(
+ return BlocBuilder<CurrentUserBloc, CurrentUserState>(

// Update state checks
- UserProfileSaving → CurrentUserUpdating
```

##### File: `lib/features/user_profile/presentation/components/user_profile_information_component.dart`

**Changes**:

```dart
// This component is used for CURRENT user
// OLD IMPORT
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';

// NEW IMPORT
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_event.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';

// Line 24: Update event
- context.read<UserProfileBloc>().add(WatchUserProfile(userId: null));
+ context.read<CurrentUserBloc>().add(WatchCurrentUserProfile());

// Line 56: Update BlocBuilder
- return BlocBuilder<UserProfileBloc, UserProfileState>(
+ return BlocBuilder<CurrentUserBloc, CurrentUserState>(

// Update state checks
- UserProfileLoaded → CurrentUserLoaded
```

#### 3. User Profile Feature (Collaborator Screens)

##### File: `lib/features/user_profile/presentation/screens/collaborator_profile_screen.dart`

**Changes**:

```dart
// This screen views OTHER users (collaborators)
// OLD IMPORT
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';

// NEW IMPORT
+ import 'package:trackflow/features/user_profile/presentation/bloc/user_profiles/user_profiles_bloc.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/user_profiles/user_profiles_event.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/user_profiles/user_profiles_state.dart';

// Line 29: Update event
- context.read<UserProfileBloc>().add(WatchUserProfile(userId: userId));
+ context.read<UserProfilesBloc>().add(WatchUserProfile(userId: widget.userId.value));

// Line 39: Update BlocBuilder
- return BlocBuilder<UserProfileBloc, UserProfileState>(
+ return BlocBuilder<UserProfilesBloc, UserProfilesState>(

// Update state checks
- UserProfileLoaded → UserProfileLoaded (same name!)
- UserProfileLoading → UserProfilesLoading
- UserProfileError → UserProfilesError
```

##### File: `lib/features/user_profile/presentation/hero_user_profile_screen.dart`

**Changes**:

```dart
// This screen views OTHER users
// OLD IMPORT
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';

// NEW IMPORT
+ import 'package:trackflow/features/user_profile/presentation/bloc/user_profiles/user_profiles_bloc.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/user_profiles/user_profiles_event.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/user_profiles/user_profiles_state.dart';

// Line 39: Update event
- context.read<UserProfileBloc>().add(WatchUserProfile(userId: userId));
+ context.read<UserProfilesBloc>().add(WatchUserProfile(userId: widget.userId.value));

// Line 60: Update BlocBuilder
- return BlocBuilder<UserProfileBloc, UserProfileState>(
+ return BlocBuilder<UserProfilesBloc, UserProfilesState>(
```

#### 4. Navigation Feature

##### File: `lib/features/navegation/presentation/widget/main_scaffold.dart`

**Changes**:

```dart
// This uses CURRENT user
// OLD IMPORT
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';

// NEW IMPORT
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_event.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';

// Line 49: Update event
- context.read<UserProfileBloc>().add(ClearUserProfile());
+ context.read<CurrentUserBloc>().add(ClearCurrentUserProfile());

// Line 52: Update BlocListener
- return BlocListener<UserProfileBloc, UserProfileState>(
+ return BlocListener<CurrentUserBloc, CurrentUserState>(
```

#### 5. Project Detail Feature (Permission Checks)

##### File: `lib/features/project_detail/presentation/components/project_detail_sliver_header.dart`

**Changes**:

```dart
// Uses CURRENT user for permissions
// OLD IMPORT
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';

// NEW IMPORT
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';

// Line 134: Update BlocBuilder
- return BlocBuilder<UserProfileBloc, UserProfileState>(
+ return BlocBuilder<CurrentUserBloc, CurrentUserState>(

// Update state checks
- UserProfileLoaded → CurrentUserLoaded
```

##### File: `lib/features/project_detail/presentation/components/project_detail_collaborators_component.dart`

**Changes**:

```dart
// Uses CURRENT user for permissions
// OLD IMPORT
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';

// NEW IMPORT
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';

// Line 113: Update watch
- final userState = context.watch<UserProfileBloc>().state;
+ final userState = context.watch<CurrentUserBloc>().state;

// Update state checks
- UserProfileLoaded → CurrentUserLoaded
```

#### 6. Manage Collaborators Feature

##### File: `lib/features/manage_collaborators/presentation/screens/manage_collaborators_screen.dart`

**Changes**:

```dart
// Uses CURRENT user for permissions + OTHER users for display
// Need BOTH BLoCs!

// OLD IMPORT
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';

// NEW IMPORTS
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/user_profiles/user_profiles_bloc.dart';

// Line 44: Update reprovideBlocs
reprovideBlocs: [
  context.read<ManageCollaboratorsBloc>(),
- context.read<UserProfileBloc>()
+ context.read<CurrentUserBloc>()
]

// Line 50: Update parameter
- userProfileBloc: context.read<UserProfileBloc>()
+ currentUserBloc: context.read<CurrentUserBloc>()
```

##### File: `lib/features/manage_collaborators/presentation/widgets/manage_collaborators_actions.dart`

**Changes**:

```dart
// Uses CURRENT user
// OLD IMPORT
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';

// NEW IMPORT
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';

// Line 22: Update parameter
- required UserProfileBloc userProfileBloc,
+ required CurrentUserBloc currentUserBloc,

// Line 24: Update usage
- final state = userProfileBloc.state;
+ final state = currentUserBloc.state;

// Update state checks
- UserProfileLoaded → CurrentUserLoaded
```

#### 7. Audio Features (Permission Checks)

##### File: `lib/features/audio_track/presentation/widgets/audio_track_actions.dart`

**Changes**:

```dart
// Uses CURRENT user for permissions
// OLD IMPORT
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';

// NEW IMPORT
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';

// Line 31: Update read
- final userState = context.read<UserProfileBloc>().state;
+ final userState = context.read<CurrentUserBloc>().state;

// Update state checks
- UserProfileLoaded → CurrentUserLoaded
```

##### File: `lib/features/track_version/presentation/screens/track_detail_screen.dart`

**Changes**:

```dart
// Uses CURRENT user for permissions
// OLD IMPORT
- import '../../../user_profile/presentation/bloc/user_profile_bloc.dart';
- import '../../../user_profile/presentation/bloc/user_profile_states.dart';

// NEW IMPORT
+ import '../../../user_profile/presentation/bloc/current_user/current_user_bloc.dart';
+ import '../../../user_profile/presentation/bloc/current_user/current_user_state.dart';

// Line 149: Update watch
- final userState = context.watch<UserProfileBloc>().state;
+ final userState = context.watch<CurrentUserBloc>().state;

// Update state checks
- UserProfileLoaded → CurrentUserLoaded
```

##### File: `lib/features/track_version/presentation/widgets/track_detail_actions_sheet.dart`

**Changes**:

```dart
// Uses CURRENT user for permissions
// OLD IMPORT
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';

// NEW IMPORT
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';

// Line 29: Update read
- final userState = context.read<UserProfileBloc>().state;
+ final userState = context.read<CurrentUserBloc>().state;

// Update state checks
- UserProfileLoaded → CurrentUserLoaded
```

##### File: `lib/features/audio_comment/presentation/components/comments_list_view.dart`

**Changes**:

```dart
// Uses CURRENT user
// OLD IMPORT
- import '../../user_profile/presentation/bloc/user_profile_bloc.dart';
- import '../../user_profile/presentation/bloc/user_profile_states.dart';

// NEW IMPORT
+ import '../../user_profile/presentation/bloc/current_user/current_user_bloc.dart';
+ import '../../user_profile/presentation/bloc/current_user/current_user_state.dart';

// Line 40: Update BlocBuilder
- return BlocBuilder<UserProfileBloc, UserProfileState>(
+ return BlocBuilder<CurrentUserBloc, CurrentUserState>(

// Update state checks
- UserProfileLoaded → CurrentUserLoaded
```

#### 8. Playlist Feature

##### File: `lib/features/playlist/presentation/widgets/playlist_tracks_widget.dart`

**Changes**:

```dart
// Uses CURRENT user for permissions
// OLD IMPORT
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
- import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';

// NEW IMPORT
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
+ import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';

// Line 69: Update watch
- final userState = context.watch<UserProfileBloc>().state;
+ final userState = context.watch<CurrentUserBloc>().state;

// Update state checks
- UserProfileLoaded → CurrentUserLoaded
```

#### 9. Update Router Configuration

##### File: `lib/core/router/app_router.dart`

**Changes**:

```dart
// Line 146: Update artist profile provider method name
static List<BlocProvider> getArtistProfileProviders() {
  return [
-   BlocProvider<UserProfileBloc>(create: (_) => sl<UserProfileBloc>()),
+   BlocProvider<UserProfilesBloc>(create: (_) => sl<UserProfilesBloc>()),
  ];
}

// Update route that uses this provider (around line 168-179)
GoRoute(
  path: AppRoutes.artistProfile,
  builder: (context, state) {
    final userId = state.pathParameters['id']!;
    return MultiBlocProvider(
      providers: AppBlocProviders.getArtistProfileProviders(),
      child: CollaboratorProfileScreen(
        userId: UserId.fromUniqueString(userId),
      ),
    );
  },
),
```

### Success Criteria

#### Automated Verification:
- [ ] No analyzer errors: `flutter analyze`
- [ ] App compiles successfully: `flutter run`
- [ ] All imports resolved correctly

#### Manual Verification:
- [ ] Settings screen shows current user profile correctly
- [ ] Edit profile works and shows brief success message
- [ ] Navigate away and back - shows loaded profile (NOT "updated")
- [ ] Collaborator profile screen shows correct user
- [ ] Permission checks work in audio actions
- [ ] No runtime errors in any screen

---

## Phase 4: Fix State Transitions

### Overview

Ensure CurrentUserBloc properly transitions from Saved state back to Loaded state, with optional brief success message display. Also ensure the auth listener properly re-initializes watching after logout/login.

### Changes Required

#### 1. Verify Auto-Transition Logic in CurrentUserBloc

**File**: `lib/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart`

**Already implemented in Phase 1, verify**:

Lines 173-185 in `_onUpdateCurrentUserProfile`:
```dart
// Update succeeded - show success briefly then return to loaded
emit(CurrentUserSaved(profile: event.profile));

// Auto-transition back to loaded after 2 seconds
await Future.delayed(const Duration(seconds: 2));
if (!isClosed && state is CurrentUserSaved) {
  // The watch stream should have emitted the updated profile by now
  // But if not, we'll emit loaded state with the profile we just saved
  emit(CurrentUserLoaded(profile: event.profile));
}
```

#### 2. Verify Auth Listener Re-initialization

**File**: `lib/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart`

**Already implemented in Phase 1, verify**:

Lines 62-69:
```dart
// Listen to auth state changes and auto-watch on login
_authSubscription = _getAuthStateUseCase().listen((user) {
  if (user != null && state is CurrentUserInitial) {
    // User logged in and bloc is in initial state - start watching
    add(WatchCurrentUserProfile());
  }
});
```

#### 3. Update UI Components to Handle CurrentUserSaved State

##### File: `lib/features/settings/presentation/widgets/user_profile_section.dart`

**Verify the bug fix** at line 131:

```dart
} else if (state is CurrentUserSaved) {
  displayText = 'Profile updated';
  subtitleText = 'Changes saved successfully';
  textColor = AppColors.success;
}
```

This will now only show for 2 seconds before auto-transitioning to `CurrentUserLoaded`.

##### File: `lib/features/user_profile/presentation/screens/profile_creation_screen.dart`

**Verify** at line 172:

```dart
} else if (state is CurrentUserSaved) {
  setState(() => _isLoading = false);
  _showSuccess('Profile created successfully!');
  _handleAppFlowCheck();
}
```

The success snackbar will show, and after 2 seconds the BLoC will transition to watching the profile.

### Success Criteria

#### Automated Verification:
- [ ] All tests pass: `flutter test`
- [ ] No analyzer errors: `flutter analyze`

#### Manual Verification:
- [ ] Edit profile → Save → See "Profile updated" message
- [ ] Wait 2 seconds → Message disappears → Shows loaded profile with updated data
- [ ] Navigate away and back → Shows loaded profile (NOT "updated")
- [ ] Logout → Login → Profile automatically loads (not stuck in Initial state)
- [ ] Create profile → Shows success → Automatically transitions to loaded state

---

## Phase 5: Cleanup & Optimization

### Overview

Remove over-engineered logic from session service, eliminate 500ms cleanup delay, and reduce excessive logging across the codebase.

### Changes Required

#### 1. Simplify SessionService Startup Logic

**File**: `lib/core/app_flow/domain/services/session_service.dart`

**Current issues**:
- Lines 67-97: Complex user fetching with sync coupling
- Multiple nested awaits create race conditions
- Unnecessary complexity

**Changes**:

```dart
/// Get the current user session
Future<Either<Failure, UserSession>> getCurrentSession() async {
  try {
    // Step 1: Check authentication status
    final authResult = await _checkAuthUseCase();
    final isAuthenticated = authResult.getOrElse(() => false);

    if (!isAuthenticated) {
      return const Right(UserSession.unauthenticated());
    }

    // Step 2: Get current user (simplified - no sync coupling)
    final userResult = await _getCurrentUserUseCase();
    final user = userResult.getOrElse(() => null);

    if (user == null) {
      return const Right(UserSession.unauthenticated());
    }

    // Step 3: Check setup requirements in parallel
    final results = await Future.wait([
      _onboardingUseCase.checkOnboardingCompleted(user.id.value),
      _profileUseCase.isProfileComplete(user.id.value),
    ]);

    final onboardingComplete = results[0].getOrElse(() => false);
    final profileComplete = results[1].getOrElse(() => false);

    // Step 4: Return session state
    if (!onboardingComplete || !profileComplete) {
      return Right(
        UserSession.authenticated(
          user: user,
          onboardingComplete: onboardingComplete,
          profileComplete: profileComplete,
        ),
      );
    }

    return Right(UserSession.ready(user: user));
  } catch (e) {
    return Left(ServerFailure('Session check failed: $e'));
  }
}
```

**Remove these methods** (they're extensions on Either):

```dart
// DELETE these helper extensions - use getOrElse() directly
extension EitherExtensions<L, R> on Either<L, R> {
  R? getOrElse(R? Function() orElse) {
    return fold(
      (_) => orElse(),
      (r) => r,
    );
  }
}
```

#### 2. Remove 500ms Cleanup Delay

**File**: `lib/core/app_flow/presentation/bloc/app_flow_bloc.dart`

**Current code** (lines 117-133):

```dart
/// Schedule delayed cleanup to ensure all BLoCs are registered
void _scheduleDelayedCleanup() {
  if (_isSessionCleanupInProgress) return;

  _isSessionCleanupInProgress = true;

  AppLogger.info(
    'Scheduling delayed cleanup',
    tag: 'APP_FLOW_BLOC',
  );

  Future.delayed(const Duration(milliseconds: 500), () {
    _clearAllUserState();
  });
}
```

**New code** (remove delay):

```dart
/// Trigger cleanup immediately
void _scheduleDelayedCleanup() {
  if (_isSessionCleanupInProgress) return;

  _isSessionCleanupInProgress = true;

  // BLoCs are registered immediately via ResetableBlocMixin constructor
  // No need for delay
  _clearAllUserState();
}
```

#### 3. Reduce Excessive Logging

**Strategy**:
- Keep ERROR and WARNING logs
- Remove most INFO logs from normal flow operations
- Convert remaining INFO to DEBUG with conditional compilation

##### File: `lib/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart`

**Remove these INFO logs**:
- Lines 97-103: "WatchCurrentUserProfile event received"
- Lines 141-146: "Profile loaded successfully"

**Keep ERROR logs**:
- Line 121: "Error watching current user profile"
- Line 154: "Profile creation failed"
- Line 187: "Profile update failed"

##### File: `lib/core/app_flow/presentation/bloc/app_flow_bloc.dart`

**Remove these INFO logs**:
- Line 35: "Auth state changed - user: ..."
- Line 68: "Starting app flow check"
- Line 83: "Session state: ..."
- Line 105: "App flow check completed: ..."

**Keep WARNING/ERROR logs**:
- Line 76: "Session check failed"
- Line 110: "App flow check failed"
- Line 147: "Session cleanup failed"

##### File: `lib/core/app_flow/domain/services/session_service.dart`

**Remove ALL INFO logs** (37 occurrences):
- Remove lines 37, 52, 60, 68, 84, 100, 124, 143, 166, 187, 199, 220

**Keep ERROR/WARNING logs**:
- Line 45, 77, 117, 135

##### File: `lib/core/app_flow/domain/services/session_cleanup_service.dart`

**Remove these INFO logs**:
- Line 89: "Starting comprehensive session cleanup"
- Line 95: "Clearing SessionStorage"
- Line 103: "Clearing UserProfile cache"
- Line 114: "UserProfile cache cleared successfully"
- Line 179: "Session cleanup completed successfully"

**Keep WARNING/ERROR logs**:
- Line 110: "UserProfile cache clear failed"
- Line 172: "Some cleanup tasks failed"
- Line 187: "Session cleanup failed with exception"

#### 4. Use Conditional Debug Logging

**Create a debug logging helper**:

**New file**: `lib/core/utils/debug_logger.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:trackflow/core/utils/app_logger.dart';

class DebugLogger {
  /// Log debug information only in debug builds
  static void debug(String message, {String? tag, Object? error}) {
    if (kDebugMode) {
      AppLogger.info(message, tag: tag ?? 'DEBUG', error: error);
    }
  }

  /// Log verbose information only in debug builds
  static void verbose(String message, {String? tag}) {
    if (kDebugMode) {
      AppLogger.info(message, tag: tag ?? 'VERBOSE');
    }
  }
}
```

**Usage in BLoCs** (where detailed logging is needed):

```dart
import 'package:trackflow/core/utils/debug_logger.dart';

// Instead of:
AppLogger.info('Profile loaded successfully', tag: 'CURRENT_USER_BLOC');

// Use:
DebugLogger.debug('Profile loaded successfully', tag: 'CURRENT_USER_BLOC');
```

### Success Criteria

#### Automated Verification:
- [ ] All tests pass: `flutter test`
- [ ] No analyzer errors: `flutter analyze`
- [ ] App compiles: `flutter run`

#### Manual Verification:
- [ ] Console output is much cleaner during normal operations
- [ ] ERROR logs still appear for actual errors
- [ ] No noticeable performance difference (500ms delay was unnecessary)
- [ ] Login/logout flow works smoothly
- [ ] Profile operations work correctly

---

## Testing Strategy

### Unit Tests

#### CurrentUserBloc Tests

**New file**: `test/features/user_profile/presentation/bloc/current_user/current_user_bloc_test.dart`

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';

// Mock use cases
class MockUpdateUserProfileUseCase extends Mock implements UpdateUserProfileUseCase {}
class MockCreateUserProfileUseCase extends Mock implements CreateUserProfileUseCase {}
class MockWatchUserProfileUseCase extends Mock implements WatchUserProfileUseCase {}
// ... other mocks

void main() {
  group('CurrentUserBloc', () {
    late CurrentUserBloc bloc;
    late MockUpdateUserProfileUseCase mockUpdateUseCase;
    // ... other mocks

    setUp(() {
      mockUpdateUseCase = MockUpdateUserProfileUseCase();
      // ... setup other mocks

      bloc = CurrentUserBloc(
        updateUserProfileUseCase: mockUpdateUseCase,
        // ... inject mocks
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is CurrentUserInitial', () {
      expect(bloc.state, equals(CurrentUserInitial()));
    });

    blocTest<CurrentUserBloc, CurrentUserState>(
      'emits [Loading, Loaded] when WatchCurrentUserProfile succeeds',
      build: () {
        when(mockWatchUseCase.call()).thenAnswer(
          (_) => Stream.value(Right(mockUserProfile)),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(WatchCurrentUserProfile()),
      expect: () => [
        CurrentUserLoading(),
        CurrentUserLoaded(profile: mockUserProfile),
      ],
    );

    blocTest<CurrentUserBloc, CurrentUserState>(
      'emits [Updating, Saved, Loaded] when UpdateCurrentUserProfile succeeds',
      build: () {
        when(mockUpdateUseCase.call(any)).thenAnswer(
          (_) async => const Right(unit),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateCurrentUserProfile(mockUserProfile)),
      expect: () => [
        CurrentUserUpdating(currentProfile: null),
        CurrentUserSaved(profile: mockUserProfile),
        // After 2 seconds should transition to Loaded
      ],
      wait: const Duration(seconds: 3),
    );

    // ... more tests
  });
}
```

#### UserProfilesBloc Tests

**New file**: `test/features/user_profile/presentation/bloc/user_profiles/user_profiles_bloc_test.dart`

Similar structure to CurrentUserBloc tests, focusing on:
- Watching single profile
- Watching multiple profiles
- Loading profile (one-time)
- Error handling

### Integration Tests

#### Profile Edit Flow Test

**File**: `test/integration_test/profile_edit_flow_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Profile Edit Flow', () {
    testWidgets('Edit profile shows success then returns to loaded', (tester) async {
      // 1. Launch app and login
      // 2. Navigate to settings
      // 3. Tap edit profile
      // 4. Change name
      // 5. Tap save
      // 6. Verify success message appears
      // 7. Wait 2 seconds
      // 8. Verify message disappears
      // 9. Verify shows loaded profile
      // 10. Navigate away and back
      // 11. Verify still shows loaded (not "updated")
    });
  });
}
```

### Manual Testing Steps

1. **Profile Creation Flow**:
   - Sign up with new account
   - Complete onboarding
   - Create profile with name and role
   - Verify success message appears
   - Verify automatically redirects to dashboard
   - Verify profile loaded in settings

2. **Profile Edit Flow**:
   - Navigate to settings
   - Verify profile loaded correctly
   - Tap edit profile
   - Change name
   - Tap save
   - Verify "Profile updated" message appears
   - Wait 2 seconds
   - Verify message disappears
   - Verify updated profile shows
   - Navigate to dashboard
   - Return to settings
   - Verify shows loaded profile (NOT "updated" message)

3. **Logout/Login Flow**:
   - View settings (profile loaded)
   - Logout
   - Login again
   - Navigate to settings
   - Verify profile automatically loads (not stuck in initial state)

4. **Collaborator Profile Flow**:
   - Navigate to a project
   - View project details
   - Tap on a collaborator
   - Verify collaborator's profile loads
   - Verify correct user information displayed
   - Navigate back
   - View another collaborator
   - Verify correct profile loads

5. **Permission Checks**:
   - As project owner: Verify can edit tracks
   - As project editor: Verify can comment
   - As project viewer: Verify cannot edit
   - Navigate between projects
   - Verify permissions update correctly

---

## Performance Considerations

### Memory Impact

- **Before**: 1 singleton UserProfileBloc watching current user
- **After**: 1 singleton CurrentUserBloc + scoped UserProfilesBloc instances
- **Impact**: Minimal - UserProfilesBloc only created when viewing collaborators
- **Cleanup**: UserProfilesBloc disposed when leaving collaborator screens

### Startup Performance

- **Removed**: 500ms artificial delay in cleanup
- **Simplified**: Session service validation logic
- **Result**: Faster logout/login cycle (500ms improvement)

### Stream Performance

- **CurrentUserBloc**: Single watch stream per user session (same as before)
- **UserProfilesBloc**: Multiple instances possible, but short-lived (scoped to screens)
- **Optimization**: Use `WatchMultipleUserProfiles` for batch loading instead of individual streams

### Logging Performance

- **Before**: 100+ INFO logs during normal operations
- **After**: Only ERROR/WARNING logs in production, DEBUG logs in debug builds
- **Result**: Reduced console spam, easier debugging, slightly better performance

---

## Migration Notes

### No Data Migration Required

This refactor does NOT change:
- Database schemas (Isar or Firestore)
- User profile entity structure
- Repository implementations
- Use case logic

### Backward Compatibility

- Existing user profiles will continue to work
- No changes to Firebase security rules needed
- No changes to API contracts

### Rollback Plan

If issues are discovered:

1. **Phase 3 rollback**: Revert file changes, restore old imports
2. **Phase 2 rollback**: Remove UserProfilesBloc, restore old UserProfileBloc
3. **Phase 1 rollback**: Remove CurrentUserBloc, restore old singleton pattern

Each phase is independently reversible.

---

## References

- Bug report context: User profile state persistence analysis (2025-10-16)
- Current implementation: [user_profile_bloc.dart](lib/features/user_profile/presentation/bloc/user_profile_bloc.dart)
- App providers: [app_bloc_providers.dart](lib/core/app/providers/app_bloc_providers.dart)
- Session service: [session_service.dart](lib/core/app_flow/domain/services/session_service.dart)
- Cleanup service: [session_cleanup_service.dart](lib/core/app_flow/domain/services/session_cleanup_service.dart)
- Settings UI: [user_profile_section.dart](lib/features/settings/presentation/widgets/user_profile_section.dart)

---

## Implementation Timeline

**Estimated time**: 8-12 hours

- Phase 1: 2-3 hours (Create CurrentUserBloc)
- Phase 2: 1-2 hours (Create UserProfilesBloc)
- Phase 3: 3-4 hours (Update 22 files)
- Phase 4: 1 hour (Verify transitions)
- Phase 5: 2-3 hours (Cleanup & optimization)

**Recommended approach**: Implement phases sequentially with verification after each phase.
