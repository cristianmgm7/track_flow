# TrackFlow Invitation & Notification System - UX Specification

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [System Overview](#system-overview)
3. [Invitation Flow UX Design](#invitation-flow-ux-design)
4. [Invitation Management UX](#invitation-management-ux)
5. [Notification System UX](#notification-system-ux)
6. [Cross-System Integration UX](#cross-system-integration-ux)
7. [Component Specifications](#component-specifications)
8. [Content Guidelines](#content-guidelines)
9. [Accessibility & Responsive Design](#accessibility--responsive-design)
10. [Error Handling & Edge Cases](#error-handling--edge-cases)
11. [Animation & Micro-interactions](#animation--micro-interactions)

---

## Executive Summary

TrackFlow's invitation and notification system facilitates seamless collaboration between music creators and audio professionals. The system supports inviting both existing users and new users (via magic links) to audio projects with specific roles (Owner, Admin, Editor, Viewer). Real-time notifications are tightly integrated with invitations to provide immediate feedback and actionable insights.

**Key UX Principles:**
- **Professional Clarity**: Clean, music industry-appropriate design
- **Contextual Awareness**: Rich information about projects, roles, and collaborators
- **Real-time Feedback**: Instant visual feedback for all actions
- **Accessibility-First**: WCAG 2.1 AA compliant design
- **Mobile-First**: Responsive design prioritizing mobile workflows

---

## System Overview

### User Roles & Permissions
```
Owner    → Full project control, billing, deletion
Admin    → Manage collaborators, project settings, exports
Editor   → Create/edit tracks, comments, mix versions
Viewer   → Listen-only access, comments on designated tracks
```

### Invitation States
```
pending    → Awaiting user response
accepted   → User joined project  
declined   → User rejected invitation
expired    → Invitation time limit exceeded
cancelled  → Sender cancelled invitation
```

### Notification Types
```
projectInvitation     → New collaboration invitation
projectUpdate         → Project changes/milestones
collaboratorJoined    → New team member joined
audioCommentAdded     → Comments on tracks
audioTrackUploaded    → New audio content
systemMessage         → Platform notifications
```

---

## Invitation Flow UX Design

### A. Discovery & Access Points

#### Primary Entry Points
1. **Project Settings Screen**
   - "Invite Collaborators" button in header
   - Positioned prominently after project title
   - Icon: `Icons.person_add` with text label

2. **Project Dashboard**
   - Floating Action Button (FAB) with `Icons.add`
   - Quick action menu: "Invite Collaborator" option
   - Team member count with "+" button

3. **Empty Collaboration State**
   - Central call-to-action when no collaborators exist
   - Illustrative graphic showing collaboration benefits
   - "Invite Your First Collaborator" primary button

#### Secondary Entry Points
- Global navigation: "Invitations" tab with badge count
- Profile menu: "Invite Friends" option
- Share sheet: "Collaborate" option for projects

### B. Step-by-Step Invitation Form Design

#### Modal Structure
```
┌─────────────────────────────────────────┐
│ [x] Invite Collaborator        [Send]   │
├─────────────────────────────────────────┤
│                                         │
│ Step 1: Find Collaborator               │
│ Step 2: Select Role & Permissions       │
│ Step 3: Add Personal Message (Optional) │
│ Step 4: Review & Send                   │
│                                         │
└─────────────────────────────────────────┘
```

#### Step 1: User Search
```dart
// Email Input with Real-time Search
AppFormField(
  label: 'Collaborator Email',
  hint: 'Search by email address...',
  suffixIcon: _searchState.isLoading 
    ? CircularProgressIndicator()
    : _foundUser != null 
      ? Icon(Icons.check_circle, color: AppColors.success)
      : null,
  // Real-time validation and search
)
```

**Search States:**
- **Typing**: Show loading spinner, debounced search (500ms)
- **User Found**: Green checkmark, user preview card
- **User Not Found**: Blue info indicator for "new user"
- **Error**: Red error message with retry option

**User Preview Card (Existing User):**
```
┌─────────────────────────────────────────┐
│ [Avatar] John Doe                  ✓    │
│          john@example.com               │
│          Existing TrackFlow user        │
└─────────────────────────────────────────┘
```

**New User Indicator:**
```
┌─────────────────────────────────────────┐
│ [+] New User                       ℹ    │
│     Magic link will be sent             │
│     for account creation                │
└─────────────────────────────────────────┘
```

#### Step 2: Role Selection
```
Role Selection (Single Choice)
┌─────────────────────────────────────────┐
│ ○ Owner    Full project control         │
│ ○ Admin    Manage team & settings       │
│ ● Editor   Create & edit content        │ ← Default
│ ○ Viewer   Listen & comment only        │
└─────────────────────────────────────────┘

[?] What do these roles mean?
```

**Role Permission Tooltip:**
- Expandable explanation of each role
- Clear capability matrix
- Visual icons for each permission type

#### Step 3: Personal Message (Optional)
```
Personal Message (Optional)
┌─────────────────────────────────────────┐
│ I'd love to collaborate with you on     │
│ this track! Your expertise would be     │
│ perfect for this project.               │
│                                         │
│ 250 characters remaining                │
└─────────────────────────────────────────┘

Quick Templates:
[General] [Mixing] [Vocals] [Custom]
```

#### Step 4: Review & Send
```
Review Invitation
┌─────────────────────────────────────────┐
│ To: john@example.com ✓                  │
│ Role: Editor                            │
│ Project: "Summer Vibes EP"              │
│ Expires: 30 days from now               │
│                                         │
│ "I'd love to collaborate..."            │
│                                         │
│ [Cancel]              [Send Invitation] │
└─────────────────────────────────────────┘
```

### C. Success/Error States

#### Success State
- Modal closes automatically
- Toast notification: "Invitation sent to [email]"
- Update sent invitations list immediately
- Optional: Offer to send another invitation

#### Error States
- **Network Error**: "Connection failed. Try again?"
- **Invalid Email**: "Please enter a valid email address"
- **Already Invited**: "This user already has a pending invitation"
- **Permission Error**: "You don't have permission to invite collaborators"
- **Quota Exceeded**: "Invitation limit reached for this project"

---

## Invitation Management UX

### A. Invitations Screen Structure

#### Tab Navigation
```
Invitations
┌─────────────────────────────────────────┐
│ Received (3)    Sent (7)                │
├─────────────────────────────────────────┤
│ [Content Area]                          │
│                                         │
│                                    [+]  │ ← FAB for new invitation
└─────────────────────────────────────────┘
```

### B. Received Invitations Tab

#### Invitation Card Layout
```
┌─────────────────────────────────────────┐
│ [Project Icon] "Summer Vibes EP"   [●]  │ ← Unread indicator
│                Role: Editor             │
│                                    [⋮]  │ ← Menu
│ From: Sarah Chen                        │
│ Expires: 23 days remaining              │
│                                         │
│ "Would love your mixing expertise..."   │
│                                         │
│          [Decline]    [Accept]          │
└─────────────────────────────────────────┤
```

#### Visual Hierarchy
- **Unread invitations**: Subtle blue left border, bold text
- **Expiring soon**: Orange accent (< 7 days)
- **Expired**: Grayed out with overlay

#### Quick Actions
- **Swipe Left**: Decline invitation
- **Swipe Right**: Accept invitation  
- **Long Press**: Show context menu
- **Tap**: Open detailed view

### C. Sent Invitations Tab

#### Sent Invitation Card
```
┌─────────────────────────────────────────┐
│ [Avatar] John Doe              [PENDING]│
│          john@example.com               │
│                                    [⋮]  │
│ Project: "Summer Vibes EP"              │
│ Role: Editor                            │
│ Sent: 2 days ago                        │
│                                         │
│                        [Cancel]        │
└─────────────────────────────────────────┤
```

#### Status Indicators
```css
PENDING   → Blue pill, pulsing animation
ACCEPTED  → Green pill with checkmark
DECLINED  → Gray pill
EXPIRED   → Orange pill with clock icon
CANCELLED → Red pill with X icon
```

### D. Invitation Status Tracking

#### Real-time Updates
- **WebSocket Integration**: Live status updates
- **Optimistic Updates**: Immediate UI response
- **Sync Indicators**: Show when data is refreshing

#### Batch Operations
- **Select Multiple**: Checkbox selection mode
- **Bulk Actions**: Cancel multiple, resend multiple
- **Confirmation Dialogs**: Prevent accidental actions

---

## Notification System UX

### A. Notification Center Structure

#### Header with Actions
```
Notifications                    [Mark All Read] [•••]
┌─────────────────────────────────────────┐
│ All (12)        Unread (3)              │
├─────────────────────────────────────────┤
│ [Notification List]                     │
└─────────────────────────────────────────┘
```

#### Filter & Sort Options
- **Filters**: All, Unread, Invitations, Updates
- **Sort**: Newest first, Oldest first, By type
- **Search**: Find specific notifications

### B. Notification Card Design

#### Standard Notification Layout
```
┌─────────────────────────────────────────┐
│ [Icon] Sarah invited you to join    [●] │ ← Type icon & unread
│        "Summer Vibes EP" as Editor      │
│        2 hours ago              [⋮]     │
│                                         │
│ [View Invitation]              →        │ ← Primary action
└─────────────────────────────────────────┤
```

#### Notification Types & Icons
```dart
projectInvitation     → Icons.person_add     (Orange)
projectUpdate         → Icons.update         (Blue)  
collaboratorJoined    → Icons.group_add      (Green)
audioCommentAdded     → Icons.comment        (Purple)
audioTrackUploaded    → Icons.music_note     (Blue)
systemMessage         → Icons.info           (Gray)
```

#### Rich Content Preview
```
┌─────────────────────────────────────────┐
│ [🎵] New track uploaded to "EP Name"    │
│      "Lead Vocals - Take 3.wav"         │
│      By Mike Chen • 1 hour ago          │
│                                         │
│ [▶️ Preview] [View Project]        [⋮]  │
└─────────────────────────────────────────┤
```

### C. Real-time Notification Delivery

#### In-App Notifications
- **Toast Notifications**: For immediate actions
- **Banner Notifications**: For important updates
- **Badge Updates**: Real-time count updates

#### Push Notifications
- **Smart Timing**: Respect user's time zones
- **Batching**: Group related notifications
- **Rich Media**: Include project artwork/previews

#### Sound & Haptics
- **Custom Sounds**: Different tones for different types
- **Haptic Feedback**: Subtle vibrations for interactions
- **Accessibility**: Support for hearing-impaired users

### D. Notification Actions

#### Primary Actions (Always Visible)
- **Invitations**: [Accept] [Decline] buttons
- **Comments**: [Reply] [View Thread]
- **Updates**: [View Changes] [Dismiss]

#### Secondary Actions (Menu)
- Mark as read/unread
- Delete notification
- Mute this project
- Notification settings

---

## Cross-System Integration UX

### A. Notification → Invitation Flow

#### Seamless Navigation
```
User Journey:
1. Receives push notification: "Sarah invited you..."
2. Taps notification → Opens app to Invitation detail
3. Reviews invitation with full context
4. Takes action (Accept/Decline) from notification screen
5. Returns to previous app state or project dashboard
```

#### Context Preservation
- **Deep Linking**: Direct navigation to specific invitation
- **State Management**: Preserve scroll position, filters
- **Back Navigation**: Intelligent back stack management

### B. Invitation → Project Onboarding

#### Acceptance Flow
```
1. User accepts invitation
2. Welcome modal: "Welcome to [Project Name]!"
3. Role explanation: "As an Editor, you can..."
4. Project tour: Key features walkthrough
5. First action prompt: "Start by listening to Track 1"
```

#### New User Onboarding
```
Magic Link Flow:
1. User clicks email link
2. Account creation (simplified)
3. Automatic project joining
4. Guided tutorial for first-time users
5. Introduction to collaboration features
```

### C. Project Context Integration

#### Invitation Context Cards
```
Project: "Summer Vibes EP"
┌─────────────────────────────────────────┐
│ [Cover Art] 4 tracks • 2 collaborators  │
│             Created by Sarah Chen       │
│             Last updated: 2 days ago    │
│                                         │
│ Recent Activity:                        │
│ • Lead vocals added                     │
│ • Mix notes updated                     │
│ • Ready for your input                  │
└─────────────────────────────────────────┘
```

---

## Component Specifications

### A. Core UI Components

#### InvitationCard
```dart
class InvitationCard extends StatelessWidget {
  final ProjectInvitation invitation;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline; 
  final VoidCallback? onCancel;
  final bool showActions;
  final bool isLoading;
  
  // States: default, loading, success, error
  // Animations: slide in, fade out, pulse (pending)
  // Accessibility: semantic labels, screen reader support
}
```

#### NotificationCard  
```dart
class NotificationCard extends StatelessWidget {
  final Notification notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkRead;
  final VoidCallback? onDelete;
  final bool showActions;
  
  // Real-time updates via BLoC
  // Swipe actions for quick operations
  // Rich content preview for media types
}
```

#### SendInvitationForm
```dart
class SendInvitationForm extends StatefulWidget {
  final ProjectId projectId;
  final Function(SendInvitationParams)? onSend;
  
  // Multi-step wizard with validation
  // Real-time user search with debouncing  
  // Role selection with permission preview
  // Message templates and custom text
}
```

### B. Status & Feedback Components

#### InvitationStatusBadge
```dart
enum InvitationStatus { pending, accepted, declined, expired, cancelled }

Widget _buildStatusBadge(InvitationStatus status) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: _getStatusColor(status).withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_getStatusIcon(status), size: 12),
        SizedBox(width: 4),
        Text(_getStatusText(status), style: _getStatusTextStyle(status)),
      ],
    ),
  );
}
```

#### NotificationBadge
```dart
class NotificationBadge extends StatelessWidget {
  final int count;
  final bool showZero;
  final Color backgroundColor;
  final Color textColor;
  
  // Animated count changes
  // Maximum display (99+)
  // Accessibility announcements
}
```

### C. Layout Components

#### EmptyState
```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;  
  final Widget? action;
  final bool showIllustration;
  
  // Contextual illustrations
  // Clear call-to-action
  // Consistent spacing using Dimensions.*
}
```

#### LoadingState
```dart
class LoadingState extends StatelessWidget {
  final String? message;
  final bool showProgress;
  final VoidCallback? onCancel;
  
  // Skeleton loading for cards
  // Progress indicators for operations
  // Cancellation support for long operations
}
```

---

## Content Guidelines

### A. Microcopy Standards

#### Invitation Messages
```
✅ Good: "Sarah invited you to collaborate on 'Summer Vibes EP'"
❌ Bad: "You have received an invitation"

✅ Good: "Join as Editor • Full creative control"
❌ Bad: "Role: Editor"

✅ Good: "23 days remaining to respond"
❌ Bad: "Expires: 2024-08-15"
```

#### Notification Text
```
✅ Good: "Mike uploaded 'Lead Vocals Take 3' to Summer Vibes EP"
❌ Bad: "New audio file uploaded"

✅ Good: "3 new comments on your mix"
❌ Bad: "New notifications available"
```

#### Error Messages
```
✅ Good: "Couldn't send invitation. Check your connection and try again."
❌ Bad: "Network error occurred"

✅ Good: "This email is already invited to the project"
❌ Bad: "Duplicate invitation error"
```

### B. Tone & Voice Guidelines

- **Professional yet Approachable**: Music industry standard
- **Action-Oriented**: Clear next steps always provided
- **Contextual**: Include relevant project/user information
- **Encouraging**: Focus on collaboration benefits
- **Concise**: Respect user's time and attention

### C. Internationalization

#### Text Expansion Planning
- **Form Labels**: 40% expansion allowance
- **Button Text**: 30% expansion allowance
- **Error Messages**: 50% expansion allowance
- **Notification Text**: 45% expansion allowance

#### Cultural Considerations
- **Time Formats**: Respect local conventions
- **Name Formats**: Support various naming patterns
- **Email Validation**: International domain support
- **Professional Etiquette**: Cultural communication norms

---

## Accessibility & Responsive Design

### A. WCAG 2.1 AA Compliance

#### Color & Contrast
```dart
// Minimum contrast ratios
Text on Background: 4.5:1
UI Elements: 3:1
Status Indicators: 4.5:1

// Color-blind friendly palette
Success: #4CAF50 (distinguishable green)
Warning: #FF9800 (distinguishable orange)  
Error: #E53E3E (distinguishable red)
Info: #2196F3 (distinguishable blue)
```

#### Semantic Markup
```dart
Semantics(
  label: 'Invitation from Sarah Chen',
  hint: 'Double tap to view details',
  button: true,
  enabled: !isLoading,
  child: InvitationCard(...),
)
```

#### Focus Management
- **Keyboard Navigation**: Tab order follows visual flow
- **Focus Indicators**: Clear visual focus rings
- **Skip Links**: Quick navigation to main content
- **Screen Reader**: Descriptive labels and announcements

### B. Responsive Design Breakpoints

#### Mobile First (360px - 768px)
```css
/* Single column layout */
.invitation-card { 
  margin: 8px 16px;
  padding: 16px;
}

.action-buttons {
  flex-direction: column;
  gap: 8px;
}
```

#### Tablet (768px - 1024px)
```css
/* Two column grid for cards */
.invitations-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}
```

#### Desktop (1024px+)
```css
/* Three column layout with sidebar */
.invitations-layout {
  display: grid;
  grid-template-columns: 280px 1fr 320px;
  gap: 24px;
}
```

### C. Touch & Interaction Design

#### Touch Targets
- **Minimum Size**: 48px x 48px (following Material Design)
- **Spacing**: 8px minimum between interactive elements
- **Feedback**: Immediate visual response to touches

#### Gesture Support
- **Swipe Actions**: Left/right swipes on cards
- **Pull to Refresh**: On notification lists
- **Long Press**: Context menu activation
- **Pinch to Zoom**: For attached images/documents

---

## Error Handling & Edge Cases

### A. Network & Connectivity

#### Offline Support
```dart
// Show cached data with offline indicator
OfflineBanner(
  message: 'You're offline. Some features may be limited.',
  action: TextButton(
    onPressed: () => _retryConnection(),
    child: Text('Retry'),
  ),
)
```

#### Failed Operations
```dart
// Retry mechanisms with exponential backoff
RetryWrapper(
  operation: () => _sendInvitation(params),
  maxRetries: 3,
  onError: (error) => _showErrorDialog(error),
  onSuccess: () => _showSuccessMessage(),
)
```

### B. Data & State Edge Cases

#### Empty States
- **No Invitations**: Encouraging call-to-action
- **No Notifications**: Clean, informative message
- **No Search Results**: Helpful suggestions

#### Loading States
- **Initial Load**: Skeleton UI matching final layout
- **Infinite Scroll**: Bottom loading indicator
- **Real-time Updates**: Subtle loading animations

#### Error Recovery
```dart
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error)? errorBuilder;
  
  // Graceful error handling
  // User-friendly error messages
  // Recovery action suggestions
}
```

### C. User Input Validation

#### Email Validation
```dart
String? validateEmail(String? value) {
  if (value?.isEmpty ?? true) return 'Email is required';
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
    return 'Please enter a valid email address';
  }
  if (value.length > 254) return 'Email address is too long';
  return null;
}
```

#### Message Validation
```dart
String? validateMessage(String? value) {
  if (value == null || value.isEmpty) return null; // Optional field
  if (value.length > 500) return 'Message must be under 500 characters';
  if (value.trim().isEmpty) return 'Message cannot be empty';
  return null;
}
```

### D. Permission & Security Edge Cases

#### Invitation Permissions
- **Project Access**: Verify user can invite collaborators
- **Role Limitations**: Ensure user can assign specific roles
- **Quota Limits**: Handle invitation limits gracefully

#### Security Validation
- **Email Spoofing**: Server-side validation required
- **Spam Prevention**: Rate limiting and validation
- **Magic Link Security**: Time-limited, single-use tokens

---

## Animation & Micro-interactions

### A. Page Transitions

#### Modal Animations
```dart
// Slide up from bottom with fade
SlideTransition(
  position: _slideAnimation,
  child: FadeTransition(
    opacity: _fadeAnimation,
    child: SendInvitationForm(...),
  ),
)

// Animation timing: 300ms ease-out
```

#### Screen Transitions
```dart
// Shared element transitions for cards
Hero(
  tag: 'invitation-${invitation.id}',
  child: InvitationCard(...),
)
```

### B. Loading & State Animations

#### Skeleton Loading
```dart
class SkeletonLoader extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  
  // Shimmer effect for loading states
  // Matches final content dimensions
  // Smooth transition to actual content
}
```

#### Status Changes
```dart
// Status badge color transitions
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  color: _getStatusColor(invitation.status),
  child: StatusBadge(...),
)
```

### C. Interactive Feedback

#### Button Press Animations
```dart
// Scale down on press with haptic feedback
GestureDetector(
  onTapDown: (_) {
    _scaleController.forward();
    HapticFeedback.lightImpact();
  },
  onTapUp: (_) => _scaleController.reverse(),
  child: ScaleTransition(
    scale: _scaleAnimation,
    child: PrimaryButton(...),
  ),
)
```

#### Swipe Actions
```dart
// Reveal actions with elastic animation
Dismissible(
  key: Key(invitation.id),
  background: SwipeActionBackground(
    icon: Icons.check,
    color: AppColors.success,
    label: 'Accept',
  ),
  onDismissed: (direction) => _handleSwipeAction(direction),
)
```

### D. Real-time Update Animations

#### New Content Arrival
```dart
// Slide in new notifications from top
AnimatedList(
  itemBuilder: (context, index, animation) {
    return SlideTransition(
      position: animation.drive(
        Tween(begin: Offset(0, -1), end: Offset.zero),
      ),
      child: NotificationCard(...),
    );
  },
)
```

#### Count Badge Updates
```dart
// Pulsing animation for new notifications
AnimatedContainer(
  duration: Duration(milliseconds: 150),
  transform: Matrix4.identity()..scale(_hasNewNotifications ? 1.2 : 1.0),
  child: NotificationBadge(...),
)
```

---

## Implementation Notes for Flutter UI Expert

### A. Architecture Integration Points

#### BLoC Pattern Implementation
```dart
// Invitation flow states
abstract class InvitationState {}
class InvitationInitial extends InvitationState {}
class InvitationLoading extends InvitationState {}
class InvitationSuccess extends InvitationState {}
class InvitationError extends InvitationState {
  final String message;
  InvitationError(this.message);
}

// Real-time notification handling
class NotificationWatcherBloc extends Bloc<NotificationEvent, NotificationState> {
  final StreamSubscription<List<Notification>> _notificationSubscription;
  
  @override
  Stream<NotificationState> mapEventToState(NotificationEvent event) async* {
    // Handle real-time updates
    // Manage state transitions
    // Emit UI-ready states
  }
}
```

#### Theme Integration
```dart
// Extend existing theme system
extension InvitationTheme on ThemeData {
  InvitationCardTheme get invitationCardTheme => InvitationCardTheme(
    backgroundColor: AppColors.surface,
    borderColor: AppColors.border,
    textColor: AppColors.textPrimary,
    // Use existing Dimensions.* for spacing
    padding: EdgeInsets.all(Dimensions.cardPadding),
  );
}
```

### B. Performance Considerations

#### List Optimization
```dart
// Use ListView.builder for large lists
// Implement item height caching
// Add scroll physics customization
class OptimizedInvitationList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemExtent: _calculateItemHeight(), // Fixed height for performance
      cacheExtent: 1000, // Pre-render items for smooth scrolling
      itemBuilder: (context, index) => InvitationCard(...),
    );
  }
}
```

#### Image Loading
```dart  
// Lazy load user avatars and project artwork
CachedNetworkImage(
  imageUrl: user.avatarUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => DefaultAvatar(),
  memCacheHeight: 100, // Optimize memory usage
)
```

### C. Testing Considerations

#### Widget Testing
```dart
// Test invitation form validation
testWidgets('should show error for invalid email', (tester) async {
  await tester.pumpWidget(SendInvitationForm(...));
  await tester.enterText(find.byType(TextFormField), 'invalid-email');
  await tester.tap(find.text('Send Invitation'));
  await tester.pump();
  
  expect(find.text('Please enter a valid email address'), findsOneWidget);
});

// Test notification card interactions
testWidgets('should mark notification as read when tapped', (tester) async {
  // ... test implementation
});
```

#### Integration Testing
```dart
// Test complete invitation flow
testWidgets('complete invitation flow', (tester) async {
  // Navigate to project
  // Open invitation form
  // Fill out form
  // Send invitation
  // Verify success state
});
```

---

This comprehensive UX specification provides detailed guidance for implementing a professional, accessible, and user-friendly invitation and notification system for TrackFlow. The specification prioritizes music industry workflows while maintaining Flutter best practices and the existing codebase architecture.