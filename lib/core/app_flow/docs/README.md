# BLoC State Cleanup Pattern Documentation

## 📚 **Documentation Overview**

This folder contains comprehensive documentation for the BLoC State Cleanup Pattern implemented in TrackFlow. This pattern ensures complete session isolation by automatically resetting BLoC states during user logout.

## 🎯 **Quick Start**

For developers who need to implement this pattern immediately:

1. **Start Here**: [Integration Checklist](./bloc_cleanup_checklist.md) - Quick setup steps
2. **Copy Examples**: [Practical Examples](./bloc_cleanup_examples.dart) - Ready-to-use code templates
3. **Need Help?**: [Troubleshooting Guide](./bloc_cleanup_troubleshooting.md) - Common issues and solutions

## 📖 **Documentation Structure**

### 1. [Main Pattern Documentation](./bloc_state_cleanup_pattern.md)
**Comprehensive guide covering:**
- Architecture overview and benefits
- Implementation approaches (mixin vs manual)
- Integration guidelines and best practices
- Testing strategies and migration guide

**Read this if:** You want to understand the complete pattern and architecture

### 2. [Practical Examples](./bloc_cleanup_examples.dart)
**Copy-paste ready code for:**
- Simple BLoCs with basic state
- Complex BLoCs with subscriptions
- Cubits with manual implementation
- Custom state objects and conditional resets
- Testing helpers and templates

**Use this when:** You're implementing the pattern in a new or existing BLoC

### 3. [Integration Checklist](./bloc_cleanup_checklist.md)
**Step-by-step guides for:**
- New BLoC setup (5-minute checklist)
- Existing BLoC migration
- Verification and testing steps
- Performance optimization tips

**Use this when:** You need a quick reference for implementation steps

### 4. [Troubleshooting Guide](./bloc_cleanup_troubleshooting.md)
**Solutions for common issues:**
- BLoC state persistence after logout
- App crashes during cleanup
- Memory leaks and performance problems
- Debugging tools and emergency fixes

**Use this when:** You're experiencing issues with the cleanup pattern

## 🚀 **5-Minute Quick Setup**

### For New BLoCs:

```dart
// 1. Import the mixin
import 'package:trackflow/core/common/mixins/resetable_bloc_mixin.dart';

// 2. Add mixin to your BLoC
class MyBloc extends Bloc<MyEvent, MyState>
    with ResetableBlocMixin<MyEvent, MyState> {
  
  // 3. Register in constructor
  MyBloc() : super(MyInitial()) {
    on<MyEvent>(_onMyEvent);
    registerForCleanup(); // Add this line
  }

  // 4. Define initial state
  @override
  MyState get initialState => MyInitial();
}
```

### For Existing BLoCs:

1. Check if BLoC handles user-specific data → [Categories Guide](./bloc_cleanup_checklist.md#bloc-categories)
2. Add the mixin → [Migration Steps](./bloc_cleanup_checklist.md#-for-existing-blocs)
3. Test the implementation → [Verification Steps](./bloc_cleanup_checklist.md#-verification-steps)

## 🏗️ **Architecture Overview**

```
User Logout Trigger
        ↓
SessionCleanupService
        ↓
┌─────────────────────┬─────────────────────┐
│ BlocStateCleanupService  │  Repository Cleanup  │
│ (Reset BLoC States)      │  (Clear Data Cache)  │
└─────────────────────┴─────────────────────┘
        ↓                           ↓
┌─────────────────────┐    ┌─────────────────────┐
│ UserProfileBloc     │    │ Clear Isar DBs      │
│ NavigationCubit     │    │ Clear Firebase Cache│
│ ProjectsBloc        │    │ Clear Preferences   │
│ [Other BLoCs...]    │    │ Clear Audio Cache   │
└─────────────────────┘    └─────────────────────┘
```

## 🎨 **Core Components**

### Interfaces & Mixins
- [`Resetable`](../../../core/common/interfaces/resetable.dart) - Core interface for resetable components
- [`ResetableBlocMixin`](../../../core/common/mixins/resetable_bloc_mixin.dart) - Convenient mixin for BLoCs

### Services  
- [`BlocStateCleanupService`](../services/bloc_state_cleanup_service.dart) - Manages all resetable BLoCs
- [`SessionCleanupService`](../services/session_cleanup_service.dart) - Coordinates complete cleanup

### Implementation Examples
- [`UserProfileBloc`](../../../features/user_profile/presentation/bloc/user_profile_bloc.dart) - Real implementation with mixin
- [`NavigationCubit`](../../../features/navegation/presentation/cubit/navigation_cubit.dart) - Manual implementation example

## 🧪 **Testing**

### Quick Test
```dart
void main() {
  test('BLoC should reset to initial state', () {
    final bloc = MyBloc();
    bloc.emit(NonInitialState());
    
    bloc.reset();
    
    expect(bloc.state, isA<MyInitial>());
  });
}
```

### Complete Test Suite
See [Testing Section](./bloc_state_cleanup_pattern.md#testing) in the main documentation.

## 🔧 **Debugging**

### Quick Debug Commands
```dart
// Check registration status
final service = sl<BlocStateCleanupService>();
print('Registered BLoCs: ${service.registeredCount}');

// Test individual reset
final bloc = sl<UserProfileBloc>();
bloc.reset();
print('Reset completed for: ${bloc.runtimeType}');
```

### Enable Debug Logging
```dart
// In main.dart
if (kDebugMode) {
  AppLogger.enableTag('BLOC_STATE_CLEANUP');
}
```

## 📊 **Performance**

- **BLoC Reset**: < 1ms per BLoC (synchronous)
- **Total Cleanup**: < 100ms for typical app (includes repository cleanup)
- **Memory Impact**: Minimal - automatic registration/unregistration
- **Scalability**: Linear with number of BLoCs

## 🔄 **Migration Status**

### ✅ **Completed**
- UserProfileBloc  
- NavigationCubit
- SessionCleanupService integration

### 🟡 **In Progress**
- ProjectsBloc
- AudioTrackBloc  
- AudioCommentBloc

### 📋 **Planned**
- OnboardingBloc
- SettingsBloc
- NotificationBloc

See [Migration Timeline](./bloc_cleanup_checklist.md#migration-timeline) for details.

## 🆘 **Need Help?**

### Common Questions
- **"Should my BLoC implement cleanup?"** → [BLoC Categories Guide](./bloc_cleanup_checklist.md#bloc-categories)
- **"How do I migrate existing BLoC?"** → [Migration Steps](./bloc_cleanup_checklist.md#-for-existing-blocs)
- **"BLoC not resetting?"** → [Troubleshooting Guide](./bloc_cleanup_troubleshooting.md#-issue-bloc-state-persists-after-logout)

### Quick References
- [5-minute setup checklist](./bloc_cleanup_checklist.md#-for-new-blocs)
- [Copy-paste templates](./bloc_cleanup_examples.dart#copy-paste-templates)
- [Debug commands](./bloc_cleanup_troubleshooting.md#quick-diagnostic-commands)

### Contact
- **Architecture Questions**: Review main documentation
- **Implementation Help**: Use practical examples  
- **Issues/Bugs**: Follow troubleshooting guide

## 📝 **Contributing**

When adding new documentation:

1. **Keep examples practical** - Focus on copy-paste ready code
2. **Update this README** - Add new files to the structure
3. **Cross-reference** - Link related sections
4. **Test examples** - Ensure all code compiles and works

## 🔗 **Related Documentation**

- [Clean Architecture Guidelines](../../../README.md)
- [BLoC Pattern Best Practices](../../../core/README.md)
- [Session Management](../README.md)
- [Testing Guidelines](../../../test/README.md)