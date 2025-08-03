# BLoC State Cleanup Pattern

## Overview

The BLoC State Cleanup Pattern ensures complete session isolation by automatically resetting BLoC states during user logout. This prevents data persistence between different user sessions and maintains a clean application state.

## Architecture

```
SessionCleanupService
├── BlocStateCleanupService (Reset BLoC states)
└── Repository Cleanup (Clear cached data)
```

### Core Components

- **`Resetable` Interface**: Contract for components that can be reset
- **`BlocStateCleanupService`**: Manages all resetable BLoCs
- **`ResetableBlocMixin`**: Convenient mixin for BLoC integration
- **Auto-Registration**: BLoCs self-register for cleanup

## Why Use This Pattern?

### ❌ **Without BLoC State Cleanup:**
```dart
// User A logs out, User B logs in
// UserProfileBloc still shows User A's data briefly
// ProjectsBloc retains User A's project list
// NavigationCubit shows User A's last selected tab
```

### ✅ **With BLoC State Cleanup:**
```dart
// User A logs out → All BLoCs reset to initial state
// User B logs in → Clean slate, no previous user data
// Immediate UI consistency
```

## Implementation Guide

### Option 1: Using ResetableBlocMixin (Recommended)

The mixin handles registration/unregistration automatically:

```dart
import 'package:trackflow/core/common/mixins/resetable_bloc_mixin.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState>
    with ResetableBlocMixin<UserProfileEvent, UserProfileState> {
  
  UserProfileBloc({
    required UpdateUserProfileUseCase updateUserProfileUseCase,
    // ... other dependencies
  }) : super(UserProfileInitial()) {
    on<WatchUserProfile>(_onWatchUserProfile);
    // ... other event handlers
    
    // ✅ Register for automatic cleanup
    registerForCleanup();
  }

  // ✅ Define the initial state for reset
  @override
  UserProfileState get initialState => UserProfileInitial();
  
  // Event handlers...
}
```

### Option 2: Manual Implementation

For more control, implement the `Resetable` interface directly:

```dart
import 'package:trackflow/core/common/interfaces/resetable.dart';
import 'package:trackflow/core/app_flow/domain/services/bloc_state_cleanup_service.dart';
import 'package:trackflow/core/di/injection.dart';

class NavigationCubit extends Cubit<AppTab> implements Resetable {
  NavigationCubit() : super(AppTab.projects) {
    // ✅ Manual registration
    final cleanupService = sl<BlocStateCleanupService>();
    cleanupService.registerResetable(this);
  }

  @override
  void reset() => emit(AppTab.projects);

  @override
  Future<void> close() {
    // ✅ Unregister on disposal
    try {
      final cleanupService = sl<BlocStateCleanupService>();
      cleanupService.unregisterResetable(this);
    } catch (e) {
      // Service might be disposed, ignore
    }
    return super.close();
  }
}
```

## Usage Examples

### Example 1: Simple State BLoC

```dart
class ProjectDetailBloc extends Bloc<ProjectDetailEvent, ProjectDetailState>
    with ResetableBlocMixin<ProjectDetailEvent, ProjectDetailState> {
  
  ProjectDetailBloc() : super(ProjectDetailInitial()) {
    on<LoadProjectDetail>(_onLoadProjectDetail);
    registerForCleanup();
  }

  @override
  ProjectDetailState get initialState => ProjectDetailInitial();
}
```

### Example 2: Complex State BLoC with Subscriptions

```dart
class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState>
    with ResetableBlocMixin<AudioPlayerEvent, AudioPlayerState> {
  
  StreamSubscription? _playbackSubscription;
  
  AudioPlayerBloc() : super(AudioPlayerInitial()) {
    on<PlayAudio>(_onPlayAudio);
    on<StopAudio>(_onStopAudio);
    registerForCleanup();
  }

  @override
  AudioPlayerState get initialState => AudioPlayerInitial();

  @override
  void reset() {
    // Cancel subscriptions before resetting state
    _playbackSubscription?.cancel();
    _playbackSubscription = null;
    
    // Call parent reset to emit initial state
    super.reset();
  }

  @override
  Future<void> close() {
    _playbackSubscription?.cancel();
    return super.close();
  }
}
```

### Example 3: Cubit with Enum State

```dart
enum LoadingState { initial, loading, loaded, error }

class SimpleCubit extends Cubit<LoadingState> implements Resetable {
  SimpleCubit() : super(LoadingState.initial) {
    final cleanupService = sl<BlocStateCleanupService>();
    cleanupService.registerResetable(this);
  }

  @override
  void reset() => emit(LoadingState.initial);

  @override
  Future<void> close() {
    try {
      final cleanupService = sl<BlocStateCleanupService>();
      cleanupService.unregisterResetable(this);
    } catch (e) {
      // Ignore disposal errors
    }
    return super.close();
  }
}
```

## Integration Guidelines

### 1. When to Use BLoC State Cleanup

✅ **Always use for user-specific data:**
- User profiles, preferences, settings
- Project lists, audio tracks, comments
- Navigation state, UI selections
- Cached user-specific content

❌ **Don't use for global app state:**
- App configuration, feature flags
- Network status, connectivity
- Theme preferences (if app-wide)
- System-level settings

### 2. Initial State Design

Your `initialState` should represent a clean, user-agnostic state:

```dart
// ✅ Good - Clean initial state
@override
UserProfileState get initialState => UserProfileInitial();

// ✅ Good - Specific clean state
@override
ProjectListState get initialState => ProjectListEmpty();

// ❌ Bad - Still contains user data
@override
UserProfileState get initialState => UserProfileLoaded(lastKnownProfile);
```

### 3. Registration Best Practices

```dart
// ✅ Good - Register in constructor
class MyBloc extends Bloc<MyEvent, MyState> 
    with ResetableBlocMixin<MyEvent, MyState> {
  
  MyBloc() : super(MyInitial()) {
    on<MyEvent>(_onMyEvent);
    registerForCleanup(); // ✅ After event handlers
  }
}

// ❌ Bad - Late registration
class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc() : super(MyInitial()) {
    on<MyEvent>(_onMyEvent);
    // Missing registerForCleanup()!
  }
  
  void someMethod() {
    registerForCleanup(); // ❌ Too late!
  }
}
```

## Testing

### Testing BLoC Reset Functionality

```dart
void main() {
  group('UserProfileBloc Reset', () {
    late UserProfileBloc bloc;
    late MockUpdateUserProfileUseCase mockUpdateUseCase;

    setUp(() {
      mockUpdateUseCase = MockUpdateUserProfileUseCase();
      bloc = UserProfileBloc(updateUserProfileUseCase: mockUpdateUseCase);
    });

    test('should reset to initial state when reset() is called', () {
      // Arrange - Put bloc in non-initial state
      bloc.emit(UserProfileLoaded(testProfile));
      
      // Act
      bloc.reset();
      
      // Assert
      expect(bloc.state, isA<UserProfileInitial>());
    });
    
    test('should be registered with cleanup service', () {
      // This test requires access to BlocStateCleanupService
      final cleanupService = sl<BlocStateCleanupService>();
      expect(cleanupService.registeredCount, greaterThan(0));
    });
  });
}
```

### Testing Service Integration

```dart
void main() {
  group('BlocStateCleanupService', () {
    late BlocStateCleanupService service;
    late MockResetableBloc mockBloc;

    setUp(() {
      service = BlocStateCleanupService();
      mockBloc = MockResetableBloc();
    });

    test('should register and reset BLoCs', () {
      // Arrange
      service.registerResetable(mockBloc);
      
      // Act
      service.resetAllBlocStates();
      
      // Assert
      verify(mockBloc.reset()).called(1);
    });
  });
}
```

## Common Patterns

### Pattern 1: Conditional Reset

```dart
@override
void reset() {
  // Only reset if user was logged in
  if (state is UserProfileLoaded) {
    emit(UserProfileInitial());
  }
}
```

### Pattern 2: Reset with Cleanup

```dart
@override
void reset() {
  // Cancel ongoing operations
  _cancelAllSubscriptions();
  
  // Clear any local cache
  _clearLocalData();
  
  // Reset to initial state
  super.reset();
}
```

### Pattern 3: Progressive Reset

```dart
@override
void reset() {
  // Show loading state briefly to indicate reset
  emit(UserProfileLoading());
  
  // Then reset to clean initial state
  Future.microtask(() => emit(UserProfileInitial()));
}
```

## Troubleshooting

### Issue: BLoC Not Resetting

**Problem:** BLoC state persists after logout

**Solutions:**
1. Check if `registerForCleanup()` is called in constructor
2. Verify `initialState` getter returns correct state
3. Ensure BLoC implements `Resetable` interface or uses mixin

### Issue: Memory Leaks

**Problem:** BLoCs not being disposed properly

**Solutions:**
1. Always call `super.close()` in overridden `close()` method
2. Unregister from cleanup service in `close()`
3. Cancel subscriptions before disposal

### Issue: Inconsistent Reset Behavior

**Problem:** Some BLoCs reset, others don't

**Solutions:**
1. Check all BLoCs use the same pattern (mixin vs manual)
2. Verify all are registered with the cleanup service
3. Add logging to track reset calls

## Migration Guide

### Migrating Existing BLoCs

1. **Add the mixin:**
```dart
// Before
class MyBloc extends Bloc<MyEvent, MyState> {

// After  
class MyBloc extends Bloc<MyEvent, MyState>
    with ResetableBlocMixin<MyEvent, MyState> {
```

2. **Add registration:**
```dart
MyBloc() : super(MyInitial()) {
  // existing code...
  registerForCleanup(); // Add this
}
```

3. **Define initial state:**
```dart
@override
MyState get initialState => MyInitial(); // Add this
```

### Gradual Adoption

You can adopt this pattern gradually:
1. Start with critical user-data BLoCs (UserProfile, Projects)
2. Add navigation and UI state BLoCs
3. Finally migrate remaining BLoCs as needed

## Performance Considerations

- ✅ BLoC reset is synchronous and fast
- ✅ Cleanup service handles errors gracefully
- ✅ Registration/unregistration is lightweight
- ⚠️ Avoid heavy operations in `reset()` method
- ⚠️ Large numbers of BLoCs may slow down cleanup slightly

## Best Practices Summary

1. **Always use the mixin** for new BLoCs
2. **Register in constructor** after event handlers
3. **Keep initial state clean** and user-agnostic
4. **Handle subscriptions** in custom reset methods
5. **Test reset functionality** in unit tests
6. **Document state assumptions** in complex BLoCs