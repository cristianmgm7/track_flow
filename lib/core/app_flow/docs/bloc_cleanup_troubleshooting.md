# BLoC State Cleanup - Troubleshooting Guide

## Quick Diagnostic Commands

### Check Registration Status
```dart
// Add this to debug registration issues
final service = sl<BlocStateCleanupService>();
print('Registered BLoCs: ${service.registeredCount}');
```

### Test Individual BLoC Reset
```dart
// Test if a specific BLoC resets properly
final bloc = sl<UserProfileBloc>();
print('Before reset: ${bloc.state}');
bloc.reset();
print('After reset: ${bloc.state}');
```

### Monitor Cleanup Execution
```dart
// Add logging to SessionCleanupService.clearAllUserData()
AppLogger.info('BLoC cleanup started', tag: 'DEBUG');
_blocStateCleanupService.resetAllBlocStates();
AppLogger.info('BLoC cleanup completed', tag: 'DEBUG');
```

## Common Issues & Solutions

### 🔴 Issue: "BLoC state persists after logout"

**Symptoms:**
- User A's data appears briefly when User B logs in
- BLoC shows old state instead of initial state
- Reset method not being called

**Debugging Steps:**

1. **Check Registration**
   ```dart
   // In BLoC constructor, verify this is called:
   registerForCleanup(); // Must be present
   ```

2. **Verify Mixin Usage**
   ```dart
   // Ensure BLoC extends properly:
   class MyBloc extends Bloc<MyEvent, MyState>
       with ResetableBlocMixin<MyEvent, MyState> { // ✅ Correct
   ```

3. **Check Initial State**
   ```dart
   @override
   MyState get initialState => MyInitial(); // Must return clean state
   ```

4. **Add Reset Logging**
   ```dart
   @override
   void reset() {
     print('${runtimeType} reset called'); // Debug line
     super.reset();
   }
   ```

**Solutions:**
- ✅ Add missing `registerForCleanup()` call
- ✅ Implement `initialState` getter correctly
- ✅ Use `ResetableBlocMixin` instead of manual implementation
- ✅ Check for exceptions in reset method

### 🔴 Issue: "App crashes during logout"

**Symptoms:**
- Exception thrown during cleanup process
- App freezes or becomes unresponsive
- Error logs show BLoC-related exceptions

**Common Causes:**

1. **Disposed BLoC Access**
   ```dart
   // ❌ Problem: Accessing disposed BLoC
   void reset() {
     if (isClosed) return; // ✅ Add this check
     super.reset();
   }
   ```

2. **Subscription Errors**
   ```dart
   // ❌ Problem: Not cancelling subscriptions
   void reset() {
     _subscription?.cancel(); // ✅ Cancel first
     _subscription = null;
     super.reset();
   }
   ```

3. **Service Dependency Issues**
   ```dart
   // ❌ Problem: Service already disposed
   @override
   Future<void> close() {
     try {
       final service = sl<BlocStateCleanupService>();
       service.unregisterResetable(this);
     } catch (e) {
       // ✅ Ignore disposal errors
     }
     return super.close();
   }
   ```

**Solutions:**
- ✅ Add null checks before operations
- ✅ Use try-catch blocks in cleanup methods
- ✅ Cancel subscriptions before state reset
- ✅ Check `isClosed` before emitting states

### 🟡 Issue: "Memory leaks after multiple logins"

**Symptoms:**
- App memory usage increases with each login/logout cycle
- Flutter Inspector shows growing widget count
- Performance degrades over time

**Debugging Steps:**

1. **Check Registration Count**
   ```dart
   // Monitor if count keeps growing
   final service = sl<BlocStateCleanupService>();
   print('Registered count: ${service.registeredCount}');
   ```

2. **Verify Unregistration**
   ```dart
   @override
   Future<void> close() {
     print('${runtimeType} closing'); // Debug line
     // ... unregistration code
     return super.close();
   }
   ```

3. **Monitor Subscriptions**
   ```dart
   // Track active subscriptions
   StreamSubscription? _sub;
   
   void _startListening() {
     _sub = stream.listen(...);
     print('Subscription started: ${_sub.hashCode}');
   }
   
   @override
   void reset() {
     if (_sub != null) {
       print('Cancelling subscription: ${_sub.hashCode}');
       _sub?.cancel();
       _sub = null;
     }
     super.reset();
   }
   ```

**Solutions:**
- ✅ Always call `super.close()` in overridden methods
- ✅ Unregister from cleanup service in `close()`
- ✅ Cancel all subscriptions in `reset()` and `close()`
- ✅ Set subscription variables to null after cancelling

### 🟡 Issue: "Inconsistent reset behavior"

**Symptoms:**
- Some BLoCs reset, others don't
- Random failures in cleanup process
- Different behavior between manual and automatic logout

**Debugging Steps:**

1. **Check All BLoCs Use Same Pattern**
   ```bash
   # Search for inconsistent implementations
   grep -r "implements Resetable" lib/
   grep -r "with ResetableBlocMixin" lib/
   ```

2. **Verify Registration Timing**
   ```dart
   // ❌ Wrong: Registering too early
   class MyBloc extends Bloc<MyEvent, MyState> {
     MyBloc() : super(MyInitial()) {
       registerForCleanup(); // ❌ Before event handlers
       on<MyEvent>(_onMyEvent);
     }
   }
   
   // ✅ Correct: Register after setup
   class MyBloc extends Bloc<MyEvent, MyState> {
     MyBloc() : super(MyInitial()) {
       on<MyEvent>(_onMyEvent);
       registerForCleanup(); // ✅ After event handlers
     }
   }
   ```

3. **Add Comprehensive Logging**
   ```dart
   // In BlocStateCleanupService.resetAllBlocStates()
   for (final resetable in _resetableBloCs) {
     try {
       print('Resetting: ${resetable.runtimeType}');
       resetable.reset();
       print('Reset successful: ${resetable.runtimeType}');
     } catch (e) {
       print('Reset failed: ${resetable.runtimeType}, Error: $e');
     }
   }
   ```

**Solutions:**
- ✅ Use consistent pattern across all BLoCs (prefer mixin)
- ✅ Register after all event handlers are set up
- ✅ Add error handling to reset methods
- ✅ Check registration order doesn't matter for your use case

### 🟢 Issue: "Performance slow during logout"

**Symptoms:**
- Logout takes several seconds
- UI freezes during cleanup
- App becomes unresponsive

**Optimization Steps:**

1. **Profile Reset Operations**
   ```dart
   @override
   void reset() {
     final stopwatch = Stopwatch()..start();
     
     // Your reset logic
     super.reset();
     
     stopwatch.stop();
     if (stopwatch.elapsedMilliseconds > 100) {
       print('Slow reset in ${runtimeType}: ${stopwatch.elapsedMilliseconds}ms');
     }
   }
   ```

2. **Identify Heavy Operations**
   ```dart
   // ❌ Heavy operation in reset
   void reset() {
     _heavyDataProcessing(); // Don't do this
     super.reset();
   }
   
   // ✅ Just clean up and reset
   void reset() {
     _subscription?.cancel();
     _clearSimpleState();
     super.reset();
   }
   ```

3. **Use Async for Heavy Cleanup**
   ```dart
   void reset() {
     // Quick synchronous cleanup
     _subscription?.cancel();
     super.reset();
     
     // Heavy cleanup in background
     Future.microtask(() => _heavyCleanup());
   }
   ```

**Solutions:**
- ✅ Keep reset methods lightweight
- ✅ Move heavy operations to background
- ✅ Cancel operations instead of waiting for completion
- ✅ Profile and optimize slow reset methods

## Debugging Tools

### Enable Debug Logging

Add this to your main.dart for comprehensive logging:

```dart
void main() {
  // Enable BLoC state cleanup logging
  if (kDebugMode) {
    AppLogger.enableTag('SESSION_CLEANUP');
    AppLogger.enableTag('BLOC_STATE_CLEANUP');
  }
  
  runApp(MyApp());
}
```

### Custom Debug Widget

Create a debug widget to monitor cleanup:

```dart
class BlocCleanupDebugWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        final service = sl<BlocStateCleanupService>();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('BLoC Cleanup Status'),
            content: Text('Registered BLoCs: ${service.registeredCount}'),
            actions: [
              TextButton(
                onPressed: () {
                  service.resetAllBlocStates();
                  Navigator.pop(context);
                },
                child: Text('Test Reset'),
              ),
            ],
          ),
        );
      },
      child: Icon(Icons.bug_report),
    );
  }
}
```

### Test Helper Functions

```dart
class BlocCleanupTestUtils {
  
  /// Test if all registered BLoCs can reset without errors
  static Future<void> testAllBlocResets() async {
    final service = sl<BlocStateCleanupService>();
    
    print('Testing ${service.registeredCount} registered BLoCs...');
    
    try {
      service.resetAllBlocStates();
      print('✅ All BLoCs reset successfully');
    } catch (e) {
      print('❌ Reset failed: $e');
    }
  }
  
  /// Monitor registration/unregistration
  static void monitorRegistrations() {
    final service = sl<BlocStateCleanupService>();
    
    Timer.periodic(Duration(seconds: 5), (timer) {
      print('Registered BLoCs: ${service.registeredCount}');
    });
  }
}
```

## Prevention Checklist

### Before Adding New BLoCs

- [ ] **Determine if BLoC handles user data** - If yes, implement cleanup
- [ ] **Choose implementation approach** - Prefer `ResetableBlocMixin`
- [ ] **Plan initial state** - Should be clean and user-agnostic
- [ ] **Consider subscriptions** - Plan cancellation strategy
- [ ] **Write tests** - Include reset functionality tests

### Code Review Checklist

- [ ] **Registration present** - `registerForCleanup()` called
- [ ] **Initial state clean** - No user-specific data
- [ ] **Subscriptions handled** - Cancelled in reset/close
- [ ] **Error handling** - Try-catch in cleanup methods
- [ ] **Tests included** - Reset functionality tested
- [ ] **Performance considered** - No heavy operations in reset

### Release Checklist

- [ ] **Test with multiple users** - No data leakage between sessions
- [ ] **Test automatic logout** - Token expiration scenarios
- [ ] **Test manual logout** - Button-triggered logout
- [ ] **Performance test** - Logout completes in < 2 seconds
- [ ] **Memory test** - No memory leaks after multiple cycles
- [ ] **Error test** - App handles cleanup errors gracefully

## Emergency Fixes

### Quick Fix: Disable Problematic BLoC

If a specific BLoC is causing issues:

```dart
@override
void reset() {
  try {
    // Your reset logic
    super.reset();
  } catch (e) {
    // Log error but don't crash app
    AppLogger.error('Reset failed for ${runtimeType}: $e');
  }
}
```

### Quick Fix: Skip Cleanup for Specific BLoC

Temporarily remove from cleanup:

```dart
// Comment out registration until fixed
// registerForCleanup();
```

### Quick Fix: Force Full App Restart

As last resort, force app restart on logout:

```dart
// In logout method
void forceAppRestart() {
  SystemNavigator.pop(); // Close app
  // User must manually restart
}
```

## Getting Help

### Common Commands

```bash
# Search for BLoCs missing cleanup
grep -r "extends Bloc" lib/ | grep -v "ResetableBlocMixin"

# Find BLoCs with manual registration
grep -r "registerResetable" lib/

# Check for subscription leaks
grep -r "StreamSubscription" lib/
```

### Debug Information to Collect

When reporting issues, include:

1. **BLoC implementation** - Show the problematic BLoC code
2. **Registration status** - Number of registered BLoCs
3. **Error logs** - Full stack trace if crashing
4. **Steps to reproduce** - Exact login/logout sequence
5. **App state** - What data was loaded before logout

### Contact Information

- Architecture Team: For pattern questions
- QA Team: For testing scenarios
- DevOps Team: For production issues