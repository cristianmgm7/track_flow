# TrackFlow - Entities and Value Objects

This document describes the domain model architecture in TrackFlow, following Domain-Driven Design (DDD) and SOLID principles. It provides a comprehensive overview of all entities, value objects, and their responsibilities, as well as the patterns and improvements introduced by the SOLID refactor.

## Overview

- **Base Entities:** Abstract base classes for all domain entities and value objects
- **Domain Entities:** Concrete implementations for each business domain
- **Value Objects:** Immutable, validated data types with value-based equality
- **DTOs & Document Models:** Data transfer and persistence representations
- **SOLID Compliance:** All entities and value objects follow SRP, OCP, LSP, ISP, and DIP

---

## 1. Base Architecture

### Entity<T>

**Location:** `lib/core/domain/entity.dart`
**Responsibility:** Abstract base class for all entities with identity-based equality.
**Key Features:**

- Provides a unique identifier (`id`)
- Implements equality based on identity

### AggregateRoot<T>

**Location:** `lib/core/domain/aggregate_root.dart`
**Responsibility:** Base class for aggregate roots (main domain objects that encapsulate other entities/value objects).

### ValueObject<T>

**Location:** `lib/core/entities/value_object.dart`
**Responsibility:** Base class for all value objects, with value-based equality using Equatable.

---

## 2. Identification System

### UniqueId and Specific IDs

**Location:** `lib/core/entities/unique_id.dart` and feature-specific files
**Responsibility:** Centralized, type-safe identification for all domain objects.
**Types:**

- `UniqueId` (base)
- `UserId`, `ProjectId`, `AudioTrackId`, `AudioCommentId`, `MagicLinkId`, `PlaylistId`, etc.
  **Key Features:**
- All IDs use UUIDs for uniqueness
- Factory constructors for creation and parsing
- Standardized across all entities

---

## 3. User Management Domain

### User

**Location:** `lib/features/auth/domain/entities/user.dart`
**Responsibility:** Represents an authenticated user.
**Key Properties:**

- `UserId id`
- `String email`
- `String? displayName`

### UserProfile

**Location:** `lib/features/user_profile/domain/entities/user_profile.dart`
**Responsibility:** Aggregate root for user profile data and creative role.
**Key Properties:**

- `UserId id`
- `String name`
- `String email`
- `CreativeRole? creativeRole`

### EmailAddress (Value Object)

**Location:** `lib/features/auth/domain/entities/email.dart`
**Responsibility:** Validates and encapsulates email addresses.
**Key Features:**

- Returns `Either<Failure, String>` for error handling

### PasswordValue (Value Object)

**Location:** `lib/features/auth/domain/entities/password.dart`
**Responsibility:** Validates and encapsulates passwords.
**Key Features:**

- Returns `Either<Failure, String>` for error handling

---

## 4. Project Management Domain

### Project

**Location:** `lib/features/projects/domain/entities/project.dart`
**Responsibility:** Aggregate root for project data, collaborators, and permissions.
**Key Properties:**

- `ProjectId id`
- Collaborator management (add, remove, update roles)
- Permission-based operations
- Soft delete and playlist conversion

### ProjectCollaborator

**Location:** `lib/features/projects/domain/entities/project_collaborator.dart`
**Responsibility:** Represents a collaborator in a project, with role and permissions.

### ProjectName, ProjectDescription (Value Objects)

**Location:** `lib/features/projects/domain/value_objects/`
**Responsibility:** Validate and encapsulate project name and description.

### ProjectRole (Value Object)

**Location:** `lib/features/projects/domain/value_objects/project_role.dart`
**Responsibility:** Enum for project roles (owner, admin, editor, viewer) and access levels.

---

## 5. Audio System Domain

### AudioTrack

**Location:** `lib/features/audio_track/domain/entities/audio_track.dart`
**Responsibility:** Aggregate root for audio track data.
**Key Properties:**

- `AudioTrackId id`
- `String name`, `String url`, `Duration duration`, `ProjectId projectId`, `UserId uploadedBy`, `DateTime createdAt`

### AudioComment

**Location:** `lib/features/audio_comment/domain/entities/audio_comment.dart`
**Responsibility:** Represents a comment on an audio track.
**Key Properties:**

- `AudioCommentId id`, `ProjectId projectId`, `AudioTrackId trackId`, `UserId createdBy`, `String content`, `Duration timestamp`, `DateTime createdAt`

### PlaybackSession

**Location:** `lib/features/audio_player/domain/entities/playback_session.dart`
**Responsibility:** Represents the state of an audio playback session, including queue, controls, and progress.

### AudioTrackMetadata, PlaybackState, RepeatMode, AudioSource, AudioFailure, AudioQueue

**Responsibility:** Support playback session with metadata, state, error handling, and queue management.

---

## 6. Playlist System Domain

### Playlist

**Location:** `lib/features/playlist/domain/entities/playlist.dart`
**Responsibility:** Aggregate root for playlist data.
**Key Properties:**

- `PlaylistId id`, `String name`, `List<String> trackIds`, `PlaylistSource playlistSource`

---

## 7. Audio Cache System Domain

### CachedAudio

**Location:** `lib/features/audio_cache/shared/domain/entities/cached_audio.dart`
**Responsibility:** Represents a cached audio file, its state, and metadata.
**Key Features:**

- File system info, cache state, quality, checksum validation

### CacheKey (Value Object)

**Location:** `lib/features/audio_cache/shared/domain/value_objects/cache_key.dart`
**Responsibility:** Composite key for cache entries, with URL hashing and integrity validation.

### StorageLimit (Value Object)

**Location:** `lib/features/audio_cache/shared/domain/value_objects/storage_limit.dart`
**Responsibility:** Represents storage limits and usage calculations.

---

## 8. Magic Link Authentication Domain

### MagicLink

**Location:** `lib/features/magic_link/domain/entities/magic_link.dart`
**Responsibility:** Represents a magic link for authentication/invitation.
**Key Properties:**

- `MagicLinkId id`, `String url`, `UserId userId`, `String projectId`, `DateTime createdAt`, `DateTime? expiresAt`, `bool isUsed`, `MagicLinkStatus status`

---

## 9. Data Transfer Layer

### DTOs (Data Transfer Objects)

**Responsibility:** Serialize/deserialize entities for data transfer and persistence.
**Examples:**

- `AuthDto`, `ProjectDTO`, `AudioTrackDTO`, `AudioCommentDto`, `UserProfileDto`, `PlaylistDto`, `MagicLinkDto`
  **Key Features:**
- Updated for new entity constructor patterns
- Proper ID conversion methods (toDomain/fromDomain)
- Standardized string ID handling

### Document Models

**Responsibility:** Database document models for persistence, with code generation.
**Examples:**

- Project, audio track, comment, user profile, playlist, cache reference, cached audio documents

---

## 10. SOLID Refactor Achievements

### Compliance with SOLID Principles

- **SRP:** Each entity/value object has a single, clear responsibility
- **OCP:** Entities and value objects are extensible via inheritance, not modification
- **LSP:** All entities and value objects substitute their base classes correctly
- **ISP:** Interfaces are clean and focused; no forced dependencies
- **DIP:** Entities depend on abstractions (Entity<T>, AggregateRoot<T>, ValueObject<T>)

### Key Improvements

- Eliminated duplication (e.g., consolidated ID types)
- Standardized inheritance and constructor patterns
- Unified equality and ID handling
- Strong typing and maintainability

---

## 11. Summary Table

| Category        | Count/Examples                   |
| --------------- | -------------------------------- |
| Base Entities   | 2 (Entity<T>, AggregateRoot<T>)  |
| Value Objects   | 19+ (IDs, validation, roles)     |
| Domain Entities | 45+ (User, Project, Audio, etc.) |
| DTOs            | 15+                              |
| Document Models | 10+                              |

---

# End of Entities and Value Objects Documentation
