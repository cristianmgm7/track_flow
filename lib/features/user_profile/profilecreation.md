# User Profile Creation Experience Implementation Plan

## **Goal**: Create a complete onboarding flow for new users to set up their profiles

## **Current Issue Analysis**
1. **Root Cause**: User profile exists in Firestore but NOT in local Isar database
2. **Gap**: No onboarding flow for new users to create their profile
3. **Technical Issue**: `cacheUserProfile()` in `user_profile_local_datasource.dart:31` is failing silently

## **Proposed Solution: Complete Profile Creation Flow**

### **User Experience Flow**
```
New User Signs Up/In → Profile Check → Profile Creation Screen → Main App
                         ↓
                   [If no profile exists locally]
```

## **Implementation Phases**

### **Phase 1: Profile Creation Screen**
- Create `/profile/create` route and screen
- Build form with name, creative role, and avatar fields
- Implement modern, welcoming UI design using `@lib/core/theme/`

### **Phase 2: Navigation & Routing Logic**
- Add profile completeness check in auth flow
- Redirect new users to profile creation screen
- Add route guards to prevent main app access until profile is complete

### **Phase 3: Data Persistence Fixes**
- Fix local database caching issues in profile creation
- Ensure profiles are saved both remotely AND locally
- Add proper error handling and retry mechanisms

### **Phase 4: Enhanced UX**
- Add avatar upload functionality
- Implement form validation with real-time feedback
- Add success animations and welcome messages

## **Technical Components**

### **New Components Needed:**
- `ProfileCreationScreen` - Main onboarding screen
- `ProfileCreationForm` - Form component with validation
- `CreativeRoleSelector` - Role selection widget
- `AvatarUploader` - Avatar upload widget

### **Updated Logic:**
- `AuthBloc` - Add profile completeness check
- `UserProfileBloc` - Add profile creation events
- `AppRouter` - Add profile creation route and guards

### **File Structure Changes:**
```
lib/features/user_profile/
├── presentation/
│   ├── screens/
│   │   └── profile_creation_screen.dart (NEW)
│   ├── components/
│   │   ├── profile_creation_form.dart (NEW)
│   │   ├── creative_role_selector.dart (NEW)
│   │   └── avatar_uploader.dart (NEW)
│   └── bloc/
│       ├── user_profile_event.dart (UPDATE)
│       └── user_profile_states.dart (UPDATE)
```

## **Expected Outcomes**
This implementation will:
✅ Fix the immediate issue of missing local profiles
✅ Provide a better user experience for new users
✅ Ensure data consistency between remote and local storage
✅ Create a foundation for future profile features

## **Next Steps**
1. Implement `ProfileCreationScreen` with form validation
2. Add new route to `AppRoutes` and router configuration
3. Update `AuthBloc` to check profile completeness
4. Fix local caching issues in `user_profile_local_datasource.dart`
5. Test complete flow end-to-end