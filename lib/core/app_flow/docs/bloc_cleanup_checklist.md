# BLoC State Cleanup - Integration Checklist

## Quick Setup Checklist

### ✅ For New BLoCs

When creating a new BLoC that handles user-specific data:

- [ ] **Import the mixin**
  ```dart
  import 'package:trackflow/core/common/mixins/resetable_bloc_mixin.dart';
  ```

- [ ] **Add the mixin to your BLoC**
  ```dart
  class MyBloc extends Bloc<MyEvent, MyState>
      with ResetableBlocMixin<MyEvent, MyState> {
  ```

- [ ] **Register for cleanup in constructor**
  ```dart
  MyBloc() : super(MyInitial()) {
    // ... event handlers
    registerForCleanup(); // Add this line
  }
  ```

- [ ] **Define initial state getter**
  ```dart
  @override
  MyState get initialState => MyInitial();
  ```

- [ ] **Test the reset functionality**
  ```dart
  test('should reset to initial state', () {
    bloc.emit(MyLoadedState());
    bloc.reset();
    expect(bloc.state, isA<MyInitial>());
  });
  ```

### ✅ For Existing BLoCs

When retrofitting existing BLoCs:

- [ ] **Identify if BLoC handles user-specific data**
  - User profiles, preferences, settings
  - Project lists, content, selections
  - Navigation state, UI state
  - Cached user content

- [ ] **Choose implementation approach**
  - [ ] **Recommended**: Use `ResetableBlocMixin`
  - [ ] **Alternative**: Manual `Resetable` interface implementation

- [ ] **Add registration call**
  ```dart
  // In constructor, after event handlers
  registerForCleanup();
  ```

- [ ] **Define clean initial state**
  ```dart
  @override
  MyState get initialState => MyInitial(); // Clean, user-agnostic state
  ```

- [ ] **Handle subscriptions (if any)**
  ```dart
  @override
  void reset() {
    _subscription?.cancel();
    _subscription = null;
    super.reset(); // Call parent reset
  }
  ```

- [ ] **Update tests**
  - Test reset functionality
  - Verify registration with cleanup service
  - Test that state doesn't persist after reset

## Verification Steps

### 🔍 Manual Testing

1. **Login with User A**
   - Navigate through app, load data
   - Note current state in various BLoCs

2. **Logout User A**
   - Trigger manual logout
   - Verify all BLoCs show initial/empty state

3. **Login with User B** 
   - Verify no User A data appears
   - Check all screens show clean state

4. **Test Automatic Logout**
   - Simulate token expiration
   - Verify cleanup triggers automatically

### 🧪 Unit Testing

```dart
group('BLoC Reset Tests', () {
  test('BLoC should reset to initial state', () {
    // Arrange
    bloc.emit(NonInitialState());
    
    // Act  
    bloc.reset();
    
    // Assert
    expect(bloc.state, equals(bloc.initialState));
  });
  
  test('BLoC should be registered with cleanup service', () {
    final service = sl<BlocStateCleanupService>();
    final initialCount = service.registeredCount;
    
    final newBloc = MyBloc();
    
    expect(service.registeredCount, equals(initialCount + 1));
    
    newBloc.close();
  });
});
```

## Common Integration Issues

### ❌ Issue: BLoC Not Resetting

**Symptoms:** BLoC state persists after logout

**Checklist:**
- [ ] Is `registerForCleanup()` called in constructor?
- [ ] Does BLoC implement `Resetable` or use the mixin?
- [ ] Is `initialState` getter implemented correctly?
- [ ] Are there any exceptions in the `reset()` method?

**Debug Steps:**
1. Add logging to reset method
2. Check cleanup service registration count
3. Verify SessionCleanupService is calling BlocStateCleanupService

### ❌ Issue: Memory Leaks

**Symptoms:** App memory usage grows over time

**Checklist:**  
- [ ] Is `close()` method calling `super.close()`?
- [ ] Are subscriptions cancelled in `reset()` or `close()`?
- [ ] Is BLoC unregistered from cleanup service on disposal?

**Debug Steps:**
1. Use Flutter Inspector to check widget tree
2. Monitor cleanup service registration count
3. Check for uncancelled subscriptions

### ❌ Issue: Race Conditions

**Symptoms:** Inconsistent state after rapid login/logout

**Checklist:**
- [ ] Are async operations cancelled in `reset()`?
- [ ] Does reset happen before new user data loads?
- [ ] Are there any cached operations continuing after reset?

**Debug Steps:**
1. Add timing logs to reset and data loading
2. Cancel all async operations in reset method
3. Use `completer.isCancelled` checks in async methods

## Performance Considerations

### ✅ Optimization Tips

- **Keep reset methods fast** - Avoid heavy operations
- **Cancel subscriptions early** - Do it in reset(), not just close()
- **Use batch operations** - Group related state changes
- **Minimize state emissions** - Don't emit intermediate states during reset

### 📊 Monitoring

Add logging to track reset performance:

```dart
@override
void reset() {
  final stopwatch = Stopwatch()..start();
  
  // Your reset logic
  super.reset();
  
  stopwatch.stop();
  AppLogger.info(
    'Reset completed in ${stopwatch.elapsedMilliseconds}ms',
    tag: '${runtimeType}_RESET'
  );
}
```

## BLoC Categories

### 🔴 **Always Implement Cleanup**
- UserProfileBloc
- ProjectsBloc  
- AudioTrackBloc
- AudioCommentBloc
- NavigationCubit
- Any BLoC with user-specific data

### 🟡 **Consider Implementing**
- SettingsBloc (if user-specific settings)
- OnboardingBloc (if tracks user progress)  
- NotificationBloc (if user-specific notifications)
- CacheBloc (if caches user data)

### 🟢 **Usually Don't Need Cleanup**
- ThemeBloc (app-wide theme)
- ConnectivityBloc (system state)
- PermissionBloc (system permissions)
- ConfigBloc (app configuration)

## Migration Timeline

### Phase 1: Critical BLoCs (Week 1)
- [ ] UserProfileBloc
- [ ] NavigationCubit  
- [ ] AuthBloc (already done)

### Phase 2: Data BLoCs (Week 2)
- [ ] ProjectsBloc
- [ ] AudioTrackBloc
- [ ] AudioCommentBloc

### Phase 3: Remaining BLoCs (Week 3)
- [ ] OnboardingBloc
- [ ] SettingsBloc
- [ ] Other feature BLoCs

### Phase 4: Testing & Refinement (Week 4)
- [ ] Comprehensive testing
- [ ] Performance optimization
- [ ] Documentation updates

## Code Review Checklist

When reviewing BLoC implementation:

- [ ] **Does BLoC handle user-specific data?** → Should implement cleanup
- [ ] **Is resetable mixin added?** → Check class declaration
- [ ] **Is registration called?** → Check constructor
- [ ] **Is initial state defined?** → Check getter implementation
- [ ] **Are subscriptions handled?** → Check custom reset method
- [ ] **Are tests included?** → Check reset functionality tests
- [ ] **Is cleanup documented?** → Check code comments

## References

- [Main Documentation](./bloc_state_cleanup_pattern.md)
- [Practical Examples](./bloc_cleanup_examples.dart)
- [Core Interface](../../../core/common/interfaces/resetable.dart)
- [Mixin Implementation](../../../core/common/mixins/resetable_bloc_mixin.dart)
- [Cleanup Service](../services/bloc_state_cleanup_service.dart)