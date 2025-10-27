# User Profile Enhancement Implementation Plan

## Overview

Expand TrackFlow's user profile system to support rich professional profiles with social media integration, detailed bios, and preview functionality. Fix two critical navigation bugs affecting collaborator views.

## Current State

**Entity Fields**: name, email, avatarUrl, avatarLocalPath, createdAt, updatedAt, creativeRole
**Edit Flow**: Settings → Edit Profile Dialog (modal)
**Bugs**:
1. Manage collaborators screen shows white/blank on initial load
2. Collaborator card navigation issue (needs verification)

## Desired End State

**Enhanced Entity**: Add description, location, social links, website, contact info, verification badge, roles/genres/skills lists
**New Edit Flow**: Settings → Full-Screen Profile Editor → Preview Bottom Sheet
**Profile Preview**: Users can see how others view their profile
**Fixed Bugs**: Both navigation issues resolved
**Clickable Links**: Social media and external links open in browser/native apps

## What We're NOT Doing

- Followers/following system (Phase 3)
- Project credits linking to app projects (external credits only for now)
- In-app social features (comments, likes on profiles)
- Profile analytics or views tracking

## Phase 1: Bug Fixes & Foundation

### Task 1.1: Fix Manage Collaborators White Screen

**File**: `lib/features/manage_collaborators/presentation/screens/manage_collaborators_screen.dart`

**Changes**: Update builder at lines 135-139 to show loading indicator:

```dart
} else {
  // Fallback - show loading for initial state
  currentProject = widget.project;
  currentCollaborators = [];
  isLoading = true;  // Add this flag
}
```

Add loading UI in Stack after ListView (line 146):

```dart
// Show loading when no data yet
if (currentCollaborators.isEmpty && isLoading)
  Center(
    child: CircularProgressIndicator(color: AppColors.primary),
  ),
```

**Success Criteria**:
- [ ] Screen shows loading spinner instead of white screen
- [ ] Test: Navigate to manage collaborators → see loading → see data
- [ ] No more blank screen on first load

### Task 1.2: Verify Collaborator Card Navigation

**File**: `lib/features/project_detail/presentation/components/collaborator_card.dart:45-46`

**Investigation**: Test if navigation works. If broken, check:
- BLoC providers in `app_bloc_providers.dart:147-152`
- Route registration in `app_router.dart:169-179`

**Success Criteria**:
- [ ] Tapping collaborator card navigates to profile
- [ ] Profile screen loads user data correctly
- [ ] Back navigation returns to project detail

### Task 1.3: Expand Domain Entity

**File**: `lib/features/user_profile/domain/entities/user_profile.dart`

**Add fields**:

```dart
// Professional context
final String? description;
final String? location;
final List<String>? roles;
final List<String>? genres;
final List<String>? skills;
final String? availabilityStatus;

// External links
final List<SocialLink>? socialLinks;
final String? websiteUrl;
final String? linktreeUrl;

// Contact (display only)
final ContactInfo? contactInfo;

// Meta
final bool verified;
```

**Add value objects** in same file:

```dart
class ContactInfo extends Equatable {
  final String? phone;
  const ContactInfo({this.phone});
  @override
  List<Object?> get props => [phone];
}

class SocialLink extends Equatable {
  final String platform; // instagram, twitter, spotify, etc
  final String url;
  const SocialLink({required this.platform, required this.url});
  @override
  List<Object?> get props => [platform, url];
}
```

**Update copyWith** to include all new fields.

**Success Criteria**:
- [ ] Entity compiles with new fields
- [ ] copyWith includes all fields
- [ ] All fields are nullable (migration safe)

### Task 1.4: Update DTO Layer

**File**: `lib/features/user_profile/data/models/user_profile_dto.dart`

**Add fields** (lines 5-31) and update:
- `fromDomain()` factory (lines 35-51)
- `toDomain()` method (lines 53-64)
- `toJson()` method (lines 99-112)
- `fromJson()` factory (lines 66-97)
- `copyWith()` method (lines 114-139)

**JSON serialization** for social links:

```dart
'socialLinks': socialLinks?.map((l) => {
  'platform': l.platform,
  'url': l.url,
}).toList(),
```

**Success Criteria**:
- [ ] DTO serializes/deserializes all fields
- [ ] Tests pass: `flutter test test/features/user_profile/data/models/`
- [ ] No Firebase serialization errors

### Task 1.5: Update Document Layer

**File**: `lib/features/user_profile/data/models/user_profile_document.dart`

**Add Isar fields** with appropriate annotations:

```dart
late String? description;
late String? location;
late List<String>? roles;
late List<String>? genres;
late String? websiteUrl;
late String? linktreeUrl;
late bool verified;

@Embedded(propertyName: 'social_links')
late List<SocialLinkDocument>? socialLinks;

@Embedded(propertyName: 'contact_info')
late ContactInfoDocument? contactInfo;
```

**Add embedded classes**:

```dart
@embedded
class SocialLinkDocument {
  late String platform;
  late String url;
}

@embedded
class ContactInfoDocument {
  String? phone;
}
```

Update `fromDTO()`, `toDTO()`, `fromRemoteDTO()`, `forLocalUpdate()` factories.

**Success Criteria**:
- [ ] Run: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- [ ] No Isar generation errors
- [ ] Document persists to local DB correctly

### Task 1.6: Update UI Model

**File**: `lib/features/user_profile/presentation/models/user_profile_ui_model.dart`

**Add unwrapped fields** and update:
- Constructor
- `fromDomain()` factory
- `props` getter

**Success Criteria**:
- [ ] UI model includes all new fields as primitives
- [ ] BLoC states compare correctly

## Phase 2: Full-Screen Profile Editor

### Task 2.1: Create Full-Screen Edit Profile Screen

**File**: `lib/features/user_profile/presentation/screens/edit_user_profile_screen.dart` (NEW)

**Pattern**: Follow `profile_creation_screen.dart` structure

```dart
class EditUserProfileScreen extends StatefulWidget {
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(
        title: 'Edit Profile',
        actions: [
          TextButton(
            onPressed: _showPreview,
            child: Text('Preview'),
          ),
        ],
      ),
      body: BlocListener<CurrentUserBloc, CurrentUserState>(
        listener: _handleBlocState,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: EditProfileForm(
            key: _formKey,
            initialProfile: widget.profile,
            onSubmit: _handleSubmit,
            isLoading: _isLoading,
          ),
        ),
      ),
    );
  }
}
```

**Success Criteria**:
- [ ] Screen renders with existing profile data
- [ ] AppBar has Preview button
- [ ] Save button submits form
- [ ] Loading state disables form

### Task 2.2: Create Edit Profile Form Component

**File**: `lib/features/user_profile/presentation/components/edit_profile_form.dart` (NEW)

**Sections**:

1. **Basic Info Card**: Avatar, Name, Email (read-only)
2. **About Card**: Description (multiline), Location
3. **Professional Card**: Roles, Genres, Skills (chip selectors)
4. **Links Card**: Social links, Website, Linktree
5. **Contact Card**: Phone (optional)

**Form fields**:

```dart
// Description
AppFormField(
  label: 'Bio',
  hint: 'Tell collaborators about yourself...',
  controller: _descriptionController,
  maxLines: 4,
  maxLength: 500,
),

// Location
AppFormField(
  label: 'Location',
  hint: 'City, Country',
  controller: _locationController,
  prefixIcon: Icons.location_on,
),
```

**Success Criteria**:
- [ ] All Phase 1 fields have inputs
- [ ] Form validates required fields
- [ ] Controllers initialized with existing data
- [ ] Submit creates updated UserProfile entity

### Task 2.3: Create Social Links Editor Widget

**File**: `lib/features/user_profile/presentation/widgets/social_links_editor.dart` (NEW)

**UI**: List of social link entries with add/remove buttons

```dart
class SocialLinksEditor extends StatefulWidget {
  final List<SocialLink>? initialLinks;
  final ValueChanged<List<SocialLink>> onChanged;

  // Predefined platforms: Instagram, Twitter, Spotify, SoundCloud, YouTube, TikTok
  // Each row: Platform dropdown + URL TextField + Remove button
}
```

**Validation**: URLs must be valid HTTP/HTTPS

**Success Criteria**:
- [ ] Add new social link button works
- [ ] Remove link button works
- [ ] URL validation prevents invalid links
- [ ] Platform selection from predefined list

### Task 2.4: Create Multi-Select Chip Widget

**File**: `lib/features/user_profile/presentation/widgets/multi_select_chips.dart` (NEW)

**Pattern**: Extend `creative_role_selector.dart` for multiple selections

```dart
class MultiSelectChips extends StatefulWidget {
  final List<String> predefinedOptions;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;
  final bool allowCustom;
  final String? customPlaceholder;
}
```

**Use cases**: Roles, Genres, Skills

**Success Criteria**:
- [ ] Can select multiple chips
- [ ] Selected chips show primary color
- [ ] Custom input field appears if allowCustom
- [ ] Returns list of selected strings

### Task 2.5: Update Settings Navigation

**File**: `lib/features/settings/presentation/widgets/user_profile_section.dart`

**Change navigation** at line 39:

```dart
// OLD: onTap: () => context.push(AppRoutes.userProfile),
// NEW:
onTap: () {
  final profile = (context.read<CurrentUserBloc>().state as CurrentUserLoaded).profile;
  context.push(AppRoutes.editUserProfile, extra: profile);
},
```

**Success Criteria**:
- [ ] Tapping Profile navigates to full-screen editor
- [ ] Profile data passed via route extra
- [ ] Back button returns to settings

### Task 2.6: Add Route Configuration

**File**: `lib/core/router/app_router.dart`

**Add route** in shell routes section:

```dart
GoRoute(
  path: AppRoutes.editUserProfile,
  builder: (context, state) {
    final profile = state.extra as UserProfile;
    return EditUserProfileScreen(profile: profile);
  },
),
```

**File**: `lib/core/router/app_routes.dart`

```dart
static const String editUserProfile = '/profile/edit';
```

**Success Criteria**:
- [ ] Route registered correctly
- [ ] Navigation works from settings
- [ ] Profile data available in screen

## Phase 3: Profile Preview

### Task 3.1: Create Preview Bottom Sheet

**File**: `lib/features/user_profile/presentation/widgets/profile_preview_sheet.dart` (NEW)

**Pattern**: Use `showAppFormSheet` helper

```dart
void showProfilePreview(BuildContext context, UserProfile profile) {
  showAppFormSheet(
    context: context,
    title: 'Profile Preview',
    initialChildSize: 0.9,
    maxChildSize: 0.95,
    child: ProfilePreviewContent(profile: profile),
  );
}

class ProfilePreviewContent extends StatelessWidget {
  final UserProfile profile;

  // Render exactly like collaborator_profile_screen.dart
  // Shows: Header with avatar, Bio, Location, Roles, Social Links
}
```

**Success Criteria**:
- [ ] Preview button opens bottom sheet
- [ ] Shows profile as others see it
- [ ] Social links are clickable
- [ ] Close button dismisses sheet

### Task 3.2: Create Clickable Social Links Widget

**File**: `lib/features/user_profile/presentation/widgets/social_links_display.dart` (NEW)

**UI**: Row of social media icons with platform branding

```dart
class SocialLinksDisplay extends StatelessWidget {
  final List<SocialLink> socialLinks;

  // Icons: FontAwesome or custom assets
  // Tap: url_launcher package to open links

  void _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
```

**Dependency**: Add `url_launcher: ^6.2.0` to `pubspec.yaml`

**Success Criteria**:
- [ ] Social icons render with correct branding
- [ ] Tapping icon opens external browser/app
- [ ] Invalid URLs show error snackbar
- [ ] No confirmation dialog (direct open)

### Task 3.3: Update Collaborator Profile Screen

**File**: `lib/features/user_profile/presentation/screens/collaborator_profile_screen.dart`

**Add to _InfoSection** (line 156-197):

```dart
// After roles
if (profile.description != null) ...[
  SizedBox(height: 16),
  Text('About', style: AppTextStyle.titleMedium),
  SizedBox(height: 8),
  Text(profile.description!, style: AppTextStyle.bodyMedium),
],

if (profile.socialLinks != null && profile.socialLinks!.isNotEmpty) ...[
  SizedBox(height: 16),
  SocialLinksDisplay(socialLinks: profile.socialLinks!),
],
```

**Success Criteria**:
- [ ] Bio displays when available
- [ ] Social links render and work
- [ ] Layout matches preview sheet
- [ ] No data shows gracefully (empty state)

## Phase 4: Data Persistence & Sync

### Task 4.1: Update Remote Datasource

**File**: `lib/features/user_profile/data/datasources/user_profile_remote_datasource.dart`

**No changes needed** - Firestore automatically handles new fields via DTO `toJson()`

**Test**: Verify new fields save to Firestore collection

**Success Criteria**:
- [ ] New profile fields appear in Firestore console
- [ ] Social links array serializes correctly
- [ ] No Firestore write errors

### Task 4.2: Update Local Datasource

**File**: `lib/features/user_profile/data/datasources/user_profile_local_datasource.dart`

**No changes needed** - Isar handles new fields after code generation

**Test**: Verify new fields persist to local DB

**Success Criteria**:
- [ ] Local profiles include new fields
- [ ] Query profiles by new fields (optional)
- [ ] No Isar write errors

### Task 4.3: Test Repository Layer

**File**: `lib/features/user_profile/data/repositories/user_profile_repository_impl.dart`

**No changes needed** - Repository uses DTO/Document transformations

**Test full flow**:
1. Edit profile with new fields
2. Save via `updateUserProfile()`
3. Verify local cache updated
4. Verify Firebase synced
5. Watch stream emits updated profile

**Success Criteria**:
- [ ] Profile updates save locally
- [ ] Profile updates sync to Firebase
- [ ] Watch stream emits new data
- [ ] Offline mode works (local-first)

## Phase 5: UI Polish & Validation

### Task 5.1: Add URL Validation

**File**: `lib/features/user_profile/domain/validators/url_validator.dart` (NEW)

```dart
class UrlValidator {
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.host.contains('.')) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  static String? validateSocialUrl(String platform, String? url) {
    // Platform-specific validation (Instagram: instagram.com, etc)
  }
}
```

**Success Criteria**:
- [ ] Invalid URLs show error
- [ ] Valid URLs pass validation
- [ ] Platform-specific validation works

### Task 5.2: Add Profile Completeness Indicator

**File**: `lib/features/user_profile/presentation/components/profile_completeness_widget.dart` (NEW)

**UI**: Progress bar showing profile completion percentage

```dart
// 100% = All Phase 1 fields filled
// Basic: Name, Email, Avatar = 30%
// + Bio, Location = 60%
// + Social Links = 80%
// + Roles/Genres = 100%
```

**Success Criteria**:
- [ ] Progress bar shows correct percentage
- [ ] Displays in edit screen header
- [ ] Updates live as fields filled

### Task 5.3: Add Empty States

**File**: `lib/features/user_profile/presentation/widgets/empty_profile_state.dart` (NEW)

**Use cases**:
- No social links added yet
- No bio written yet
- Viewing collaborator with minimal profile

**UI**: Friendly message with action button

**Success Criteria**:
- [ ] Empty states show helpful text
- [ ] "Add Bio" button navigates to edit
- [ ] No awkward blank sections

## Testing Strategy

### Unit Tests

**Files to test**:
- `user_profile.dart` entity (copyWith, equality)
- `user_profile_dto.dart` (JSON serialization)
- `url_validator.dart` (validation logic)

**Run**: `flutter test test/features/user_profile/domain/`

### Integration Tests

**Scenarios**:
1. Create profile with social links → verify saved to Firestore
2. Edit existing profile → verify updates persist
3. View collaborator profile → social links clickable
4. Preview own profile → matches collaborator view

**Run**: `flutter test integration_test/user_profile_test.dart`

### Manual Testing

- [ ] Edit profile, add all Phase 1 fields, save
- [ ] Preview profile, verify all fields show
- [ ] Navigate to collaborator profile, tap social icon → opens browser
- [ ] Offline: edit profile → verify saves locally → come online → syncs
- [ ] Settings → Profile → Edit → save → back to settings (flow complete)
- [ ] Manage collaborators screen → no white screen on first load

## Migration Notes

**Database Migration**: None required (all fields nullable)

**Existing Users**:
- New fields default to null
- App continues to work with old data
- Future: Show "Complete your profile" banner

**Rollback Plan**:
- New fields ignored by old app versions
- Safe to deploy without breaking existing installs

## Performance Considerations

**Social Links**: Max 10 links to prevent UI overflow
**Bio Length**: Max 500 characters (indexed for search in future)
**Image Uploads**: Existing avatar system handles it
**Firestore Reads**: No additional reads (fields included in existing document)

## Success Criteria Summary

### Automated Verification

- [ ] All unit tests pass: `flutter test`
- [ ] Code generation succeeds: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- [ ] No linter errors: `flutter analyze`
- [ ] App builds: `flutter build apk` (Android) or `flutter build ios` (iOS)

### Manual Verification

**Phase 1**:
- [ ] Manage collaborators screen shows loading instead of white screen
- [ ] Collaborator card navigation works
- [ ] Entity compiles with new fields

**Phase 2**:
- [ ] Settings → Edit Profile navigates to full-screen editor
- [ ] All Phase 1 fields editable
- [ ] Social links can be added/removed
- [ ] Save button persists changes

**Phase 3**:
- [ ] Preview button shows bottom sheet
- [ ] Preview matches what collaborators see
- [ ] Social icons open external links
- [ ] Collaborator profile shows new fields

**Phase 4**:
- [ ] Profile saves to Firestore
- [ ] Profile caches locally
- [ ] Offline edits sync when online
- [ ] Watch stream emits updates

**Phase 5**:
- [ ] URL validation prevents invalid links
- [ ] Profile completeness shows progress
- [ ] Empty states handle missing data
- [ ] No UI glitches or layout issues

## References

- Original user request: Session start message
- Enhanced entity example: Provided in user message
- Current entity: `lib/features/user_profile/domain/entities/user_profile.dart`
- Profile creation pattern: `lib/features/user_profile/presentation/screens/profile_creation_screen.dart`
- Settings navigation: `lib/features/settings/presentation/widgets/user_profile_section.dart`
- Collaborator view: `lib/features/user_profile/presentation/screens/collaborator_profile_screen.dart`
