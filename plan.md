# Notification System Fix Plan

## Problem Summary
The notification system creates notifications locally and syncs them to remote (Firestore), but fails to sync notifications FROM remote TO local storage. This means users never receive notifications created for them by other users (e.g., when added as collaborators).

## Root Cause
The `SyncNotificationsUseCase` only watches local data instead of actually fetching notifications from Firestore. The repository lacks a method to pull remote notifications and cache them locally.

## Required Changes

### 1. Add Remote Sync Method to NotificationRepository
**File**: `lib/core/notifications/domain/repositories/notification_repository.dart`
**Action**: Add new method signature
```dart
/// Sync notifications from remote to local cache for a user
Future<Either<Failure, Unit>> syncNotificationsFromRemote(UserId userId);
```

### 2. Implement Remote Sync in Repository
**File**: `lib/core/notifications/data/repositories/notification_repository_impl.dart`
**Action**: Implement the sync method
- Fetch all notifications for user from remote datasource
- Compare with local notifications (by ID and timestamp)
- Cache new/updated notifications locally
- Handle sync conflicts (remote wins for read/unread status)

### 3. Fix SyncNotificationsUseCase
**File**: `lib/core/sync/domain/usecases/sync_notifications_usecase.dart`
**Action**: Replace line 60 with actual remote sync call
```dart
// Replace this:
await _notificationRepository.watchNotifications(userEntity).first;

// With this:
final syncResult = await _notificationRepository.syncNotificationsFromRemote(userEntity);
syncResult.fold(
  (failure) => throw Exception('Failed to sync notifications: ${failure.message}'),
  (_) => AppLogger.sync('NOTIFICATIONS', 'Remote notifications synced successfully'),
);
```

### 4. Enhance Remote DataSource (if needed)
**File**: `lib/core/notifications/data/datasources/notification_remote_datasource.dart`
**Action**: Verify `getNotificationsForUser` method exists and works correctly

### 5. Add Error Handling and Logging
**File**: `lib/core/notifications/data/repositories/notification_repository_impl.dart`
**Action**: Add comprehensive error handling and logging for the sync process

## Implementation Steps

### Step 1: Update Domain Layer
1. Add `syncNotificationsFromRemote` method to `NotificationRepository` interface
2. Update repository contract with proper documentation

### Step 2: Implement Data Layer
1. Implement `syncNotificationsFromRemote` in `NotificationRepositoryImpl`
2. Add logic to compare remote vs local notifications
3. Implement smart caching (only update what's changed)
4. Add proper error handling and logging

### Step 3: Fix Sync Use Case
1. Update `SyncNotificationsUseCase.call()` method
2. Replace local-only watching with actual remote sync
3. Add proper error handling for sync failures

### Step 4: Test the Flow
1. User A adds User B as collaborator
2. Verify notification is created in Firestore for User B
3. Verify User B's app syncs the notification during next sync cycle (15 min or app startup)
4. Verify notification appears in User B's notification list

## Acceptance Criteria

✅ **Notification Creation**: When User A adds User B as collaborator, notification is created in Firestore for User B

✅ **Remote Sync**: User B's app fetches the notification from Firestore during sync

✅ **Local Storage**: Notification is cached locally in User B's Isar database

✅ **UI Display**: Notification appears in User B's notification center/list

✅ **Real-time Updates**: NotificationWatcherBloc emits updated state when new notifications are synced

✅ **Sync Timing**: Notifications sync during app startup and every 15 minutes via BackgroundSyncCoordinator

## Technical Notes

- **Offline-First**: Local notifications are always displayed immediately, remote sync happens in background
- **Conflict Resolution**: Remote data wins for notification content, but preserve local read/unread status until explicitly changed
- **Performance**: Only sync notifications that are new or have been updated since last sync
- **Error Handling**: Sync failures should not break the notification system - local data is always available

## Files to Modify

1. `lib/core/notifications/domain/repositories/notification_repository.dart` - Add interface method
2. `lib/core/notifications/data/repositories/notification_repository_impl.dart` - Implement sync logic
3. `lib/core/sync/domain/usecases/sync_notifications_usecase.dart` - Fix sync call
4. Potentially `lib/core/notifications/data/datasources/notification_remote_datasource.dart` - Verify remote methods

## Testing Strategy

1. **Unit Tests**: Test repository sync method with mocked data sources
2. **Integration Tests**: Test full notification flow from creation to display
3. **Manual Testing**: 
   - Add collaborator on Device A
   - Verify notification appears on Device B after sync
   - Test offline scenarios and sync recovery