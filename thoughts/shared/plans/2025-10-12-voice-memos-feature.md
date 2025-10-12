# Voice Memos Feature Implementation Plan

## Overview

This plan details the implementation of a standalone Voice Memos feature for TrackFlow, a music collaboration app. Voice memos allow users to quickly capture musical ideas or notes using the existing audio recording and playback infrastructure. The feature will be local-only initially, with a data structure designed for future conversion to track versions.

## Current State Analysis

### Existing Infrastructure to Leverage

1. **Audio Recording System** (`lib/features/audio_recording/`)
   - `RecordingBloc` with pause/resume/cancel support
   - `PlatformRecordingService` producing M4A/AAC audio at 128kbps, 44.1kHz
   - `RecordingService` interface with permission handling
   - Real-time amplitude monitoring for waveform visualization
   - Temporary file storage with automatic cleanup

2. **Audio Playback System** (`lib/features/audio_player/`)
   - Centralized `AudioPlayerBloc` with single `AudioPlayer` instance
   - Cache-first playback strategy
   - Reactive state management with streams
   - Support for local file playback
   - Play/pause/seek controls

3. **Local Storage (Isar)**
   - High-performance embedded database
   - Reactive watch streams with `fireImmediately: true`
   - Transaction support for atomic operations
   - FNV-1a hash for string-to-int ID conversion
   - File system utilities for directory management

4. **Navigation Structure** (`lib/features/navegacion/`)
   - `MainScaffold` with bottom navigation (3 tabs currently)
   - `NavigationCubit` managing tab state
   - `AppScaffold` with FAB support
   - Route registration via GoRouter

5. **Theme System** (`lib/core/theme/`)
   - `AppColors`, `AppDimensions`, `AppTextStyle`
   - Consistent spacing (8pt grid)
   - FAB sizing: `Dimensions.fabSize = 56.0`
   - Bottom nav height: `Dimensions.bottomNavHeight = 80.0`

### Key Discoveries

1. **Audio File Storage Pattern** (from `DirectoryService`)
   - Base path: `{appDocuments}/trackflow/audio/`
   - Subdirectories by type: `comments/`, `tracks/`, `voice_memos/` (new)
   - `AudioStorageRepository` manages cached audio hierarchy

2. **Recording Output Format**
   - Format: M4A (AAC-LC codec)
   - Bit rate: 128kbps
   - Sample rate: 44.1kHz (CD quality)
   - File naming: `recording_{timestamp}_{uuid}.m4a`

3. **Playback Integration Pattern** (from audio comments)
   - Create `AudioSource` with local file path
   - Dispatch `PlayAudioCommentRequested` event to `AudioPlayerBloc`
   - Listen to `AudioPlayerSessionState` for playback state

4. **List Screen Pattern** (from projects/invitations)
   - `AppScaffold` with `AppAppBar`
   - `BlocBuilder` for reactive UI
   - `FloatingActionButton` for primary action
   - Empty state with instructional text
   - `ListView.builder` with custom card components

## Desired End State

### Feature Capabilities

1. **Voice Memos Tab** - 4th tab in bottom navigation with microphone icon
2. **Memos List** - Display all voice memos sorted by date (newest first)
3. **Recording** - Dedicated screen with pulsing circle animation
4. **Playback** - Inline controls in each memo list item
5. **Management** - Rename memos and delete functionality
6. **Persistence** - Local-only storage using Isar

### Data Structure for Future Scalability

The `VoiceMemo` entity will include:
- `id: VoiceMemoId` - Unique identifier
- `title: String` - User-editable title
- `localFilePath: String` - Audio file path
- `duration: Duration` - Recording length
- `recordedAt: DateTime` - Creation timestamp
- **Future field**: `convertedToTrackId: AudioTrackId?` - For tracking conversion

### Verification Criteria

**User Flow**:
1. User taps Voice Memos tab in bottom nav
2. Sees list of existing memos (or empty state)
3. Taps FAB to start recording
4. Navigates to recording screen with pulsing circle
5. Stops recording, auto-returns to list
6. New memo appears at top with auto-generated title
7. Taps memo to play inline
8. Long-press memo title to rename
9. Swipe to delete memo

## What We're NOT Doing

1. **Cloud Sync** - No Firebase sync, no remote storage
2. **Sharing** - No export or share functionality
3. **Waveform Visualization** - Using pulsing circle instead (simpler)
4. **Audio Editing** - No trimming, filters, or effects
5. **Categories/Tags** - No organization beyond chronological list
6. **Search** - No search functionality
7. **Track Conversion** - Data structure supports it, but not implementing yet
8. **Audio Quality Settings** - Using fixed 128kbps AAC settings
9. **Background Recording** - Recording stops when app backgrounds
10. **Multiple Recordings Simultaneously** - Single recording session at a time

## Implementation Approach

This implementation follows Clean Architecture principles with an offline-first, local-only strategy. We'll reuse existing recording and playback infrastructure, adding only the necessary domain logic, local storage, and UI components for voice memos.

### Architecture Layers

- **Domain**: Entities, repository contracts, use cases (business logic)
- **Data**: Isar document models, local data source, repository implementation
- **Presentation**: BLoC state management, screens, widgets

### Technology Stack

- **Local Database**: Isar (embedded NoSQL)
- **Recording**: `record` package (via existing `PlatformRecordingService`)
- **Playback**: `just_audio` package (via existing `AudioPlayerBloc`)
- **State Management**: BLoC pattern with `flutter_bloc`
- **DI**: `injectable` + `get_it`
- **Navigation**: GoRouter

---

## Phase 1: Domain Layer - Entities and Contracts

### Overview
Establish the domain model for voice memos with entities, value objects, repository contracts, and use cases. This phase defines the core business logic without any implementation details.

### Changes Required

#### 1. Create Voice Memo Entity
**File**: `lib/features/voice_memos/domain/entities/voice_memo.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../../../core/domain/entity.dart';
import '../value_objects/voice_memo_id.dart';

/// Voice memo entity representing a recorded audio memo
class VoiceMemo extends Entity<VoiceMemoId> {
  final String title;
  final String fileLocalPath;
  final String? fileRemoteUrl;
  final Duration duration;
  final DateTime recordedAt;

  /// Future scalability: track if this memo was converted to a track version
  /// Null means not converted yet
  final String? convertedToTrackId;

  /// The user who created this voice memo. Null for legacy/app local only contexts.
  final UserId? createdBy;

  const VoiceMemo({
    required VoiceMemoId id,
    required this.title,
    required this.fileLocalPath,
    this.fileRemoteUrl,
    required this.duration,
    required this.recordedAt,
    this.convertedToTrackId,
    this.createdBy,
  }) : super(id);

  /// Factory method for creating new voice memos
  factory VoiceMemo.create({
    required String fileLocalPath,
    String? fileRemoteUrl,
    required Duration duration,
    UserId? createdBy,
  }) {
    final now = DateTime.now();
    return VoiceMemo(
      id: VoiceMemoId(),
      title: _generateTitle(now),
      fileLocalPath: fileLocalPath,
      fileRemoteUrl: fileRemoteUrl,
      duration: duration,
      recordedAt: now,
      convertedToTrackId: null,
      createdBy: createdBy,
    );
  }

  /// Generate auto-title from timestamp
  static String _generateTitle(DateTime timestamp) {
    final month = timestamp.month.toString().padLeft(2, '0');
    final day = timestamp.day.toString().padLeft(2, '0');
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return 'Voice Memo $month/$day/${timestamp.year} $hour:$minute';
  }

  VoiceMemo copyWith({
    VoiceMemoId? id,
    String? title,
    String? fileLocalPath,
    String? fileRemoteUrl,
    Duration? duration,
    DateTime? recordedAt,
    String? convertedToTrackId,
    UserId? createdBy,
  }) {
    return VoiceMemo(
      id: id ?? this.id,
      title: title ?? this.title,
      fileLocalPath: fileLocalPath ?? this.fileLocalPath,
      fileRemoteUrl: fileRemoteUrl ?? this.fileRemoteUrl,
      duration: duration ?? this.duration,
      recordedAt: recordedAt ?? this.recordedAt,
      convertedToTrackId: convertedToTrackId ?? this.convertedToTrackId,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    fileLocalPath,
    fileRemoteUrl,
    duration,
    recordedAt,
    convertedToTrackId,
    createdBy,
  ];
}

#### 2. Create Voice Memo ID Value Object
**File**: `lib/features/voice_memos/domain/value_objects/voice_memo_id.dart`

```dart
import 'package:uuid/uuid.dart';
import '../../../../core/domain/value_object.dart';

/// Voice memo unique identifier
class VoiceMemoId extends ValueObject<String> {
  @override
  final String value;

  VoiceMemoId._(this.value);

  /// Generate new UUID
  factory VoiceMemoId() {
    return VoiceMemoId._(const Uuid().v4());
  }

  /// Create from existing string
  factory VoiceMemoId.fromUniqueString(String uniqueId) {
    return VoiceMemoId._(uniqueId);
  }

  @override
  List<Object?> get props => [value];
}
```

#### 3. Create Repository Contract
**File**: `lib/features/voice_memos/domain/repositories/voice_memo_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/voice_memo.dart';
import '../value_objects/voice_memo_id.dart';

/// Repository contract for voice memo operations
abstract class VoiceMemoRepository {
  /// Watch all voice memos (sorted by recordedAt desc)
  Stream<Either<Failure, List<VoiceMemo>>> watchAllMemos();

  /// Get single memo by ID
  Future<Either<Failure, VoiceMemo?>> getMemoById(VoiceMemoId memoId);

  /// Save a new voice memo
  Future<Either<Failure, Unit>> saveMemo(VoiceMemo memo);

  /// Update existing memo (for rename)
  Future<Either<Failure, Unit>> updateMemo(VoiceMemo memo);

  /// Delete memo and its audio file
  Future<Either<Failure, Unit>> deleteMemo(VoiceMemoId memoId);

  /// Delete all memos (cleanup)
  Future<Either<Failure, Unit>> deleteAllMemos();
}
```

#### 4. Create Use Cases

**File**: `lib/features/voice_memos/domain/usecases/create_voice_memo_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../audio_recording/domain/entities/audio_recording.dart';
import '../entities/voice_memo.dart';
import '../repositories/voice_memo_repository.dart';

/// Creates a voice memo from a completed recording
@lazySingleton
class CreateVoiceMemoUseCase {
  final VoiceMemoRepository _repository;

  CreateVoiceMemoUseCase(this._repository);

  Future<Either<Failure, VoiceMemo>> call(AudioRecording recording) async {
    // Create memo entity from recording
    final memo = VoiceMemo.create(
      localFilePath: recording.localPath,
      duration: recording.duration,
    );

    // Save to repository
    final result = await _repository.saveMemo(memo);

    return result.fold(
      (failure) => Left(failure),
      (_) => Right(memo),
    );
  }
}
```

**File**: `lib/features/voice_memos/domain/usecases/watch_voice_memos_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/voice_memo.dart';
import '../repositories/voice_memo_repository.dart';

/// Watch all voice memos with reactive updates
@lazySingleton
class WatchVoiceMemosUseCase {
  final VoiceMemoRepository _repository;

  WatchVoiceMemosUseCase(this._repository);

  Stream<Either<Failure, List<VoiceMemo>>> call() {
    return _repository.watchAllMemos();
  }
}
```

**File**: `lib/features/voice_memos/domain/usecases/update_voice_memo_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/voice_memo.dart';
import '../repositories/voice_memo_repository.dart';

/// Update voice memo (for rename)
@lazySingleton
class UpdateVoiceMemoUseCase {
  final VoiceMemoRepository _repository;

  UpdateVoiceMemoUseCase(this._repository);

  Future<Either<Failure, Unit>> call(VoiceMemo memo) async {
    return await _repository.updateMemo(memo);
  }
}
```

**File**: `lib/features/voice_memos/domain/usecases/delete_voice_memo_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../value_objects/voice_memo_id.dart';
import '../repositories/voice_memo_repository.dart';

/// Delete a voice memo and its audio file
@lazySingleton
class DeleteVoiceMemoUseCase {
  final VoiceMemoRepository _repository;

  DeleteVoiceMemoUseCase(this._repository);

  Future<Either<Failure, Unit>> call(VoiceMemoId memoId) async {
    return await _repository.deleteMemo(memoId);
  }
}
```

**File**: `lib/features/voice_memos/domain/usecases/play_voice_memo_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../audio_player/domain/entities/audio_source.dart';
import '../../../audio_player/domain/entities/audio_track_metadata.dart';
import '../../../audio_player/domain/services/audio_player_service.dart';
import '../../../audio_player/domain/value_objects/audio_track_id.dart';
import '../entities/voice_memo.dart';

/// Play a voice memo using the centralized audio player
@lazySingleton
class PlayVoiceMemoUseCase {
  final AudioPlayerService _audioPlayerService;

  PlayVoiceMemoUseCase(this._audioPlayerService);

  Future<Either<Failure, Unit>> call(VoiceMemo memo) async {
    // Create audio metadata for the memo
    final metadata = AudioTrackMetadata(
      id: AudioTrackId.fromUniqueString(memo.id.value),
      title: memo.title,
      artist: 'Voice Memo',
      duration: memo.duration,
    );

    // Create audio source
    final audioSource = AudioSource(
      url: memo.localFilePath,
      metadata: metadata,
    );

    // Play via audio player service
    return await _audioPlayerService.playbackService.play(audioSource);
  }
}
```

### Success Criteria

#### Automated Verification:
- [ ] All domain files compile without errors: `flutter analyze`
- [ ] Domain layer has no dependencies on data or presentation layers
- [ ] Use cases are registered in DI after running: `flutter packages pub run build_runner build --delete-conflicting-outputs`

#### Manual Verification:
- [ ] Entity factory method generates correct auto-titles
- [ ] VoiceMemoId generates unique UUIDs
- [ ] Repository contract defines all needed operations
- [ ] Use cases follow single responsibility principle

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to the next phase.

---

## Phase 2: Data Layer - Local Storage and Repository

### Overview
Implement local-only persistence using Isar database. This includes document models, local data source, and repository implementation without any cloud sync.

### Changes Required

#### 1. Create Isar Document Model
**File**: `lib/features/voice_memos/data/models/voice_memo_document.dart`

```dart
import 'package:isar/isar.dart';
import '../../domain/entities/voice_memo.dart';
import '../../domain/value_objects/voice_memo_id.dart';

part 'voice_memo_document.g.dart';

/// Isar document for voice memo local storage
@collection
class VoiceMemoDocument {
  /// Isar requires int ID - use fast hash
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  late String title;
  late String localFilePath;
  late int durationMs;
  late DateTime recordedAt;

  /// Future field for track conversion
  late String? convertedToTrackId;

  VoiceMemoDocument();

  /// Create from domain entity
  factory VoiceMemoDocument.fromDomain(VoiceMemo memo) {
    return VoiceMemoDocument()
      ..id = memo.id.value
      ..title = memo.title
      ..localFilePath = memo.localFilePath
      ..durationMs = memo.duration.inMilliseconds
      ..recordedAt = memo.recordedAt
      ..convertedToTrackId = memo.convertedToTrackId;
  }

  /// Convert to domain entity
  VoiceMemo toDomain() {
    return VoiceMemo(
      id: VoiceMemoId.fromUniqueString(id),
      title: title,
      localFilePath: localFilePath,
      duration: Duration(milliseconds: durationMs),
      recordedAt: recordedAt,
      convertedToTrackId: convertedToTrackId,
    );
  }
}

/// FNV-1a 64-bit hash for string to int ID conversion
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit;
    hash *= 0x100000001b3;
  }
  return hash;
}
```

#### 2. Register Schema in Isar Configuration
**File**: `lib/core/di/app_module.dart` (lines 68-80)

**Changes**: Add `VoiceMemoDocumentSchema` to schemas array

```dart
final schemas = [
  ProjectDocumentSchema,
  AudioTrackDocumentSchema,
  AudioCommentDocumentSchema,
  PlaylistDocumentSchema,
  UserProfileDocumentSchema,
  CachedAudioDocumentUnifiedSchema,
  SyncOperationDocumentSchema,
  InvitationDocumentSchema,
  NotificationDocumentSchema,
  AudioWaveformDocumentSchema,
  TrackVersionDocumentSchema,
  VoiceMemoDocumentSchema, // NEW
];
```

#### 3. Add to Build Configuration
**File**: `build.yaml` (lines 4-18)

**Changes**: Add voice memo document to code generation targets

```yaml
targets:
  $default:
    builders:
      isar_generator:
        generate_for:
          - "lib/features/projects/data/models/project_document.dart"
          - "lib/features/audio_comment/data/models/audio_comment_document.dart"
          # ... existing entries ...
          - "lib/features/voice_memos/data/models/voice_memo_document.dart"  # NEW
```

#### 4. Create Local Data Source
**File**: `lib/features/voice_memos/data/datasources/voice_memo_local_datasource.dart`

```dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/file_system_utils.dart';
import '../models/voice_memo_document.dart';

/// Abstract contract for local data source
abstract class VoiceMemoLocalDataSource {
  Stream<List<VoiceMemoDocument>> watchAllMemos();
  Future<Either<Failure, VoiceMemoDocument?>> getMemoById(String id);
  Future<Either<Failure, Unit>> saveMemo(VoiceMemoDocument memo);
  Future<Either<Failure, Unit>> updateMemo(VoiceMemoDocument memo);
  Future<Either<Failure, Unit>> deleteMemo(String id);
  Future<Either<Failure, Unit>> deleteAllMemos();
}

/// Isar implementation of local data source
@LazySingleton(as: VoiceMemoLocalDataSource)
class IsarVoiceMemoLocalDataSource implements VoiceMemoLocalDataSource {
  final Isar _isar;

  IsarVoiceMemoLocalDataSource(this._isar);

  @override
  Stream<List<VoiceMemoDocument>> watchAllMemos() {
    return _isar.voiceMemoDocuments
        .where()
        .sortByRecordedAtDesc()
        .watch(fireImmediately: true);
  }

  @override
  Future<Either<Failure, VoiceMemoDocument?>> getMemoById(String id) async {
    try {
      final memo = await _isar.voiceMemoDocuments
          .filter()
          .idEqualTo(id)
          .findFirst();
      return Right(memo);
    } catch (e) {
      return Left(CacheFailure('Failed to get memo: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveMemo(VoiceMemoDocument memo) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.voiceMemoDocuments.put(memo);
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to save memo: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateMemo(VoiceMemoDocument memo) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.voiceMemoDocuments.put(memo);
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to update memo: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMemo(String id) async {
    try {
      // Get memo to find file path
      final memo = await _isar.voiceMemoDocuments
          .filter()
          .idEqualTo(id)
          .findFirst();

      if (memo == null) {
        return Left(CacheFailure('Memo not found'));
      }

      // Delete database entry
      await _isar.writeTxn(() async {
        await _isar.voiceMemoDocuments.delete(fastHash(id));
      });

      // Delete audio file
      await FileSystemUtils.deleteFileIfExists(memo.localFilePath);

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to delete memo: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAllMemos() async {
    try {
      // Get all memos to delete their files
      final memos = await _isar.voiceMemoDocuments.where().findAll();

      // Delete all database entries
      await _isar.writeTxn(() async {
        await _isar.voiceMemoDocuments.clear();
      });

      // Delete all audio files
      for (final memo in memos) {
        await FileSystemUtils.deleteFileIfExists(memo.localFilePath);
      }

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to delete all memos: $e'));
    }
  }
}
```

#### 5. Create Repository Implementation
**File**: `lib/features/voice_memos/data/repositories/voice_memo_repository_impl.dart`

```dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/file_system_utils.dart';
import '../../domain/entities/voice_memo.dart';
import '../../domain/repositories/voice_memo_repository.dart';
import '../../domain/value_objects/voice_memo_id.dart';
import '../datasources/voice_memo_local_datasource.dart';
import '../models/voice_memo_document.dart';

@LazySingleton(as: VoiceMemoRepository)
class VoiceMemoRepositoryImpl implements VoiceMemoRepository {
  final VoiceMemoLocalDataSource _localDataSource;

  VoiceMemoRepositoryImpl(this._localDataSource);

  @override
  Stream<Either<Failure, List<VoiceMemo>>> watchAllMemos() {
    try {
      return _localDataSource.watchAllMemos().map(
        (docs) => Right(docs.map((doc) => doc.toDomain()).toList()),
      );
    } catch (e) {
      return Stream.value(
        Left(CacheFailure('Failed to watch memos: $e')),
      );
    }
  }

  @override
  Future<Either<Failure, VoiceMemo?>> getMemoById(VoiceMemoId memoId) async {
    final result = await _localDataSource.getMemoById(memoId.value);
    return result.fold(
      (failure) => Left(failure),
      (doc) => Right(doc?.toDomain()),
    );
  }

  @override
  Future<Either<Failure, Unit>> saveMemo(VoiceMemo memo) async {
    try {
      // Move file from temp to permanent storage
      final permanentPath = await _moveToPermStorage(memo.localFilePath);

      // Create updated memo with permanent path
      final updatedMemo = memo.copyWith(localFilePath: permanentPath);

      // Save to database
      final doc = VoiceMemoDocument.fromDomain(updatedMemo);
      return await _localDataSource.saveMemo(doc);
    } catch (e) {
      return Left(StorageFailure('Failed to save memo: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateMemo(VoiceMemo memo) async {
    final doc = VoiceMemoDocument.fromDomain(memo);
    return await _localDataSource.updateMemo(doc);
  }

  @override
  Future<Either<Failure, Unit>> deleteMemo(VoiceMemoId memoId) async {
    return await _localDataSource.deleteMemo(memoId.value);
  }

  @override
  Future<Either<Failure, Unit>> deleteAllMemos() async {
    return await _localDataSource.deleteAllMemos();
  }

  /// Move file from temp to permanent voice memos directory
  Future<String> _moveToPermStorage(String tempPath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final voiceMemosDir = Directory('${appDir.path}/trackflow/audio/voice_memos');

    // Ensure directory exists
    await FileSystemUtils.ensureDirectoryExists(voiceMemosDir.path);

    // Generate filename from original temp path
    final filename = tempPath.split('/').last;
    final permanentPath = '${voiceMemosDir.path}/$filename';

    // Move file
    final tempFile = File(tempPath);
    await tempFile.copy(permanentPath);
    await tempFile.delete();

    return permanentPath;
  }
}
```

### Success Criteria

#### Automated Verification:
- [ ] Run code generation: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- [ ] Generated file exists: `lib/features/voice_memos/data/models/voice_memo_document.g.dart`
- [ ] No build errors: `flutter analyze`
- [ ] DI configuration updated: Check `lib/core/di/injection.config.dart` includes voice memo registrations

#### Manual Verification:
- [ ] Isar schema registered in app_module.dart
- [ ] Document model uses fastHash for ID conversion
- [ ] Local data source implements all CRUD operations
- [ ] Repository moves files to permanent storage
- [ ] File deletion removes both DB entry and audio file

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to the next phase.

---

## Phase 3: Presentation Layer - BLoC State Management

### Overview
Create BLoC for voice memo state management with events and states following the established patterns from audio comments.

### Changes Required

#### 1. Create Voice Memo Events
**File**: `lib/features/voice_memos/presentation/bloc/voice_memo_event.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../../audio_recording/domain/entities/audio_recording.dart';
import '../../domain/entities/voice_memo.dart';
import '../../domain/value_objects/voice_memo_id.dart';

/// Base event class
abstract class VoiceMemoEvent extends Equatable {
  const VoiceMemoEvent();

  @override
  List<Object?> get props => [];
}

/// Watch all voice memos with reactive updates
class WatchVoiceMemosRequested extends VoiceMemoEvent {
  const WatchVoiceMemosRequested();
}

/// Create memo from completed recording
class CreateVoiceMemoRequested extends VoiceMemoEvent {
  final AudioRecording recording;

  const CreateVoiceMemoRequested(this.recording);

  @override
  List<Object?> get props => [recording];
}

/// Play a voice memo
class PlayVoiceMemoRequested extends VoiceMemoEvent {
  final VoiceMemo memo;

  const PlayVoiceMemoRequested(this.memo);

  @override
  List<Object?> get props => [memo];
}

/// Update memo title (rename)
class UpdateVoiceMemoRequested extends VoiceMemoEvent {
  final VoiceMemo memo;
  final String newTitle;

  const UpdateVoiceMemoRequested(this.memo, this.newTitle);

  @override
  List<Object?> get props => [memo, newTitle];
}

/// Delete a memo
class DeleteVoiceMemoRequested extends VoiceMemoEvent {
  final VoiceMemoId memoId;

  const DeleteVoiceMemoRequested(this.memoId);

  @override
  List<Object?> get props => [memoId];
}
```

#### 2. Create Voice Memo States
**File**: `lib/features/voice_memos/presentation/bloc/voice_memo_state.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/voice_memo.dart';

/// Base state class
abstract class VoiceMemoState extends Equatable {
  const VoiceMemoState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class VoiceMemoInitial extends VoiceMemoState {
  const VoiceMemoInitial();
}

/// Loading state
class VoiceMemoLoading extends VoiceMemoState {
  const VoiceMemoLoading();
}

/// Memos loaded successfully
class VoiceMemosLoaded extends VoiceMemoState {
  final List<VoiceMemo> memos;

  const VoiceMemosLoaded(this.memos);

  @override
  List<Object?> get props => [memos];
}

/// Error state
class VoiceMemoError extends VoiceMemoState {
  final String message;

  const VoiceMemoError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Memo action success (for create/update/delete feedback)
class VoiceMemoActionSuccess extends VoiceMemoState {
  final String message;

  const VoiceMemoActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
```

#### 3. Create Voice Memo BLoC
**File**: `lib/features/voice_memos/presentation/bloc/voice_memo_bloc.dart`

```dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/create_voice_memo_usecase.dart';
import '../../domain/usecases/delete_voice_memo_usecase.dart';
import '../../domain/usecases/play_voice_memo_usecase.dart';
import '../../domain/usecases/update_voice_memo_usecase.dart';
import '../../domain/usecases/watch_voice_memos_usecase.dart';
import 'voice_memo_event.dart';
import 'voice_memo_state.dart';

@injectable
class VoiceMemoBloc extends Bloc<VoiceMemoEvent, VoiceMemoState> {
  final WatchVoiceMemosUseCase _watchVoiceMemosUseCase;
  final CreateVoiceMemoUseCase _createVoiceMemoUseCase;
  final UpdateVoiceMemoUseCase _updateVoiceMemoUseCase;
  final DeleteVoiceMemoUseCase _deleteVoiceMemoUseCase;
  final PlayVoiceMemoUseCase _playVoiceMemoUseCase;

  VoiceMemoBloc(
    this._watchVoiceMemosUseCase,
    this._createVoiceMemoUseCase,
    this._updateVoiceMemoUseCase,
    this._deleteVoiceMemoUseCase,
    this._playVoiceMemoUseCase,
  ) : super(const VoiceMemoInitial()) {
    on<WatchVoiceMemosRequested>(_onWatchMemos);
    on<CreateVoiceMemoRequested>(_onCreateMemo);
    on<PlayVoiceMemoRequested>(_onPlayMemo);
    on<UpdateVoiceMemoRequested>(_onUpdateMemo);
    on<DeleteVoiceMemoRequested>(_onDeleteMemo);
  }

  Future<void> _onWatchMemos(
    WatchVoiceMemosRequested event,
    Emitter<VoiceMemoState> emit,
  ) async {
    emit(const VoiceMemoLoading());

    await emit.onEach<Either<Failure, List<VoiceMemo>>>(
      _watchVoiceMemosUseCase(),
      onData: (either) {
        either.fold(
          (failure) => emit(VoiceMemoError(failure.message)),
          (memos) => emit(VoiceMemosLoaded(memos)),
        );
      },
      onError: (error, stackTrace) {
        emit(VoiceMemoError(error.toString()));
      },
    );
  }

  Future<void> _onCreateMemo(
    CreateVoiceMemoRequested event,
    Emitter<VoiceMemoState> emit,
  ) async {
    final result = await _createVoiceMemoUseCase(event.recording);

    result.fold(
      (failure) => emit(VoiceMemoError(failure.message)),
      (memo) => emit(const VoiceMemoActionSuccess('Voice memo saved')),
    );
  }

  Future<void> _onPlayMemo(
    PlayVoiceMemoRequested event,
    Emitter<VoiceMemoState> emit,
  ) async {
    final result = await _playVoiceMemoUseCase(event.memo);

    result.fold(
      (failure) => emit(VoiceMemoError(failure.message)),
      (_) => null, // Playback state handled by AudioPlayerBloc
    );
  }

  Future<void> _onUpdateMemo(
    UpdateVoiceMemoRequested event,
    Emitter<VoiceMemoState> emit,
  ) async {
    final updatedMemo = event.memo.copyWith(title: event.newTitle);
    final result = await _updateVoiceMemoUseCase(updatedMemo);

    result.fold(
      (failure) => emit(VoiceMemoError(failure.message)),
      (_) => emit(const VoiceMemoActionSuccess('Memo renamed')),
    );
  }

  Future<void> _onDeleteMemo(
    DeleteVoiceMemoRequested event,
    Emitter<VoiceMemoState> emit,
  ) async {
    final result = await _deleteVoiceMemoUseCase(event.memoId);

    result.fold(
      (failure) => emit(VoiceMemoError(failure.message)),
      (_) => emit(const VoiceMemoActionSuccess('Memo deleted')),
    );
  }
}
```

### Success Criteria

#### Automated Verification:
- [ ] Run build runner: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- [ ] No analyzer errors: `flutter analyze`
- [ ] BLoC registered in DI container

#### Manual Verification:
- [ ] Events use domain types (not primitives)
- [ ] States are immutable with props
- [ ] BLoC uses emit.onEach for stream subscriptions
- [ ] Error states provide user-friendly messages

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to the next phase.

---

## Phase 4: Navigation Integration - Add 4th Tab

### Overview
Add Voice Memos as the 4th tab in bottom navigation, update navigation cubit, and register routes.

### Changes Required

#### 1. Update Navigation Cubit Enum
**File**: `lib/features/navegacion/presentation/cubit/navigation_cubit.dart`

**Changes**: Add `voiceMemos` to `AppTab` enum

```dart
enum AppTab {
  projects,
  voiceMemos,  // NEW - insert as 2nd tab
  notifications,
  settings,
}
```

#### 2. Update Main Scaffold for 4-Tab Layout
**File**: `lib/features/navegacion/presentation/widget/main_scaffold.dart`

**Changes**: Add voice memos navigation item and screen

```dart
// Around line 30-40 - Add import
import '../../../voice_memos/presentation/screens/voice_memos_screen.dart';

// Around line 60-80 - Update _getBody method
Widget _getBody(AppTab tab) {
  switch (tab) {
    case AppTab.projects:
      return const ProjectListScreen();
    case AppTab.voiceMemos:  // NEW
      return const VoiceMemosScreen();
    case AppTab.notifications:
      return const NotificationCenterScreen();
    case AppTab.settings:
      return const SettingsScreen();
  }
}
```

#### 3. Update Bottom Navigation Bar
**File**: `lib/features/ui/navigation/bottom_nav.dart`

**Changes**: Add microphone icon as 2nd tab

```dart
// Around line 40-80 - Update navigation items
final items = [
  BottomNavigationBarItem(
    icon: Icon(Icons.folder_outlined),
    activeIcon: Icon(Icons.folder),
    label: 'Projects',
  ),
  BottomNavigationBarItem(  // NEW
    icon: Icon(Icons.mic_outlined),
    activeIcon: Icon(Icons.mic),
    label: 'Voice Memos',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.notifications_outlined),
    activeIcon: Icon(Icons.notifications),
    label: 'Notifications',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.settings_outlined),
    activeIcon: Icon(Icons.settings),
    label: 'Settings',
  ),
];
```

#### 4. Register Voice Memos Route
**File**: `lib/core/router/app_routes.dart`

**Changes**: Add route constant

```dart
class AppRoutes {
  // ... existing routes
  static const String voiceMemos = '/voice-memos';
  static const String voiceMemoRecording = '/voice-memos/recording';
}
```

**File**: `lib/core/router/app_router.dart`

**Changes**: Register routes in GoRouter

```dart
// Add import
import '../../features/voice_memos/presentation/screens/voice_memos_screen.dart';
import '../../features/voice_memos/presentation/screens/voice_memo_recording_screen.dart';

// Around line 50-100 - Add routes
GoRoute(
  path: AppRoutes.voiceMemos,
  builder: (context, state) => const VoiceMemosScreen(),
),
GoRoute(
  path: AppRoutes.voiceMemoRecording,
  builder: (context, state) => const VoiceMemoRecordingScreen(),
),
```

### Success Criteria

#### Automated Verification:
- [ ] No analyzer errors: `flutter analyze`
- [ ] App builds successfully: `flutter build apk --debug` (Android) or `flutter build ios --debug` (iOS)

#### Manual Verification:
- [ ] Bottom navigation shows 4 tabs with correct icons
- [ ] Microphone icon appears as 2nd tab
- [ ] Tapping Voice Memos tab navigates correctly
- [ ] Tab state persists when switching between tabs
- [ ] Selected tab highlights correctly

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to the next phase.

---

## Phase 5: Voice Memos List Screen

### Overview
Create the main Voice Memos screen with list display, FAB for recording, and inline playback controls.

### Changes Required

#### 1. Create Voice Memos List Screen
**File**: `lib/features/voice_memos/presentation/screens/voice_memos_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../ui/feedback/app_feedback_system.dart';
import '../../../ui/navigation/app_scaffold.dart';
import '../../../ui/navigation/app_bar.dart';
import '../bloc/voice_memo_bloc.dart';
import '../bloc/voice_memo_event.dart';
import '../bloc/voice_memo_state.dart';
import '../widgets/voice_memo_card.dart';

class VoiceMemosScreen extends StatelessWidget {
  const VoiceMemosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VoiceMemoBloc>()
        ..add(const WatchVoiceMemosRequested()),
      child: const _VoiceMemosScreenContent(),
    );
  }
}

class _VoiceMemosScreenContent extends StatelessWidget {
  const _VoiceMemosScreenContent();

  @override
  Widget build(BuildContext context) {
    return BlocListener<VoiceMemoBloc, VoiceMemoState>(
      listener: (context, state) {
        if (state is VoiceMemoError) {
          AppFeedbackSystem.showError(context, state.message);
        } else if (state is VoiceMemoActionSuccess) {
          AppFeedbackSystem.showSuccess(context, state.message);
        }
      },
      child: AppScaffold(
        appBar: AppAppBar(
          title: 'Voice Memos',
          showBackButton: false,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(AppRoutes.voiceMemoRecording),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.mic, color: AppColors.onPrimary),
        ),
        body: BlocBuilder<VoiceMemoBloc, VoiceMemoState>(
          builder: (context, state) {
            if (state is VoiceMemoLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is VoiceMemoError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    SizedBox(height: Dimensions.space16),
                    Text(
                      'Failed to load voice memos',
                      style: AppTextStyle.bodyLarge,
                    ),
                    SizedBox(height: Dimensions.space8),
                    Text(
                      state.message,
                      style: AppTextStyle.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is VoiceMemosLoaded) {
              if (state.memos.isEmpty) {
                return _buildEmptyState(context);
              }
              return _buildMemosList(context, state.memos);
            }

            return _buildEmptyState(context);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic_none,
            size: 80,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: Dimensions.space24),
          Text(
            'No voice memos yet',
            style: AppTextStyle.headlineSmall,
          ),
          SizedBox(height: Dimensions.space8),
          Text(
            'Tap the microphone button to\nrecord your first memo',
            textAlign: TextAlign.center,
            style: AppTextStyle.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemosList(BuildContext context, List<VoiceMemo> memos) {
    return ListView.separated(
      padding: EdgeInsets.all(Dimensions.space16),
      itemCount: memos.length,
      separatorBuilder: (_, __) => SizedBox(height: Dimensions.space12),
      itemBuilder: (context, index) {
        return VoiceMemoCard(memo: memos[index]);
      },
    );
  }
}
```

#### 2. Create Voice Memo Card Widget
**File**: `lib/features/voice_memos/presentation/widgets/voice_memo_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../audio_player/presentation/bloc/audio_player_bloc.dart';
import '../../../audio_player/presentation/bloc/audio_player_state.dart';
import '../../../ui/cards/base_card.dart';
import '../../../ui/menus/app_popup_menu.dart';
import '../../domain/entities/voice_memo.dart';
import '../bloc/voice_memo_bloc.dart';
import '../bloc/voice_memo_event.dart';
import 'voice_memo_rename_dialog.dart';

class VoiceMemoCard extends StatelessWidget {
  final VoiceMemo memo;

  const VoiceMemoCard({super.key, required this.memo});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      padding: EdgeInsets.all(Dimensions.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: Dimensions.space12),
          _buildPlaybackControls(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onLongPress: () => _showRenameDialog(context),
                child: Text(
                  memo.title,
                  style: AppTextStyle.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: Dimensions.space4),
              Text(
                dateFormat.format(memo.recordedAt),
                style: AppTextStyle.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
          onPressed: () => _showMenu(context),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        final isCurrentMemo = state is AudioPlayerSessionState &&
            state.session.currentTrack?.id.value == memo.id.value;

        final isPlaying = isCurrentMemo &&
            state is AudioPlayerPlaying;

        final position = isCurrentMemo && state is AudioPlayerSessionState
            ? state.session.position
            : Duration.zero;

        final progress = memo.duration.inMilliseconds > 0
            ? position.inMilliseconds / memo.duration.inMilliseconds
            : 0.0;

        return Row(
          children: [
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.primary,
              ),
              onPressed: () => _togglePlayback(context, isPlaying),
            ),
            Expanded(
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: AppColors.surface,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                  SizedBox(height: Dimensions.space4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style: AppTextStyle.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _formatDuration(memo.duration),
                        style: AppTextStyle.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _togglePlayback(BuildContext context, bool isPlaying) {
    if (isPlaying) {
      context.read<AudioPlayerBloc>().add(const PauseAudioRequested());
    } else {
      context.read<VoiceMemoBloc>().add(PlayVoiceMemoRequested(memo));
    }
  }

  void _showRenameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => VoiceMemoRenameDialog(
        memo: memo,
        onRename: (newTitle) {
          context.read<VoiceMemoBloc>().add(
            UpdateVoiceMemoRequested(memo, newTitle),
          );
        },
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showAppMenu<String>(
      context: context,
      items: [
        AppMenuItem<String>(
          value: 'rename',
          label: 'Rename',
          icon: Icons.edit,
        ),
        AppMenuItem<String>(
          value: 'delete',
          label: 'Delete',
          icon: Icons.delete,
          iconColor: AppColors.error,
          textColor: AppColors.error,
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'rename':
            _showRenameDialog(context);
            break;
          case 'delete':
            context.read<VoiceMemoBloc>().add(
              DeleteVoiceMemoRequested(memo.id),
            );
            break;
        }
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
```

#### 3. Create Rename Dialog Widget
**File**: `lib/features/voice_memos/presentation/widgets/voice_memo_rename_dialog.dart`

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../ui/buttons/primary_button.dart';
import '../../../ui/inputs/app_text_field.dart';
import '../../domain/entities/voice_memo.dart';

class VoiceMemoRenameDialog extends StatefulWidget {
  final VoiceMemo memo;
  final Function(String newTitle) onRename;

  const VoiceMemoRenameDialog({
    super.key,
    required this.memo,
    required this.onRename,
  });

  @override
  State<VoiceMemoRenameDialog> createState() => _VoiceMemoRenameDialogState();
}

class _VoiceMemoRenameDialogState extends State<VoiceMemoRenameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.memo.title);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text('Rename Voice Memo', style: AppTextStyle.titleLarge),
      content: AppTextField(
        controller: _controller,
        hintText: 'Enter new title',
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        PrimaryButton(
          text: 'Rename',
          onPressed: () {
            final newTitle = _controller.text.trim();
            if (newTitle.isNotEmpty) {
              widget.onRename(newTitle);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
```

### Success Criteria

#### Automated Verification:
- [ ] No analyzer errors: `flutter analyze`
- [ ] App builds successfully: `flutter run`

#### Manual Verification:
- [ ] Voice Memos screen displays with correct app bar
- [ ] FAB appears in bottom right corner
- [ ] Empty state shows when no memos exist
- [ ] List displays memos sorted by date (newest first)
- [ ] Each memo card shows title, date, and duration
- [ ] Play button triggers playback
- [ ] Progress bar updates during playback
- [ ] Long-press title opens rename dialog
- [ ] Menu button shows rename and delete options
- [ ] Rename updates title immediately
- [ ] Delete removes memo from list

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to the next phase.

---

## Phase 6: Recording Screen with Pulsing Circle

### Overview
Create a dedicated recording screen with a pulsing circle animation that reacts to audio input volume, start/stop controls, and automatic navigation back to the list upon completion.

### Changes Required

#### 1. Create Recording Screen
**File**: `lib/features/voice_memos/presentation/screens/voice_memo_recording_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../audio_recording/presentation/bloc/recording_bloc.dart';
import '../../../audio_recording/presentation/bloc/recording_event.dart';
import '../../../audio_recording/presentation/bloc/recording_state.dart';
import '../../../ui/navigation/app_scaffold.dart';
import '../../../ui/navigation/app_bar.dart';
import '../bloc/voice_memo_bloc.dart';
import '../bloc/voice_memo_event.dart';
import '../widgets/pulsing_circle_animator.dart';
import '../widgets/recording_timer.dart';

class VoiceMemoRecordingScreen extends StatefulWidget {
  const VoiceMemoRecordingScreen({super.key});

  @override
  State<VoiceMemoRecordingScreen> createState() =>
      _VoiceMemoRecordingScreenState();
}

class _VoiceMemoRecordingScreenState extends State<VoiceMemoRecordingScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-start recording when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RecordingBloc>().add(const StartRecordingRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecordingBloc, RecordingState>(
      listener: (context, state) {
        if (state is RecordingCompleted) {
          // Save the memo
          context.read<VoiceMemoBloc>().add(
            CreateVoiceMemoRequested(state.recording),
          );
          // Navigate back to list
          context.pop();
        } else if (state is RecordingError) {
          // Show error and go back
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          context.pop();
        }
      },
      child: AppScaffold(
        appBar: AppAppBar(
          title: 'Recording',
          onBackPressed: () {
            context.read<RecordingBloc>().add(const CancelRecordingRequested());
            context.pop();
          },
        ),
        body: BlocBuilder<RecordingBloc, RecordingState>(
          builder: (context, state) {
            if (state is RecordingInProgress || state is RecordingPaused) {
              return _buildRecordingUI(context, state);
            }

            // Loading state
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildRecordingUI(BuildContext context, RecordingState state) {
    final session = state is RecordingInProgress
        ? state.session
        : (state as RecordingPaused).session;

    final amplitude = session.currentAmplitude ?? 0.0;
    final elapsed = session.elapsed;
    final isPaused = state is RecordingPaused;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pulsing circle
          PulsingCircleAnimator(
            amplitude: amplitude,
            isRecording: !isPaused,
          ),

          SizedBox(height: Dimensions.space48),

          // Timer
          RecordingTimer(elapsed: elapsed),

          SizedBox(height: Dimensions.space48),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cancel button
              IconButton(
                iconSize: 48,
                icon: Icon(Icons.close, color: AppColors.error),
                onPressed: () {
                  context.read<RecordingBloc>().add(
                    const CancelRecordingRequested(),
                  );
                  context.pop();
                },
              ),

              SizedBox(width: Dimensions.space32),

              // Pause/Resume button
              IconButton(
                iconSize: 48,
                icon: Icon(
                  isPaused ? Icons.play_arrow : Icons.pause,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  if (isPaused) {
                    context.read<RecordingBloc>().add(
                      const ResumeRecordingRequested(),
                    );
                  } else {
                    context.read<RecordingBloc>().add(
                      const PauseRecordingRequested(),
                    );
                  }
                },
              ),

              SizedBox(width: Dimensions.space32),

              // Stop/Save button
              IconButton(
                iconSize: 48,
                icon: Icon(Icons.check, color: AppColors.success),
                onPressed: () {
                  context.read<RecordingBloc>().add(
                    const StopRecordingRequested(),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: Dimensions.space24),

          // Instructions
          Text(
            isPaused ? 'Recording paused' : 'Recording in progress...',
            style: AppTextStyle.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 2. Create Pulsing Circle Animator Widget
**File**: `lib/features/voice_memos/presentation/widgets/pulsing_circle_animator.dart`

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PulsingCircleAnimator extends StatefulWidget {
  final double amplitude; // 0.0 to 1.0
  final bool isRecording;

  const PulsingCircleAnimator({
    super.key,
    required this.amplitude,
    required this.isRecording,
  });

  @override
  State<PulsingCircleAnimator> createState() => _PulsingCircleAnimatorState();
}

class _PulsingCircleAnimatorState extends State<PulsingCircleAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scale based on amplitude (0.8 to 1.2 range)
    final amplitudeScale = 0.8 + (widget.amplitude * 0.4);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final totalScale = widget.isRecording
            ? _animation.value * amplitudeScale
            : 1.0;

        return Transform.scale(
          scale: totalScale,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(0.8),
                  AppColors.primary.withOpacity(0.4),
                  AppColors.primary.withOpacity(0.1),
                ],
                stops: const [0.3, 0.6, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                widget.isRecording ? Icons.mic : Icons.pause,
                size: 80,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        );
      },
    );
  }
}
```

#### 3. Create Recording Timer Widget
**File**: `lib/features/voice_memos/presentation/widgets/recording_timer.dart`

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';

class RecordingTimer extends StatelessWidget {
  final Duration elapsed;

  const RecordingTimer({super.key, required this.elapsed});

  @override
  Widget build(BuildContext context) {
    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.error,
          ),
        ),
        SizedBox(width: 8),
        Text(
          '$minutes:$seconds',
          style: AppTextStyle.displaySmall.copyWith(
            fontWeight: FontWeight.bold,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
```

### Success Criteria

#### Automated Verification:
- [ ] No analyzer errors: `flutter analyze`
- [ ] App builds successfully: `flutter run`

#### Manual Verification:
- [ ] Recording starts automatically when screen opens
- [ ] Pulsing circle appears and animates
- [ ] Circle scales with audio amplitude (speak loudly to test)
- [ ] Timer shows recording duration in MM:SS format
- [ ] Pause button pauses recording and changes icon
- [ ] Resume button resumes recording
- [ ] Cancel button stops recording and navigates back without saving
- [ ] Check/Save button stops recording, saves memo, and navigates back
- [ ] New memo appears at top of list after recording
- [ ] Back button cancels recording and navigates back

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to the next phase.

---

## Phase 7: Integration Testing and Polish

### Overview
Final integration testing, bug fixes, and UI polish to ensure a production-ready feature.

### Changes Required

#### 1. Add Permission Error Handling
**File**: `lib/features/voice_memos/presentation/screens/voice_memo_recording_screen.dart`

**Changes**: Add permission denied state handling

```dart
// Around line 45 - Update BlocListener
BlocListener<RecordingBloc, RecordingState>(
  listener: (context, state) {
    if (state is RecordingCompleted) {
      context.read<VoiceMemoBloc>().add(
        CreateVoiceMemoRequested(state.recording),
      );
      context.pop();
    } else if (state is RecordingError) {
      // Check if permission error
      if (state.message.contains('Permission') ||
          state.message.contains('permission')) {
        _showPermissionDialog(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
          ),
        );
        context.pop();
      }
    }
  },
  // ... rest of widget
)

// Add method
void _showPermissionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text('Microphone Permission Required', style: AppTextStyle.titleLarge),
      content: Text(
        'TrackFlow needs microphone access to record voice memos. '
        'Please enable microphone permission in your device settings.',
        style: AppTextStyle.bodyMedium,
      ),
      actions: [
        PrimaryButton(
          text: 'OK',
          onPressed: () {
            Navigator.of(ctx).pop();
            context.pop();
          },
        ),
      ],
    ),
  );
}
```

#### 2. Add Loading State for Memo Creation
**File**: `lib/features/voice_memos/presentation/screens/voice_memos_screen.dart`

**Changes**: Show loading indicator when creating memo

```dart
// Update BlocListener to handle multiple states
BlocListener<VoiceMemoBloc, VoiceMemoState>(
  listener: (context, state) {
    if (state is VoiceMemoError) {
      AppFeedbackSystem.showError(context, state.message);
    } else if (state is VoiceMemoActionSuccess) {
      AppFeedbackSystem.showSuccess(context, state.message);
      // Re-fetch memos after action
      context.read<VoiceMemoBloc>().add(const WatchVoiceMemosRequested());
    }
  },
  // ... rest of listener
)
```

#### 3. Add Swipe-to-Delete Gesture
**File**: `lib/features/voice_memos/presentation/widgets/voice_memo_card.dart`

**Changes**: Wrap card in Dismissible

```dart
@override
Widget build(BuildContext context) {
  return Dismissible(
    key: Key(memo.id.value),
    direction: DismissDirection.endToStart,
    background: Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: Dimensions.space20),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
      ),
      child: Icon(Icons.delete, color: AppColors.onError),
    ),
    confirmDismiss: (direction) async {
      return await _showDeleteConfirmation(context);
    },
    onDismissed: (direction) {
      context.read<VoiceMemoBloc>().add(
        DeleteVoiceMemoRequested(memo.id),
      );
    },
    child: BaseCard(
      padding: EdgeInsets.all(Dimensions.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: Dimensions.space12),
          _buildPlaybackControls(context),
        ],
      ),
    ),
  );
}

Future<bool> _showDeleteConfirmation(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text('Delete Voice Memo?', style: AppTextStyle.titleLarge),
      content: Text(
        'This action cannot be undone.',
        style: AppTextStyle.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text('Delete', style: TextStyle(color: AppColors.error)),
        ),
      ],
    ),
  ) ?? false;
}
```

#### 4. Add Analytics/Logging (Optional)
**File**: `lib/features/voice_memos/domain/usecases/create_voice_memo_usecase.dart`

**Changes**: Add logging for memo creation

```dart
import '../../../../core/utils/app_logger.dart';

// In call method, after successful save:
AppLogger.info(
  'Voice memo created: ${memo.id.value}, duration: ${memo.duration.inSeconds}s',
  tag: 'CreateVoiceMemoUseCase',
);
```

### Success Criteria

#### Automated Verification:
- [ ] All tests pass: `flutter test`
- [ ] No analyzer warnings: `flutter analyze`
- [ ] Build succeeds for both platforms: `flutter build apk` and `flutter build ios`

#### Manual Verification:
- [ ] **Recording Permission Flow**:
  - [ ] First time recording requests microphone permission
  - [ ] Permission denial shows informative dialog
  - [ ] Permission grant allows recording to proceed
- [ ] **Recording Experience**:
  - [ ] Pulsing circle reacts smoothly to voice input
  - [ ] Timer updates every second
  - [ ] Pause/resume works without glitches
  - [ ] Cancel discards recording without trace
  - [ ] Save creates memo with correct title and duration
- [ ] **List Experience**:
  - [ ] Memos appear sorted by date (newest first)
  - [ ] Empty state shows when no memos exist
  - [ ] Pull-to-refresh works (if implemented)
  - [ ] Scrolling is smooth with many memos
- [ ] **Playback Experience**:
  - [ ] Play button starts playback
  - [ ] Progress bar updates smoothly
  - [ ] Pause button pauses playback
  - [ ] Multiple memos can be played sequentially
  - [ ] Switching tabs doesn't interrupt playback
- [ ] **Editing Experience**:
  - [ ] Long-press title opens rename dialog
  - [ ] Rename updates title immediately
  - [ ] Menu shows rename and delete options
  - [ ] Swipe-to-delete shows confirmation
  - [ ] Delete removes memo and audio file
- [ ] **Edge Cases**:
  - [ ] Recording very short memos (< 1 second)
  - [ ] Recording long memos (> 5 minutes)
  - [ ] Handling device rotation during recording
  - [ ] Low storage space scenario
  - [ ] App backgrounding during recording cancels properly

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding.

---

## Testing Strategy

### Unit Tests

#### Domain Layer Tests
Create tests in `test/features/voice_memos/domain/`:

**Entities**:
- `voice_memo_test.dart`:
  - Test factory method generates correct auto-titles
  - Test copyWith creates new instance with updated fields
  - Test equality comparison

**Use Cases**:
- `create_voice_memo_usecase_test.dart`:
  - Test successful memo creation
  - Test repository failure handling
- `watch_voice_memos_usecase_test.dart`:
  - Test stream emission
  - Test error handling
- `delete_voice_memo_usecase_test.dart`:
  - Test successful deletion
  - Test deletion of non-existent memo

#### Data Layer Tests
Create tests in `test/features/voice_memos/data/`:

**Models**:
- `voice_memo_document_test.dart`:
  - Test fromDomain conversion
  - Test toDomain conversion
  - Test fastHash generates consistent IDs

**Data Sources**:
- `voice_memo_local_datasource_test.dart`:
  - Mock Isar instance
  - Test CRUD operations
  - Test stream emissions
  - Test file deletion

**Repositories**:
- `voice_memo_repository_impl_test.dart`:
  - Test file move to permanent storage
  - Test all repository methods
  - Test error handling

#### Presentation Layer Tests
Create tests in `test/features/voice_memos/presentation/`:

**BLoC**:
- `voice_memo_bloc_test.dart`:
  - Test initial state
  - Test watch memos event flow
  - Test create memo event flow
  - Test update memo event flow
  - Test delete memo event flow
  - Test error state emissions

### Integration Tests

Create integration tests in `integration_test/voice_memos_test.dart`:

```dart
void main() {
  testWidgets('Voice memos end-to-end flow', (tester) async {
    // 1. Launch app and navigate to voice memos tab
    // 2. Verify empty state
    // 3. Tap FAB to start recording
    // 4. Wait for recording screen
    // 5. Tap stop button
    // 6. Verify memo appears in list
    // 7. Tap play button
    // 8. Verify playback starts
    // 9. Long-press title to rename
    // 10. Verify title updates
    // 11. Swipe to delete
    // 12. Verify memo removed
  });
}
```

### Manual Testing Checklist

#### Functionality
- [ ] Create first voice memo
- [ ] Create multiple memos in succession
- [ ] Play memo inline
- [ ] Pause playback mid-memo
- [ ] Resume playback
- [ ] Rename memo via long-press
- [ ] Rename memo via menu
- [ ] Delete memo via menu
- [ ] Delete memo via swipe
- [ ] Cancel recording before saving
- [ ] Pause and resume during recording

#### UI/UX
- [ ] Empty state displays correctly
- [ ] List scrolls smoothly
- [ ] FAB is accessible and visible
- [ ] Recording screen transitions smoothly
- [ ] Pulsing circle animates properly
- [ ] Timer displays accurately
- [ ] Progress bar updates smoothly
- [ ] Icons are appropriate and clear
- [ ] Text is readable and well-sized
- [ ] Colors follow theme system

#### Performance
- [ ] List with 50+ memos scrolls smoothly
- [ ] Recording doesn't lag or stutter
- [ ] Playback starts quickly
- [ ] No memory leaks during extended use
- [ ] App remains responsive during operations

#### Edge Cases
- [ ] Microphone permission denied
- [ ] Microphone permission granted
- [ ] Recording with no audio input (silence)
- [ ] Recording with very loud audio
- [ ] Device rotation during recording
- [ ] App backgrounded during recording
- [ ] Low storage space
- [ ] Corrupted audio file handling

---

## Performance Considerations

### Database Optimization
- **Isar Indexing**: `recordedAt` field should have descending index for fast sorting
- **Query Limit**: Consider pagination if user accumulates 100+ memos
- **Memory**: Dispose of streams properly in BLoC `close()` method

### Audio File Management
- **File Size**: M4A at 128kbps averages ~1MB per minute
- **Storage**: Monitor total storage with many memos
- **Cleanup**: Implement periodic cleanup of orphaned files
- **Compression**: Consider lower bitrate for longer recordings (e.g., 64kbps for memos > 5 minutes)

### UI Performance
- **List Rendering**: Use `ListView.builder` for efficient rendering
- **Animation**: Pulsing circle uses `AnimationController` - ensure disposal
- **Throttling**: Amplitude updates every 100ms (existing pattern from recording service)

### Memory Management
- **Stream Subscriptions**: Always cancel in BLoC close
- **Audio Player**: Single instance prevents memory bloat
- **File Handles**: Ensure file streams close after operations

---

## Migration Notes

### Initial Setup (First Time Users)
1. No migration needed - feature is entirely new
2. Isar schema auto-creates collection on first run
3. Voice memos directory auto-creates on first recording

### Future Scalability - Track Conversion

When implementing the conversion feature later:

1. **Data Structure Ready**:
   - `VoiceMemo.convertedToTrackId` field exists
   - Update to non-null when conversion happens

2. **Conversion Flow** (future implementation):
   ```dart
   // Pseudocode for future conversion
   Future<Either<Failure, AudioTrack>> convertMemoToTrack(VoiceMemo memo) {
     // 1. Copy audio file to tracks directory
     // 2. Create TrackVersion entity with memo metadata
     // 3. Update memo.convertedToTrackId = track.id
     // 4. Save both entities
   }
   ```

3. **UI Indicators** (future):
   - Show badge on converted memos
   - Disable deletion if converted (or cascade delete)
   - Link to original track from memo card

---

## References

### Codebase Patterns
- Audio recording system: `lib/features/audio_recording/`
- Audio playback system: `lib/features/audio_player/`
- Audio comments (reference implementation): `lib/features/audio_comment/`
- Isar patterns: `lib/features/audio_cache/data/models/cached_audio_document_unified.dart`
- Navigation: `lib/features/navegacion/presentation/widget/main_scaffold.dart`
- Theme system: `lib/core/theme/`

### External Documentation
- Isar Database: https://isar.dev/
- `record` package: https://pub.dev/packages/record
- `just_audio` package: https://pub.dev/packages/just_audio
- Flutter BLoC: https://bloclibrary.dev/
- GoRouter: https://pub.dev/packages/go_router

### Design Inspiration
- WhatsApp voice message recording (gesture-based input bar)
- Apple Voice Memos (pulsing circle UI)
- Spotify player controls (inline playback)
