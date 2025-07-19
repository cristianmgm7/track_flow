# Authentication & Onboarding Flow Refactoring Plan

## 🔍 **Current State Diagnosis**

### **Problem Analysis**

The current authentication and onboarding flow has several architectural and logical issues:

#### **1. Incorrect Flow Order**

- **Current Flow**: `Splash → Welcome → Onboarding → Auth → Dashboard`
- **Problem**: Onboarding happens BEFORE authentication, which is logically incorrect
- **Expected Flow**: `Splash → Welcome → Auth → Onboarding → Profile Creation → Dashboard`

#### **2. Profile Creation Logic Issues**

- **Location**: Profile creation is handled in `AuthRepositoryImpl._createOrSyncUserProfile()`
- **Problem**: This creates a basic profile automatically during sign-up/sign-in
- **Issue**: Users don't get a proper onboarding experience to set up their profile
- **Conflict**: The new `ProfileCreationScreen` exists but isn't properly integrated into the flow

#### **3. State Management Confusion**

- **AuthBloc**: Handles both authentication AND onboarding states
- **Problem**: Mixing concerns - authentication and onboarding should be separate
- **Issue**: Onboarding states (`OnboardingInitial`, `WelcomeScreenInitial`) are in `AuthState`

#### **4. Routing Logic Problems**

- **AppRouter**: Redirects based on auth state but doesn't consider profile completeness
- **Problem**: Users can reach dashboard without completing profile setup
- **Issue**: Profile creation check happens in `MainScaffold` instead of router level

#### **5. Data Consistency Issues**

- **Profile Storage**: Profiles exist in Firestore but may not be cached locally
- **Problem**: `_createOrSyncUserProfile()` has error handling that continues auth even if profile creation fails
- **Issue**: Silent failures in profile caching lead to inconsistent state

## 🎯 **Proposed Solution Architecture**

### **New Flow Design**

```
Splash Screen
    ↓
Welcome Screen (First time users only)
    ↓
Authentication (Login/Signup)
    ↓
Onboarding Check
    ↓
Profile Creation (If needed)
    ↓
Main Dashboard
```

### **State Management Refactoring**

#### **1. Separate Auth and Onboarding Concerns**

```dart
// AuthBloc - Only handles authentication
abstract class AuthState {
  AuthInitial, AuthLoading, AuthAuthenticated, AuthUnauthenticated, AuthError
}

// OnboardingBloc - Handles onboarding flow
abstract class OnboardingState {
  OnboardingInitial, OnboardingLoading, OnboardingCompleted, OnboardingIncomplete
}

// UserProfileBloc - Handles profile management
abstract class UserProfileState {
  ProfileInitial, ProfileLoading, ProfileComplete, ProfileIncomplete, ProfileError
}
```

#### **2. Router-Level Flow Control**

```dart
// AppRouter redirect logic
redirect: (context, state) {
  final authState = authBloc.state;
  final onboardingState = onboardingBloc.state;
  final profileState = userProfileBloc.state;

  if (authState is AuthUnauthenticated) return AppRoutes.auth;
  if (authState is AuthAuthenticated && onboardingState is OnboardingIncomplete) {
    return AppRoutes.onboarding;
  }
  if (authState is AuthAuthenticated && profileState is ProfileIncomplete) {
    return AppRoutes.profileCreation;
  }
  return null;
}
```

## 📋 **Implementation Plan**

### **Phase 1: State Management Refactoring**

#### **1.1 Create OnboardingBloc**

```dart
// lib/features/onboarding/presentation/bloc/onboarding_bloc.dart
@injectable
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingRepository _onboardingRepository;
  final WelcomeScreenRepository _welcomeScreenRepository;

  // Events: CheckOnboarding, MarkOnboardingCompleted, MarkWelcomeSeen
  // States: OnboardingInitial, OnboardingLoading, OnboardingCompleted, OnboardingIncomplete
}
```

#### **1.2 Refactor AuthBloc**

```dart
// Remove onboarding-related events and states from AuthBloc
// Keep only: AuthCheckRequested, AuthSignInRequested, AuthSignUpRequested, AuthSignOutRequested, AuthGoogleSignInRequested
```

#### **1.3 Update UserProfileBloc**

```dart
// Add profile completeness check
class CheckProfileCompleteness extends UserProfileEvent {}
class ProfileComplete extends UserProfileState {}
class ProfileIncomplete extends UserProfileState {}
```

### **Phase 2: Router and Navigation Refactoring**

#### **2.1 Update AppRouter**

```dart
// Add proper flow control with multiple BLoC states
class AppRouter {
  static GoRouter router(
    AuthBloc authBloc,
    OnboardingBloc onboardingBloc,
    UserProfileBloc userProfileBloc,
  ) {
    return GoRouter(
      redirect: (context, state) {
        // Implement proper flow logic
      },
      routes: [
        // Update route structure
      ],
    );
  }
}
```

#### **2.2 Remove Profile Check from MainScaffold**

```dart
// Remove _checkProfileCompleteness() from MainScaffold
// This should be handled at router level
```

### **Phase 3: Profile Creation Integration**

#### **3.1 Update AuthRepositoryImpl**

```dart
// Remove automatic profile creation from _createOrSyncUserProfile()
// Only sync existing profiles, don't create new ones
Future<void> _syncUserProfile(User user) async {
  // Only sync if profile exists, don't create
}
```

#### **3.2 Enhance ProfileCreationScreen**

```dart
// Add proper integration with the new flow
// Ensure it's called after authentication but before dashboard
```

### **Phase 4: Data Layer Improvements**

#### **4.1 Fix Profile Caching Issues**

```dart
// Ensure proper error handling in UserProfileLocalDataSource
// Add retry mechanisms for failed cache operations
```

#### **4.2 Add Profile Completeness Validation**

```dart
// Create ProfileCompletenessValidator
class ProfileCompletenessValidator {
  static bool isComplete(UserProfile profile) {
    return profile.name.isNotEmpty &&
           profile.creativeRole != null &&
           profile.name != 'No Name';
  }
}
```

## 🔧 **Technical Implementation Details**

### **File Structure Changes**

```
lib/
├── features/
│   ├── auth/
│   │   ├── presentation/bloc/
│   │   │   ├── auth_bloc.dart (REFACTOR - remove onboarding)
│   │   │   ├── auth_event.dart (REFACTOR - remove onboarding events)
│   │   │   └── auth_state.dart (REFACTOR - remove onboarding states)
│   │   └── data/repositories/
│   │       └── auth_repository_impl.dart (REFACTOR - remove profile creation)
│   ├── onboarding/ (NEW FEATURE)
│   │   ├── presentation/bloc/
│   │   │   ├── onboarding_bloc.dart (NEW)
│   │   │   ├── onboarding_event.dart (NEW)
│   │   │   └── onboarding_state.dart (NEW)
│   │   └── presentation/screens/
│   │       └── onboarding_screen.dart (MOVE from auth)
│   └── user_profile/
│       ├── presentation/bloc/
│       │   ├── user_profile_bloc.dart (ENHANCE - add completeness check)
│       │   ├── user_profile_event.dart (ENHANCE - add completeness events)
│       │   └── user_profile_states.dart (ENHANCE - add completeness states)
│       └── domain/
│           └── validators/
│               └── profile_completeness_validator.dart (NEW)
└── core/
    └── router/
        └── app_router.dart (REFACTOR - new flow logic)
```

### **Dependency Injection Updates**

```dart
// lib/core/di/app_module.dart
@module
abstract class AppModule {
  // Add OnboardingBloc
  @lazySingleton
  OnboardingBloc get onboardingBloc => OnboardingBloc(
    onboardingRepository: onboardingRepository,
    welcomeScreenRepository: welcomeScreenRepository,
  );

  // Update AppRouter to include all required BLoCs
  @factoryMethod
  GoRouter get appRouter => AppRouter.router(
    authBloc: authBloc,
    onboardingBloc: onboardingBloc,
    userProfileBloc: userProfileBloc,
  );
}
```

### **Migration Strategy**

#### **Step 1: Create New Onboarding Feature**

1. Create `OnboardingBloc` with proper events and states
2. Move onboarding logic from `AuthBloc`
3. Update `OnboardingScreen` to use new BLoC

#### **Step 2: Refactor AuthBloc**

1. Remove onboarding-related code
2. Keep only authentication logic
3. Update tests and dependencies

#### **Step 3: Update Router Logic**

1. Implement new flow control in `AppRouter`
2. Add proper state checking for all BLoCs
3. Test navigation flow

#### **Step 4: Integrate Profile Creation**

1. Update `AuthRepositoryImpl` to remove automatic profile creation
2. Ensure `ProfileCreationScreen` is properly called in flow
3. Add profile completeness validation

#### **Step 5: Data Layer Fixes**

1. Fix profile caching issues
2. Add proper error handling
3. Implement retry mechanisms

## 🧪 **Testing Strategy**

### **Unit Tests**

- Test each BLoC independently
- Test new flow logic in router
- Test profile completeness validation

### **Integration Tests**

- Test complete user flow from signup to dashboard
- Test offline scenarios
- Test profile creation flow

### **E2E Tests**

- Test complete onboarding flow
- Test profile creation and validation
- Test navigation between screens

## 📊 **Success Metrics**

### **User Experience**

- ✅ Users complete proper onboarding flow
- ✅ Profile creation is mandatory for new users
- ✅ No users reach dashboard without complete profile

### **Technical Quality**

- ✅ Clean separation of concerns
- ✅ Proper error handling
- ✅ Consistent data state
- ✅ Testable architecture

### **Performance**

- ✅ Faster app startup (no unnecessary profile checks)
- ✅ Better offline handling
- ✅ Reduced complexity in auth flow

## 🚀 **Implementation Timeline**

### **Week 1: Foundation**

- Create OnboardingBloc and related files
- Refactor AuthBloc to remove onboarding logic
- Update dependency injection

### **Week 2: Router and Navigation**

- Implement new router logic
- Update navigation flow
- Test basic routing

### **Week 3: Profile Integration**

- Update AuthRepositoryImpl
- Integrate ProfileCreationScreen
- Add profile completeness validation

### **Week 4: Testing and Polish**

- Write comprehensive tests
- Fix any issues found
- Performance optimization

## ⚠️ **Risks and Mitigation**

### **Risk 1: Breaking Existing Users**

- **Mitigation**: Implement feature flags to gradually roll out changes
- **Backup**: Keep old flow as fallback during transition

### **Risk 2: Data Migration**

- **Mitigation**: Ensure existing profiles are properly migrated
- **Backup**: Add data validation and recovery mechanisms

### **Risk 3: Complex State Management**

- **Mitigation**: Thorough testing of all state combinations
- **Backup**: Add comprehensive logging for debugging

## 📝 **Conclusion**

This refactoring plan addresses the core architectural issues in the current authentication and onboarding flow. By separating concerns, implementing proper flow control, and ensuring data consistency, we'll create a more maintainable and user-friendly experience.

The key benefits include:

- **Logical Flow**: Authentication → Onboarding → Profile Creation → Dashboard
- **Clean Architecture**: Separated concerns with dedicated BLoCs
- **Better UX**: Proper onboarding experience for new users
- **Maintainability**: Easier to test and extend
- **Data Consistency**: Reliable profile management

The implementation should be done incrementally with proper testing at each phase to ensure a smooth transition.
