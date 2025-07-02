# TrackFlow - Entities and Value Objects

## General Overview

TrackFlow implements a robust domain model following Domain-Driven Design (DDD) principles with clear separation between **Entities** and **Value Objects**. This documentation presents a comprehensive analysis of all entities and value objects found in the project after the SOLID refactor completion.

### Domain Statistics
- **Base Entities**: 2 abstract classes
- **Domain Entities**: ~45 implementations
- **Value Objects**: 19 implementations
- **DTOs**: ~15 classes for data transfer
- **Document Models**: ~10 models for persistence

---

## 🏗️ Base Architecture

### Fundamental Base Classes

#### **Entity<T>** (`lib/core/domain/entity.dart`)
```dart
abstract class Entity<T> {
  final T id;
  const Entity(this.id);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Entity<T> && other.id == id;
}
```
- Abstract base class for all entities
- Implements identity-based equality
- Provides fundamental pattern for objects with identity

#### **AggregateRoot<T>** (`lib/core/domain/aggregate_root.dart`)
```dart
abstract class AggregateRoot<T> extends Entity<T> {
  const AggregateRoot(super.id);
}
```
- Extends Entity to implement DDD Aggregate Root pattern
- Base for main entities that encapsulate other domain objects

#### **ValueObject<T>** (`lib/core/entities/value_object.dart`)
```dart
abstract class ValueObject<T> extends Equatable {
  final T value;
  const ValueObject(this.value);
  
  @override
  List<Object?> get props => [value];
}
```
- Base class for all value objects
- Implements value-based equality using Equatable

---

## 🆔 Identification System

### Identification Value Objects

#### **UniqueId** (`lib/core/entities/unique_id.dart`)
**Centralized ID Management:**
- **UniqueId**: Base identifier using UUID
- **UserId**: User identification
- **ProjectId**: Project identification
- **AudioTrackId**: Audio track identification (consolidated)
- **AudioCommentId**: Audio comment identification
- **MagicLinkId**: Magic link identification (new)
- **PlaylistId**: Playlist identification (consolidated)

**Key Changes in SOLID Refactor:**
- Removed redundant equality implementations
- Consolidated duplicate AudioTrackId implementations
- Added missing ID types (MagicLinkId)
- Standardized factory constructors pattern

```dart
class AudioTrackId extends UniqueId {
  factory AudioTrackId() => AudioTrackId._(const Uuid().v4());
  factory AudioTrackId.fromUniqueString(String input) => AudioTrackId._(input);
  const AudioTrackId._(super.value) : super._();
}
```

#### **Specific Identifiers by Feature**
- **ProjectCollaboratorId** (`lib/features/projects/domain/value_objects/project_collaborator_id.dart`)

---

## 👤 User Management and Identity

### User Entities

#### **User** (`lib/features/auth/domain/entities/user.dart`)
```dart
class User extends Entity<UserId> {
  final String email;
  final String? displayName;

  User({required UserId id, required this.email, this.displayName}) : super(id);
}
```
**SOLID Refactor Changes:**
- Migrated from plain class to Entity<UserId>
- Changed constructor to accept UserId instead of String
- Removed manual equality implementation

#### **UserProfile** (`lib/features/user_profile/domain/entities/user_profile.dart`)
```dart
class UserProfile extends AggregateRoot<UserId> {
  final String name;
  final String email;
  final CreativeRole? creativeRole;
  // ...
  
  const UserProfile({
    required UserId id,
    required this.name,
    // ...
  }) : super(id);
}
```
**SOLID Refactor Changes:**
- Migrated from Equatable to AggregateRoot<UserId>
- Standardized constructor pattern
- Removed manual props implementation

### Authentication Value Objects

#### **EmailAddress** (`lib/features/auth/domain/entities/email.dart`)
```dart
class EmailAddress extends ValueObject<Either<Failure, String>>
```
- Email format validation
- Returns Either<Failure, String> for error handling

#### **PasswordValue** (`lib/features/auth/domain/entities/password.dart`)
```dart
class PasswordValue extends ValueObject<Either<Failure, String>>
```
- Password validation
- Implements security rules

---

## 📁 Project Management

### Main Entity

#### **Project** (`lib/features/projects/domain/entities/project.dart`)
```dart
class Project extends AggregateRoot<ProjectId>
```
**Key Features:**
- Main Aggregate Root for project domain
- Collaborator management with roles and permissions
- Permission-based operations
- Soft delete functionality
- Playlist conversion
- Membership validation

**Key Methods:**
- `addCollaborator()` - Add collaborators
- `removeCollaborator()` - Remove collaborators
- `updateCollaboratorRole()` - Update roles
- `canUserEdit()` - Permission validation
- `toPlaylist()` - Convert to playlist

#### **ProjectCollaborator** (`lib/features/projects/domain/entities/project_collaborator.dart`)
```dart
class ProjectCollaborator extends Entity<ProjectCollaboratorId>
```
- Individual collaborator management
- Role and permission system
- Specific permission validations
- Individual permission overrides

### Project Value Objects

#### **ProjectName** (`lib/features/projects/domain/value_objects/project_name.dart`)
```dart
class ProjectName extends ValueObject<String>
```
- Name validation (max 50 characters)
- Format and content rules

#### **ProjectDescription** (`lib/features/projects/domain/value_objects/project_description.dart`)
```dart
class ProjectDescription extends ValueObject<String>
```
- Description validation (max 500 characters)
- Formatting and sanitization

#### **ProjectRole** (`lib/features/projects/domain/value_objects/project_role.dart`)
```dart
enum ProjectRole { owner, admin, editor, viewer }
```
- Project role hierarchy
- Defines access levels and permissions

---

## 🎵 Audio System

### Audio Content Entities

#### **AudioTrack** (`lib/features/audio_track/domain/entities/audio_track.dart`)
```dart
class AudioTrack extends AggregateRoot<AudioTrackId> {
  final String name;
  final String url;
  final Duration duration;
  final ProjectId projectId;
  final UserId uploadedBy;
  final DateTime createdAt;

  const AudioTrack({
    required AudioTrackId id,
    required this.name,
    // ...
  }) : super(id);
}
```
**SOLID Refactor Changes:**
- Migrated from Equatable to AggregateRoot<AudioTrackId>
- Uses consolidated AudioTrackId from core
- Standardized constructor pattern
- Removed manual props implementation

#### **AudioComment** (`lib/features/audio_comment/domain/entities/audio_comment.dart`)
```dart
class AudioComment extends Entity<AudioCommentId> {
  final ProjectId projectId;
  final AudioTrackId trackId;
  final UserId createdBy;
  final String content;
  final Duration timestamp;
  final DateTime createdAt;

  const AudioComment({
    required AudioCommentId id,
    required this.projectId,
    // ...
  }) : super(id);
}
```
**SOLID Refactor Changes:**
- Migrated from Equatable to Entity<AudioCommentId>
- Standardized constructor pattern
- Removed manual props implementation

### Audio Player System

#### **PlaybackSession** (`lib/features/audio_player/domain/entities/playback_session.dart`)
```dart
class PlaybackSession extends Entity<UniqueId>
```
**Core Features:**
- Current track state
- Audio queue management
- Playback controls (play/pause/stop)
- Position and progress tracking
- Volume and speed control
- Playback error handling

**Related Entities:**
- **AudioTrackMetadata** - Metadata for player
- **PlaybackState** - Playback states
- **RepeatMode** - Repeat modes
- **AudioSource** - Audio source abstractions
- **AudioFailure** - Error handling
- **AudioQueue** - Queue management

### Playlist System

#### **Playlist** (`lib/features/playlist/domain/entities/playlist.dart`)
```dart
class Playlist extends AggregateRoot<PlaylistId> {
  final String name;
  final List<String> trackIds;
  final PlaylistSource playlistSource;

  const Playlist({
    required PlaylistId id,
    required this.name,
    required this.trackIds,
    required this.playlistSource,
  }) : super(id);
}
```
**SOLID Refactor Changes:**
- Migrated from Equatable to AggregateRoot<PlaylistId>
- Uses consolidated PlaylistId from core
- Removed custom equality operators
- Standardized constructor pattern

---

## 🗂️ Audio Cache System

### Cache Entities

#### **CachedAudio** (`lib/features/audio_cache/shared/domain/entities/cached_audio.dart`)
```dart
class CachedAudio extends Entity<UniqueId>
```
**Features:**
- File system information
- Cache state tracking
- Quality levels
- Checksum validation

**Related Entities:**
- **CacheReference** - Cache reference management
- **CacheMetadata** - Cache metadata
- **DownloadProgress** - Download tracking
- **CacheValidationResult** - Validation results
- **CleanupDetails** - Cleanup tracking
- **PlaylistCacheStats** - Playlist cache statistics

### Cache Value Objects

#### **CacheKey** (`lib/features/audio_cache/shared/domain/value_objects/cache_key.dart`)
```dart
class CacheKey extends ValueObject<String>
```
- Composite key generation
- URL hashing
- Integrity validation

#### **StorageLimit** (`lib/features/audio_cache/shared/domain/value_objects/storage_limit.dart`)
```dart
class StorageLimit extends ValueObject<int>
```
- Byte/MB/GB conversions
- Usage calculations
- Limit validation

---

## 🔗 Other Domains

### Magic Link Authentication

#### **MagicLink** (`lib/features/magic_link/domain/entities/magic_link.dart`)
```dart
class MagicLink extends Entity<MagicLinkId> {
  final String url;
  final UserId userId;
  final String projectId;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isUsed;
  final MagicLinkStatus status;

  const MagicLink({
    required MagicLinkId id,
    required this.url,
    // ...
  }) : super(id);
}
```
**SOLID Refactor Changes:**
- Migrated from Equatable to Entity<MagicLinkId>
- Added new MagicLinkId type
- Standardized constructor pattern

---

## 📋 Data Transfer Layer

### Data Transfer Objects (DTOs)

The project includes comprehensive DTOs for serialization:

- **AuthDto** - Firebase authentication
- **ProjectDTO** - Firestore integration
- **AudioTrackDTO** - Track data transfer
- **AudioCommentDto** - Comment data
- **UserProfileDto** - Profile data
- **PlaylistDto** - Playlist data
- **MagicLinkDto** - Magic link authentication

**SOLID Refactor Impact:**
- All DTOs updated to handle new entity constructor patterns
- Added proper ID conversion methods (toDomain/fromDomain)
- Standardized string ID handling in data layer

### Document Models

Database document models with code generation:
- Project, audio track, comment documents
- User profile, playlist documents
- Cache reference, cached audio documents

---

## 🏛️ Architectural Patterns

### Domain-Driven Design (DDD)

The codebase follows DDD principles with:

1. **Entities** - Objects with identity extending base Entity class
2. **Aggregate Roots** - Complex business objects (like Project, AudioTrack, UserProfile, Playlist)
3. **Value Objects** - Immutable data with value-based equality
4. **DTOs** - Data transfer between layers
5. **Document Models** - Database persistence

### Separation of Responsibilities

- **Domain Layer**: Pure entities and value objects
- **Data Layer**: DTOs and document models
- **Infrastructure**: Specific implementations

### Validation and Business Rules

- Value objects encapsulate validations
- Entities implement complex business rules
- Granular permission system in Project

---

## 📊 Summary by Categories

### Entities (45+ implementations)
- **Base**: 2 abstract classes
- **Identification and User**: 4 entities
- **Project Management**: 2 main entities
- **Audio**: 15+ entities (tracks, player, cache)
- **Playlists**: 1 entity
- **Other Domains**: 3 entities

### Value Objects (19 implementations)
- **Base**: 1 abstract class
- **IDs**: 7 different types (consolidated)
- **Authentication**: 2 validated value objects
- **Project**: 4 specific value objects
- **Audio Cache**: 4 value objects
- **Roles**: 1 value object

### Data Transfer
- **DTOs**: 15+ classes (updated for new entity patterns)
- **Document Models**: 10+ models

---

## 🔍 SOLID Refactor Achievements

### Phase 1 Completion: Entities Refactor

1. **Single Responsibility Principle (SRP)**
   - Each entity has a clear, single purpose
   - Separated concerns between entities and value objects

2. **Open/Closed Principle (OCP)**
   - Removed redundant equality implementations
   - Entities extend base classes without modification

3. **Liskov Substitution Principle (LSP)**
   - All entities properly substitute their base classes
   - Consistent inheritance patterns

4. **Interface Segregation Principle (ISP)**
   - Clean, focused entity interfaces
   - No forced dependencies on unused methods

5. **Dependency Inversion Principle (DIP)**
   - Entities depend on abstractions (Entity<T>, AggregateRoot<T>)
   - Consistent ID abstraction through UniqueId

### Key Improvements

- **Eliminated Duplication**: Removed duplicate AudioTrackId implementations
- **Standardized Inheritance**: All entities now properly extend Entity<T> or AggregateRoot<T>
- **Consistent Patterns**: Unified constructor and ID handling patterns
- **Type Safety**: Strong typing with consolidated ID system
- **Maintainability**: Simplified equality logic and reduced code duplication

---

## 🎯 Next Steps: Data Sources Refactor

With entities now following SOLID principles, the next phase will focus on:

1. **Data Source Interface Segregation**: Split large interfaces following ISP
2. **Method Standardization**: Ensure all methods return `Either<Failure, T>`
3. **Duplicate Elimination**: Remove redundant methods across data sources
4. **Repository Consolidation**: Move business logic from data sources to repositories

The entity refactor provides a solid foundation for the remaining phases of the SOLID architecture improvement.